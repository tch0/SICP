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

; Ex 3.64
; find specific value in infinite stream with given tolerance
(define (stream-limit infinite-stream tolerance)
    (define (good-enough? a b)
        (< (abs (- a b)) tolerance)
    )
    (let ((a (stream-ref infinite-stream 0))
          (b (stream-ref infinite-stream 1)))
        (if (good-enough? a b)
            a
            (stream-limit (stream-cdr infinite-stream) tolerance)
        )
    )
)

(define (sqrt x tolerance)
    (stream-limit (sqrt-stream x) tolerance)
)

(sqrt 2 0.1)
(sqrt 2 0.001)
(sqrt 2 0.000001)