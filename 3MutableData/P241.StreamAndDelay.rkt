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
; integers
(define (integers-starting-from n)
    (cons-stream n (integers-starting-from (+ n 1)))
)
(define integers (integers-starting-from 1))
; ===============================================================================

(define (add-streams s1 s2)
    (stream-map + s1 s2)
)
(define (scale-stream s scale)
    (stream-map (lambda (x) (* x scale)) s)
)


; use force and delay explicitly
(define (integral delayed-integrand initial-value dt)
    (define int
        (cons-stream initial-value
                     (let ((integrand (force delayed-integrand)))
                        (add-streams (scale-stream integrand dt)
                                     int
                        )
                     )
        )
    )
    int
)
(define (solve f y0 dt)
    ; define dy as procedure, because we can not use a variable before it's definition
    (define y (integral (delay (dy)) y0 dt))
    (define (dy) (stream-map f y))
    y
)
; calculate dy/dt = y
(stream-ref (solve (lambda (y) y) 1 0.001) 1000)