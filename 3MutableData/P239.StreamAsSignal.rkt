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

; simulate Feedback Loop Signal Processing System
; input stream: x = (xi), initial value: C, Incremental: dt
; Si = C + Sum(j=1 to i)Xj*dt
(define (integral integrand initial-value dt)
    (define int
        (cons-stream initial-value
                     (add-streams (scale-stream integrand dt) int)
        )
    )
    int
)


; Ex 3.73
; simulate RC circuit
; + i -->--R----C---- -(v)
; v = v0 + 1/C(Integral(0 to i) i*dt) + R*i
(define (RC r c dt)
    (define (proc i v0)
        (add-streams (scale-stream (integral i v0 dt) (/ 1 c))
                     (scale-stream i r))
    )
    proc
)
; test
(define RC1 (RC 5 1 0.5))