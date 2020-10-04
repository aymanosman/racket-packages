#lang racket

(require zeromq)

(define responder (zmq-socket 'rep #:bind "tcp://*:5555"))

(let loop ()
  (define msg (zmq-recv responder))
  ;; Do some work
  (sleep 1)
  (zmq-send responder "World")
  (loop))