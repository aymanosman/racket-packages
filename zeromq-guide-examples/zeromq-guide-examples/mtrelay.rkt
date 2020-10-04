#lang racket

(require zeromq)

(define (step1)
  ;; Connect to step2 and tell it we're ready
  (define xmitter (zmq-socket 'pair #:connect "inproc://step2"))
  (printf "Step 1 ready, signaling step 2\n")
  (zmq-send xmitter "READY")
  (zmq-close xmitter))

(define (step2)
  ;; Bind inproc socket before starting step1
  (define receiver (zmq-socket 'pair #:bind "inproc://step2"))
  (thread step1)

  ;; Wait for signal and pass it on
  (zmq-recv receiver)
  (zmq-close receiver)

  ;; Connect to step3 and tell it we're ready
  (define xmitter (zmq-socket 'pair #:connect "inproc://step3"))
  (printf "Step 2 ready, signaling step 3\n")
  (zmq-send xmitter "READY")
  (zmq-close xmitter))

(define receiver (zmq-socket 'pair #:bind "inproc://step3"))
(void (thread step2))

;; Wait for signal
(void (zmq-recv receiver))

(printf "Test successful!\n")