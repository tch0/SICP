#lang sicp

; car and cdr for stream
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

; test
(define result
    (stream-map +
                (cons-stream 1 (cons-stream 2 nil))
                (cons-stream 2 (cons-stream 3 nil)))
)

(stream-car result)
(stream-cdr result)
(stream-cdr (stream-cdr result))