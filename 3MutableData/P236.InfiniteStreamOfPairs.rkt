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
; display specific number items of stream
(define (display-stream-items s num end)
    (cond ((<= num 0) (display "===== end of display-stream-items. =====")
                      (newline))
          ((stream-null? s) (display-stream-items s 0 end))
          (else (display (stream-car s))
                (display end)
                (display-stream-items (stream-cdr s) (- num 1) end))
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
; ===============================================================================

; infinite stream of pairs
; given two infinite stream, generate Cartesian Product (stream of pair streams)
; Part1         Part2
; (S0,T0) |(S0,T1) (S0,T2),...
; ---------------------------------
;         |(S1,T1) (S1,T2),...
;         |        (S2,T2),...      <-- Part3
;         |                ...
(define (pairs s t)
    (cons-stream (list (stream-car s) (stream-car t)) ; Part1
                 (interleave (stream-map (lambda (x) (list (stream-car s) x)) (stream-cdr t)) ; Part2
                             (pairs (stream-cdr s) (stream-cdr t)) ; Part3
                 )
    )
)

; in order to combine multiple infinite streams, we need to define a combination order.
(define (interleave s1 s2)
    (if (stream-null? s1)
        s2
        (cons-stream (stream-car s1)
                     (interleave s2 (stream-cdr s1)))
    )
)

; test
; integers
(define (integers-starting-from n)
    (cons-stream n (integers-starting-from (+ n 1)))
)
(define integers (integers-starting-from 1))
(display-stream-items (pairs integers integers) 198 "\n")