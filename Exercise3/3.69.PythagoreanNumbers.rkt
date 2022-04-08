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
; in order to combine multiple infinite streams, we need to define a combination order.
(define (interleave s1 s2)
    (if (stream-null? s1)
        s2
        (cons-stream (stream-car s1)
                     (interleave s2 (stream-cdr s1)))
    )
)
; pairs of two streams
(define (pairs s t)
    (cons-stream (list (stream-car s) (stream-car t)) ; Part1
                 (interleave (stream-map (lambda (x) (list (stream-car s) x)) (stream-cdr t)) ; part2
                             (pairs (stream-cdr s) t) ; part3
                 )
    )
)
; integers
(define (integers-starting-from n)
    (cons-stream n (integers-starting-from (+ n 1)))
)
(define integers (integers-starting-from 1))
; ===============================================================================

(define (triples s t u)
    (cons-stream (list (stream-car s) (stream-car t) (stream-car u))
                 (interleave (stream-map (lambda (x) (cons (stream-car s) x))
                                                     (stream-cdr (pairs t u))) ; repeat calculation of (pairs t u)
                             (triples (stream-cdr s)
                                      (stream-cdr t)
                                      (stream-cdr u))
                 )
    )
)

(define (pythagorean-numbers)
    (define (square x) (* x x))
    (define numbers (triples integers integers integers))
    (stream-filter (lambda (x) (= (square (caddr x)) (+ (square (cadr x)) (square (car x)))))
                   numbers
    )
)

; test
(display-stream-items (pythagorean-numbers) 5 "\n")