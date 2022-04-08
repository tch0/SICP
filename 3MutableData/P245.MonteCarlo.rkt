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

(define random-init 0)
(define (rand-update x)
    (remainder (+ (* 1103515245 x) 12345) #x7FFFFFFF)
)
(define rand
    (let ((x random-init))
        (lambda ()
            (set! x (rand-update x))
            x
        )
    )
)

; random number stream
(define random-numbers
    (cons-stream random-init
                 (stream-map rand-update random-numbers)
    )
)

(define (map-successive-pairs f s)
    (cons-stream (f (stream-car s) (stream-car (stream-cdr s)))
                 (map-successive-pairs f (stream-cdr (stream-cdr s)))
    )
)
; the probability of two ramdom number coprime : 6/PI^2
(define cesaro-stream
    (map-successive-pairs (lambda (r1 r2) (= (gcd r1 r2) 1))
                          random-numbers
    )
)

(define (monte-carlo experiment-stream passed failed)
    (define (next passed failed)
        (cons-stream (/ passed (+ passed failed))
                     (monte-carlo (stream-cdr experiment-stream) passed failed)
        )
    )
    (if (stream-car experiment-stream)
        (next (+ passed 1) failed)
        (next passed (+ failed 1))
    )
)

(define pi (stream-map (lambda (p) (if (= p 0) 0 (sqrt (/ 6 p))))
                       (monte-carlo cesaro-stream 0 0))
)

(display-stream-items pi 100 "\n")