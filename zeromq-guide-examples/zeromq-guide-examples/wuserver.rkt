#lang racket/base

(require racket/format zeromq)

(define publisher (zmq-socket 'pub #:bind "tcp://*:5556"))

(let loop ()
  ;; Get values that will fool the boss
  (define zipcode (random 100000))
  (define temperature (random -80 135))
  (define relhumidity (random 10 60))

  (zmq-send publisher (format "~a ~a ~a"
                              (~r zipcode #:min-width 5 #:pad-string "0")
                              temperature
                              relhumidity))
  (loop))