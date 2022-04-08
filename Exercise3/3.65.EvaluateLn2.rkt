#lang sicp

; auxiliary procedures for stream
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
; scale a stream
(define (scale-stream stream factor)
    (stream-map (lambda (x) (* x factor)) stream)
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

; partial-sums from Exercise3/3.55.PartialSums.rkt
(define (partial-sums stream)
    (cons-stream (stream-car stream)
                 (stream-map + (stream-cdr stream) (partial-sums stream)))
)

; Ex 3.65
; evaluate ln2 = 1 - 1/2 + 1/3 - 1/4 + ...
(define (ln2-summands n)
    (cons-stream (/ 1.0 n)
                 (stream-map - (ln2-summands (+ n 1))))
)
(define ln2-stream (partial-sums (ln2-summands 1)))

; Euler Accelerator
(define (square x) (* x x))
(define (enler-transform s)
    (let ((s0 (stream-ref s 0)) ; S(n-1)
          (s1 (stream-ref s 1)) ; S(n)
          (s2 (stream-ref s 2))); S(n+1)
        (cons-stream (- s2 (/ (square (- s2 s1))
                              (+ s0 (* -2 s1) s2)))
                      (enler-transform (stream-cdr s))
        )
    )
)

; accelerated sequence of accelerated sequence
(define (make-tableau transform s)
    (cons-stream s
                 (make-tableau transform (transform s)))
)
(define (accelerated-sequence transform s)
    (stream-map stream-car (make-tableau transform s))
)

; test
(display-stream-items ln2-stream 10 "\n")
(display-stream-items (enler-transform ln2-stream) 10 "\n")
(display-stream-items (accelerated-sequence enler-transform ln2-stream) 10 "\n")
(log 2)