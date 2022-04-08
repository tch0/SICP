#lang sicp

; auxiliary procedures
(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))
(define (stream-ref s n)
    (if (= n 0)
        (stream-car s)
        (stream-ref (stream-cdr s) (- n 1))
    )
)
(define (stream-map proc . argstreams)
    (if (null? (car argstreams))
        the-empty-stream
        (cons-stream
            (apply proc (map stream-car argstreams))
            (apply stream-map (cons proc (map stream-cdr argstreams)))
        )
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
; display specific number items of stream
(define (display-stream-items s num)
    (cond ((<= num 0) (display "end")
                      (newline))
          ((stream-null? s) (display-stream-items s 0))
          (else (display (stream-car s))
                (display " ")
                (display-stream-items (stream-cdr s) (- num 1)))
    )
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
; =====================================================================================

; define stream recursively
(define ones (cons-stream 1 ones))
(define (add-streams s1 s2)
    (stream-map + s1 s2)
)
; integers
(define integers (cons-stream 1 (add-streams ones integers)))

; fibonacci sequence
(define fibs (cons-stream 0 (cons-stream 1 (add-streams (stream-cdr fibs) fibs))))
(display-stream-items fibs 10) ; first 10 items

; scale a stream
(define (scale-stream stream factor)
    (stream-map (lambda (x) (* x factor)) stream)
)
; exponentiation of 2
(define double (cons-stream 1 (scale-stream double 2)))
(display-stream-items double 10)

; prime numbers
(define (square x) (* x x))
(define (integers-starting-from n) (cons-stream n (integers-starting-from (+ n 1))))
(define (divisible? x y) (= (remainder x y) 0))

; mutual recursive definition
(define primes (cons-stream 2 (stream-filter prime? (integers-starting-from 3))))
(define (prime? n)
    (define (iter ps)
        (cond ((> (square (stream-car ps)) n) true)
              ((divisible? n (stream-car ps)) false)
              (else (iter (stream-cdr ps)))
        )
    )
    (iter primes)
)
; first 100 prime numbers
(display-stream-items primes 100)