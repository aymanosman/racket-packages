#lang racket

(require zeromq)

(define receiver (zmq-socket 'pull #:connect "tcp://localhost:5557"))
(define sender (zmq-socket 'push #:connect "tcp://localhost:5558"))
(define controller (zmq-socket 'sub #:connect "tcp://localhost:5559"))
(zmq-subscribe controller "")

;; HELPERS

(define (message-evt socket)
  (wrap-evt socket
            (lambda (msg)
              (list socket msg))))

;; Process message from receiver and controller
(let loop ()

  (match-define (list socket (zmq-message (list string))) (sync (message-evt receiver)
                                                                (message-evt controller)))

  (cond
    [(eq? receiver socket)
     (printf "~a." string)     ;; Show progress
     (flush-output)
     (define msecs (/ (string->number (bytes->string/utf-8 string)) 1000))
     (sleep msecs)             ;; Do the work
     (zmq-send sender string)  ;; Send results to sink
     (loop)]
    [(eq? controller socket)
     (void)]))
