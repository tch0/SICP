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

; Ex 3.53
(define (mul-streams s1 s2) (stream-map * s1 s2))
; integers
(define (integers-starting-from n)
    (cons-stream n (integers-starting-from (+ n 1)))
)
(define integers (integers-starting-from 1))
(define factorials (cons-stream 1 (mul-streams (integers-starting-from 2) factorials)))

; test
(display-stream-items factorials 10)