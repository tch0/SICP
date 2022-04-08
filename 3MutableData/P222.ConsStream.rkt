#lang sicp

; existing stream procedures (from Racket Language): cons-stream, the-empty-stream, stream-null?
; [Those procedures should can be implemented by using Scheme primitive procedures only.]
; cons-stream must be a special form, (cons-stream a b), b should not be evaluated.
; cdr of cons-stream is a promise/delay object

; car and cdr for stream
(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))

; basic procedures for stream similar to list
(define (stream-ref s n)
    (if (= n 0)
        (stream-car s)
        (stream-ref (stream-cdr s) (- n 1))
    )
)
(define (stream-map proc s)
    (if (stream-null? s)
        the-empty-stream
        (cons-stream (proc (stream-car s))
                     (stream-map proc (stream-cdr s)))
    )
)
(define (stream-for-each proc s)
    (if (stream-null? s)
        'done
        (begin (proc (stream-car s))
               (stream-for-each proc (stream-cdr s))
        )
    )
)
(define (display-stream s)
    (define (display-line x)
        (newline)
        (display x)
    )
    (stream-for-each display-line s)
)

; interval in stream form
(define (stream-enumerate-interval low high)
    (if (> low high)
        the-empty-stream
        (cons-stream low (stream-enumerate-interval (+ low 1) high))
    )
)
; filter of stream
(define (stream-filter predicate stream)
    (cond ((stream-null? stream) the-empty-stream)
          ((predicate (stream-car stream)) (cons-stream (stream-car stream)
                                                        (stream-filter predicate (stream-cdr stream))))
          (else (stream-filter predicate (stream-cdr stream)))
    )
)

; prime test from Exercise1/1.22.TimedPrimeTest.rkt
(define (prime? n)
    (define (find-divisor n test-divisor)
        (define (square x) (* x x))
        (define (divides? a b) (= (remainder b a) 0)) ; b % a
        (cond ((> (square test-divisor) n) n)
              ((divides? test-divisor n) test-divisor)
              (else (find-divisor n (+ test-divisor 1)))
        )
    )
    ; find smallest divisor of a integer
    (define (smallest-divisor n)
        (find-divisor n 2)
    )
    (= n (smallest-divisor n))
)

; test
; the second prime number between 10000 to 1000000
(stream-car (stream-cdr (stream-filter prime? (stream-enumerate-interval 10000 1000000))))