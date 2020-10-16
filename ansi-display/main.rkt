#lang racket

(define color/c (one-of/c 'black 'red 'green 'yellow 'blue 'cyan 'white 'default))
(define brightness/c (one-of/c 'bright 'normal))

(provide
 (contract-out
  [ansi-display (-> (or/c color/c brightness/c 'reset string?) ... any)]))

(define (ansi-display . program)
  (define dirty #t)
  (define color 'default)
  (define brightness 'normal)

  (let loop ([program program])
    (match program
      [(list)
       (void)]

      [(cons 'reset '())
       (loop (list 'reset ""))]

      [(cons exp program)
       (match exp
         [(? color? c)
          (set! dirty #t)
          (set! color c)]
         [(? brightness? b)
          (set! dirty #t)
          (set! brightness b)]
         ['reset
          (set! dirty #t)
          (set! color 'default)
          (set! brightness 'normal)]
         [(? string?)
          (when dirty
            (display "\e[")
            (display (brightness->string brightness))
            (display (color->string color))
            (display "m")
            (set! dirty #f))
          (display exp)])
       (loop program)])))

(define (brightness->string b)
  (case b
    [(normal) "3"]
    [(bright) "9"]))

(define (color->string color)
  (case color
    [(black) "0"]
    [(red) "1"]
    [(green) "2"]
    [(yellow) "3"]
    [(blue) "4"]
    [(cyan) "5"]
    [(white) "7"]
    [(default) "9"]))

(define (color? c)
  (memq c '(red green blue yellow white black default)))

(define (brightness? b)
  (memq b '(normal bright)))

(module+ test
  (require rackunit)

  (check-equal? (with-output-to-string
                  (lambda ()
                    (ansi-display 'green "INFO"
                                  'reset " "
                                  "hello"
                                  'bright 'black " at main"
                                  'reset)))
                "\e[32mINFO\e[39m hello\e[90m at main\e[39m"))
