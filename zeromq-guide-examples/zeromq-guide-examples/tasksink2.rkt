#lang racket

(require zeromq)

(define receiver (zmq-socket 'pull #:bind "tcp://*:5558"))
(define controller (zmq-socket 'pub #:bind "tcp://*:5559"))

;; Wait for start of batch
(void (zmq-recv receiver))

;; Start our clock now
(define start-time (current-inexact-milliseconds))

;; Process 100 confirmations
(for ([task-nbr 100])
  (define string (zmq-recv receiver))
  (if (= 0 (modulo task-nbr 10))
      (printf ":")
      (printf "."))
  (flush-output))

(newline)
(printf "Total elapsed time: ~a msec\n" (- (current-inexact-milliseconds) start-time))

;; Send kill signal to workers

(zmq-send controller "KILL")