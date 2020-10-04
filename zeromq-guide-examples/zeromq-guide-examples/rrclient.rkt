#lang racket

(require zeromq)

(define socket (zmq-socket 'req #:connect "tcp://localhost:5559"))

(for ([request (in-range 1 11)])
  (zmq-send socket "Hello")
  (define message (zmq-recv socket))
  (printf "Received reply ~s [~s]\n" request message))