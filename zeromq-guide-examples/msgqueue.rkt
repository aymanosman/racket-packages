#lang racket

(require zeromq)

(define frontend (zmq-socket 'router #:bind "tcp://*:5559"))
(define backend (zmq-socket 'dealer #:bind "tcp://*:5560"))

(zmq-proxy frontend backend)