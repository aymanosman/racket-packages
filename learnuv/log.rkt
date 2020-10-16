#lang racket

(provide log_info)

(require ansi-display
         (for-syntax racket/list))

(define (log_info-fn #:loc loc fmt . args)

  (match-define (list source line) loc)

  (ansi-display 'green "INFO  "
                'white (apply format fmt args)
                'bright 'black  (format "   (~a:~a)" source line)
                'reset)
  (newline))

(define-syntax (log_info stx)
  (define source (last (explode-path (syntax-source stx))))
  (define line (syntax-line stx))
  (syntax-case stx ()
    [(_ arg* ...)
     #`(log_info-fn #:loc (list #,source #,line) arg* ...)]))
