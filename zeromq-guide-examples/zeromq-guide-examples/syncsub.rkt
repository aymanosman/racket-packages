#lang racket

(require zeromq)

;; First, connect our subscriber socket
(define subscriber (zmq-socket 'sub
                               #:connect "tcp://localhost:5561"
                               #:subscribe ""))

;; 0MQ is so fast, we need to wait a while...
(sleep 1)

;; Second, synchronize with publisher
(define syncclient (zmq-socket 'req #:connect "tcp://localhost:5562"))

;; - send a synchronization request
(zmq-send syncclient "")

;; - wait for sychronization reply
(void (zmq-recv syncclient))

;; Third, get our updates and report how many we got
(define update-nbr
  (let loop ([n 0])
    (define string (zmq-recv subscriber))
    (if (bytes=? string #"END")
        n
        (loop (add1 n)))))

(printf "Received ~a updates\n" update-nbr)
  