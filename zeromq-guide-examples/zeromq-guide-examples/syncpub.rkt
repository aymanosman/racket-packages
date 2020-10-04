#lang racket

(require zeromq)

(define SUBSCRIBERS_EXPECTED 10)

;; Socket to talk to clients
(define publisher (zmq-socket 'pub))

(define sndhwm 1100000)
(zmq-set-option publisher 'sndhwm sndhwm)

(zmq-bind publisher "tcp://*:5561")

;; Socket to receive signals
(define syncservice (zmq-socket 'rep #:bind "tcp://*:5562"))

;; Get synchronization from subscribers
(printf "Waiting for subscribers\n")
(define subscribers 0)
(let loop ()
  (when (< subscribers SUBSCRIBERS_EXPECTED)
    ;; - wait for synchronization request
    (define string (zmq-recv syncservice))
    ;; - send synchronization reply
    (zmq-send syncservice "")
    (set! subscribers (add1 subscribers))
    (loop)))

;; Now broadcast exactly 1M updates followed by END
(printf "Broadcast messages\n")
(for ([update_nbr 1000000])
  (zmq-send publisher "Rhubarb"))
(zmq-send publisher "END")
