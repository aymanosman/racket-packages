#lang racket

(require zeromq)

(define (worker-routine)
  ;; Socket to talk to dispatcher
  (define receiver (zmq-socket 'rep #:connect "inproc://workers"))
  (let loop ()
    (define msg (zmq-recv receiver))
    (printf "Received request: ~a [~a]\n" msg (current-id))
    (sleep 1)
    (zmq-send receiver "World")
    (loop))
  (zmq-close receiver))

(define clients (zmq-socket 'router #:bind "tcp://*:5555"))
(define workers (zmq-socket 'dealer #:bind "inproc://workers"))

(define current-id (make-parameter #f))

(for ([i 5])
  (thread (thunk (parameterize ([current-id i])
                   (worker-routine)))))

(zmq-proxy clients workers)
