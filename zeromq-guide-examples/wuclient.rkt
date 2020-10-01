#lang racket

(require zeromq)

(printf "Collecting updates from weather server...\n")

(define socket (zmq-socket 'sub #:connect "tcp://localhost:5556"))

;; Subscribe to zipcode, default is NYC, 10001
(define zip-filter (command-line #:program "wuclient"
                                 #:args maybe-filter
                                 (match maybe-filter
                                   [(list filter _ ...)
                                    filter]
                                   [(list)
                                    "10001"])))

(zmq-subscribe socket zip-filter)

;; Process 5 updates
(define update-nbr 5)
(define total-temp 0)
(for ([_ update-nbr])
  (define string (zmq-recv socket))
  (define temperature
    (let ([in (open-input-bytes string)])
      (read in)
      (read in)))
  (set! total-temp (+ total-temp temperature)))

(printf "Average temperature for zipcode '~a' was ~a\n" zip-filter (/ total-temp update-nbr))
