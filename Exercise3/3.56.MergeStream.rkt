#lang sicp

; auxiliary procedures
(define (stream-car stream) (car stream))
(define (stream-cdr stream) (force (cdr stream)))
(define (stream-map proc . argstreams)
    (if (null? (car argstreams))
        the-empty-stream
        (cons-stream
            (apply proc (map stream-car argstreams))
            (apply stream-map (cons proc (map stream-cdr argstreams)))
        )
    )
)
; scale a stream
(define (scale-stream stream factor)
    (stream-map (lambda (x) (* x factor)) stream)
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

; merge two sorted streams
(define (merge s1 s2)
    (cond ((stream-null? s1) s2)
          ((stream-null? s2) s1)
          (else (let ((s1car (stream-car s1))
                      (s2car (stream-car s2)))
                    (cond ((< s1car s2car) (cons-stream s1car (merge (stream-cdr s1) s2)))
                          ((> s1car s2car) (cons-stream s2car (merge s1 (stream-cdr s2))))
                          (else (cons-stream s1car (merge (stream-cdr s1) (stream-cdr s2))))
                    )
                )
          )
    )
)

; Ex 3.56
; construct target stream through merge
; kinda magic
(define S (cons-stream 1
                      (merge (scale-stream S 2)
                             (merge (scale-stream S 3)
                                    (scale-stream S 5)))
          )
)

(display-stream-items S 100)