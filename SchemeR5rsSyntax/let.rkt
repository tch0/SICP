#lang sicp

; let: bind at same time
(let ((x 2) (y 3))
  (* x y)) ; ==> 6

; let*: bind sequentially
(let ((x 2) (y 3))
  (let* ((x 7)
         (z (+ x y))) ; x is newly set 7, so z is 10, if use let z will be 5
    (* z x))) ; ===> 70

; letrec: allow mutal recrusion
(letrec ((even? (lambda (n) (if (zero? n) #t (odd? (- n 1)))))
         (odd? (lambda (n) (if (zero? n) #f (even? (- n 1)))))
        )
        (even? 88) ; #t
)