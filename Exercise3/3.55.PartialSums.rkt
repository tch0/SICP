#lang sicp

; auxiliary procedures
(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))
(define (stream-map proc . argstreams)
    (if (null? (car argstreams))
        the-empty-stream
        (cons-stream (apply proc (map stream-car argstreams))
                     (apply stream-map (cons proc (map stream-cdr argstreams))))
    )
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
; integers
(define (integers-starting-from n)
    (cons-stream n (integers-starting-from (+ n 1)))
)
(define integers (integers-starting-from 1))

; Ex 3.55
(define (partial-sums stream)
    (cons-stream (stream-car stream)
                 (stream-map + (stream-cdr stream) (partial-sums stream)))
)
; test
(display-stream-items (partial-sums integers) 10)