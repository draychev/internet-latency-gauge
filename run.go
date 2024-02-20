package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"regexp"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"

	"github.com/draychev/go-toolbox/pkg/envvar"
	"github.com/draychev/go-toolbox/pkg/logger"
	"github.com/draychev/go-toolbox/pkg/signal"
)

var log = logger.NewPretty("internet-latency-gauge")

const defaultPortNumber = "9876" /* Prometheus must be configured with this */

var loc = "default" /* where is this computer located? */
var computerName = "default"

func getComputerName() string {
	var utsname syscall.Utsname
	err := syscall.Uname(&utsname)
	if err != nil {
		log.Error().Err(err).Msg("Error calling uname")
		return ""
	}

	nodeName := make([]byte, 0, len(utsname.Nodename))
	for _, c := range utsname.Nodename[:] {
		if c == 0 {
			break
		}
		nodeName = append(nodeName, byte(c))
	}
	return strings.Split(string(nodeName), ".")[0]
}

func ping(destinationHost string, pingGauge *prometheus.GaugeVec) {
	// Compile the regular expression and check for errors
	re, err := regexp.Compile(`time=(\d+\.?\d*) ms`)
	if err != nil {
		fmt.Println("Error compiling regex:", err)
		return
	}

	cmd := exec.Command("ping", "-c", "1", destinationHost)
	output, err := cmd.CombinedOutput()
	if err != nil {
		log.Error().Err(err).Msgf("Error pinging %s", destinationHost)
		return
	}
	match := re.FindStringSubmatch(string(output))
	if len(match) < 2 {
		log.Error().Msgf("Did not found time with regex in output: %s", output)
		return
	}
	tm, err := strconv.ParseFloat(match[1], 64)
	if err != nil {
		log.Error().Err(err).Msgf("Error parsing %s into float", match)
		return
	}
	pingGauge.WithLabelValues(computerName, loc, destinationHost).Set(tm)
}

type loggingHandler struct {
	handler http.Handler
}

func (h *loggingHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	start := time.Now()
	log.Info().Msgf("Started %s %s", r.Method, r.URL.Path)
	h.handler.ServeHTTP(w, r)
	log.Info().Msgf("Completed %s %s in %v", r.Method, r.URL.Path, time.Since(start))
}

func main() {
	// We'll need these variables for the Prometheus tags
	loc = os.Getenv("LOCATION")
	destinations := strings.Split(os.Getenv("PING_DEST"), ",")
	computerName = getComputerName()

	if loc == "" {
		log.Error().Msg("Where is this computer located? Set environment variable LOCATION")
		os.Exit(1)
	}

	if computerName == "" {
		log.Error().Msg("Could not determine the name of this computer")
		os.Exit(1)
	}

	if len(destinations) < 1 {
		log.Error().Msg("No destinations to ping. Set these as comma separated values in the PING_DEST env var.")
		os.Exit(1)
	}

	log.Info().Msgf("This computer is %s and is located in %s. Will ping %+v", computerName, loc, destinations)

	// name        -- this computer's name (uname -n)
	// location    -- this computer's location (closest airport code)
	// destination -- the destination we are pinging (latency to this)
	pingGauge := promauto.NewGaugeVec(prometheus.GaugeOpts{
		Name: "ping_gauge",
		Help: "A gauge to track ping latency to some destination",
	}, []string{"name", "location", "destination"})

	// how often should we ping
	pingTicker := time.NewTicker(5 * time.Second)
	go func(gauge *prometheus.GaugeVec) {
		for {
			// Wait for the ticker to tick
			<-pingTicker.C
			for _, destination := range destinations {
				ping(strings.Trim(destination, " "), gauge)
			}
		}
	}(pingGauge)

	mux := http.NewServeMux()
	loggedMux := &loggingHandler{handler: mux}

	mux.Handle("/metrics", promhttp.Handler())
	portNumber := envvar.GetEnv("PORT_NUMBER", defaultPortNumber)

	_, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	stop := signal.RegisterExitHandlers(cancel)

	log.Info().Msgf("Starting web server on port %s", portNumber)

	server := &http.Server{
		Addr:    fmt.Sprintf(":%s", portNumber),
		Handler: loggedMux,
	}

	go func() {
		log.Error().Err(server.ListenAndServe()).Msg("Could not start server")
	}()

	<-stop
	cancel()
	log.Info().Msg("We are done!")
}
