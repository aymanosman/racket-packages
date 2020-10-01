#lang racket

(require zeromq)

(define frontend (zmq-socket 'router #:bind "tcp://*:5559"))
(define backend (zmq-socket 'dealer #:bind "tcp://*:5560"))

(define (loop)
  (match-define (list socket msg) (sync (broker-evt frontend)
                                        (broker-evt backend)))
  (cond
    [(eq? socket frontend)
     (zmq-send-message backend msg)]
    [(eq? socket backend)
     (zmq-send-message frontend msg)])

  (loop))

;; HELPERS

(define (broker-evt socket)
  (wrap-evt socket
            (lambda (msg)
              (list socket msg))))

;; MAIN

(loop)