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

; infinite stream

; integers
(define (integers-starting-from n)
    (cons-stream n (integers-starting-from (+ n 1)))
)
(define integers (integers-starting-from 1))

(stream-ref integers 100) ; 101

; other streams that use integers
(define (divisible? x y) (= (remainder x y) 0))
(define no-sevens (stream-filter (lambda (x) (not (divisible? x 7))) integers))
(stream-ref no-sevens 100) ; 117

; fibonacci sequence
(define (fibgen a b)
    (cons-stream a (fibgen b (+ a b)))
)
(define fibs (fibgen 0 1))
(stream-ref fibs 10) ; 55

; the Sieve of Eratosthenes to get primes
(define (Eratosthenes-Seive stream)
    (cons-stream (stream-car stream)
                 (Eratosthenes-Seive (stream-filter (lambda (x) (not (divisible? x (stream-car stream))))
                                                    (stream-cdr stream)))
    )
)

(define primes (Eratosthenes-Seive (integers-starting-from 2)))
; first 100 prime numbers
(display-stream-items primes 100)