#lang racket

(define color/c (one-of/c 'black 'red 'green 'yellow 'blue 'cyan 'white))
(define brightness/c (one-of/c 'bright 'normal))

(provide
 (contract-out [ansi-display (-> (or/c color/c brightness/c 'reset string?) ... any)]))

(define (reset-env! env)
  (hash-set! env 'color 'white)
  (hash-set! env 'brightness 'normal))

(define (ansi-display . program)
  (define env (make-hash))

  (reset-env! env)

  (let loop ([program program])
    (match program
      [(list)
       (void)]

      [(cons exp program)
       (ansi-interpret-exp exp env)
       (loop program)])))

(define (ansi-interpret-exp e env)
  (match e
    [(? color? color)
     (hash-set! env 'color color)]
    [(? brightness? b)
     (hash-set! env 'brightness b)]
    ['reset
     (reset-env! env)]
    [(? string?)
     (apply-env! env)
     (display e)]))

(define (apply-env! env)
  (display "\u001b[")
  (display (case (hash-ref env 'brightness)
             [(normal) "3"]
             [(bright) "9"]))
  (define color (hash-ref env 'color))
  (display (case color
             [(black) "0"]
             [(red) "1"]
             [(green) "2"]
             [(yellow) "3"]
             [(blue) "4"]
             [(cyan) "5"]
             [(white) "7"]))
  (display "m"))

(define (color? c)
  (memq c '(red green blue yellow white black)))

(define (brightness? b)
  (memq b '(normal bright)))
