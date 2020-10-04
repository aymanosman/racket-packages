#lang racket

(require zeromq)

;; Socket to send messages on
(define sender (zmq-socket 'push #:bind "tcp://*:5557"))

;; Socket to send start of batch message on
(define sink (zmq-socket 'push #:connect "tcp://localhost:5558"))

(printf "Press Enter when workers are ready: \n")
(void (read-line))
(printf "Sending task to workers\n")

;; The first message is "0" and signals start of batch
(zmq-send sink "0")

;; Send 100 tasks
(define total-msec
  (for/fold ([total-msec 0])
            ([task-nbr 100])
    ;; Random workload from 1 to 100msecs
    (define workload (random 1 100))
    (zmq-send sender (~a workload))
    (+ total-msec workload)))

(printf "Total expected cost: ~a msec\n" total-msec)
