#lang racket

(require zeromq)

(define receiver (zmq-socket 'pull #:connect "tcp://localhost:5557"))
(define sender (zmq-socket 'push #:connect "tcp://localhost:5558"))

;; Process tasks forever
(let loop ()

  (define string (zmq-recv receiver))
  (printf "~a." string) ;; Show progress
  (flush-output)
  (define msecs (/ (string->number (bytes->string/utf-8 string)) 1000))
  (sleep msecs)         ;; Do work
  (zmq-send sender "")  ;; Send results to sink

  (loop))