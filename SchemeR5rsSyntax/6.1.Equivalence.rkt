#lang sicp


; eqv?
; #t
(eqv? "" "")                     ; ===>  unspecified
(eqv? '#() '#())                 ; ===>  unspecified

; #f
(eqv? (lambda (x) x)
      (lambda (x) x))            ; ===>  unspecified
(eqv? (lambda (x) x)
      (lambda (y) y))            ; ===>  unspecified

; procedures that have their own local states
(define (gen-counter)
    (let ((n 0))
        (lambda ()
            (set! n (+ n 1))
            n
        )
    )
)
(let ((g (gen-counter)))
    (eqv? g g)
) ; ==> #t
(eqv? (gen-counter) (gen-counter)) ; ==> #f

; if local state does not affect the final result
(define (gen-loser)
    (let ((n 0))
        (lambda ()
            (set! n (+ n 1))
            100
        )
    )
)
(let ((g (gen-loser))) (eqv? g g)) ; ==> #t
(eqv? (gen-loser) (gen-loser)) ; ==> implement-defined


; equal?
(equal? (cons 1 2) (cons 1 2)) ; #t