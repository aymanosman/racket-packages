#lang racket

(require zeromq)

(printf "Connectin to hello world server...\n")
(define requester (zmq-socket 'req #:connect "tcp://localhost:5555"))

(for ([n (in-range 1 10)])
  (printf "Sending Hello ~a...\n" n)
  (zmq-send requester "Hello")

  (define reply (zmq-recv requester))
  (printf "Received ~a ~a\n" reply n))