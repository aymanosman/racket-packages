#lang racket

(require zeromq)

(define socket (zmq-socket 'rep #:connect "tcp://localhost:5560"))

(let loop ()
  (define message (zmq-recv socket))
  (printf "Received request: ~s\n" message)
  (flush-output)
  (zmq-send socket "World")
  (loop))