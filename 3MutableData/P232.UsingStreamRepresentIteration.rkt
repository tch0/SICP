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

; newton iteration
(define (sqrt-stream x)
    (define guesses
        (cons-stream 1.0 (stream-map (lambda (guess) (sqrt-imporve guess x))
                                     guesses))
    )
    guesses
)
(define (average x y) (/ (+ x y) 2.0))
(define (sqrt-imporve guess x) (average guess (/ x guess)))

(display-stream-items (sqrt-stream 2) 10 "\n")


; evaluate PI thourgh infinite series
; partial-sums from Exercise3/3.55.PartialSums.rkt
(define (partial-sums stream)
    (cons-stream (stream-car stream)
                 (stream-map + (stream-cdr stream) (partial-sums stream)))
)

; PI/4 = 1 - 1/3 + 1/5 - 1/7 + ...
(define (pi-summands n)
    (cons-stream (/ 1.0 n)
                 (stream-map - (pi-summands (+ n 2)))
    )
)
(define pi-stream (scale-stream (partial-sums (pi-summands 1)) 4))
(display-stream-items pi-stream 10 "\n")


; Euler Accelerator: convergence accelerated sequence for staggered series
; S(n+1) - (S(n+1) - S(n))^2/(S(n-1)-2S(n)+S(n+1))
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
(display-stream-items (enler-transform pi-stream) 10 "\n")

; accelerated sequence of accelerated sequence
; stream of stream
(define (make-tableau transform s)
    (cons-stream s
                 (make-tableau transform (transform s)))
)
(define (accelerated-sequence transform s)
    (stream-map stream-car (make-tableau transform s))
)
(display-stream-items (accelerated-sequence enler-transform pi-stream) 10 "\n")
; the result is exciting