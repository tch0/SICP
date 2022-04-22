; self-evaluating values
10
-5
"hello"

; variable
true
false
(define a 10)
a

; quotation
'helloworld
'(1 2 3)

; assignment
(set! a 100)
a

; definition
(define (square x) (* x x))
(square 100)
;inner definition
(define (hello)
    (define (world) 'nice)
    (world)
)
(hello)

; if
(if (> a 10)
    'a>10
    'a<=10
)

; lambda
(lambda (x) (* x (square x)))

; begin
(begin
    (set! a 10)
    a
) ; 10

; cond
(cond ((< a 10) 'a<10)
      ((> a 10) 'a>10)
      (else 'a=10)
) ; a=10
; => in cond, 1 support, 2 not support 
; (cond (true => (lambda (x) 99)) (else false)) ; 99

; let
(let ((x 1) (y 2)) (+ x y)) ; 3
; let*
(let* ((x 1) (y (+ x 1))) (+ x y)) ; 3
; named let
(let factorial ((n 10))
    (if (= n 1)
        1
        (* n (factorial (- n 1)))
    )
) ; 3628800
; letrec
(letrec ((even? (lambda (x) (if (= x 0) true (odd? (- x 1)))))
         (odd? (lambda (x) (if (= x 0) false (even? (- x 1))))))
    (even? 10)
) ; #t

; iterations
(set! a 10)
(define product 1)
(while (> a 0) (set! product (* a product)) (set! a (- a 1)))
product ; 3628800

; application
; of primitive procedures
(car (cons 1 2))
(>= 100 10)
; of lambda
((lambda () (* 100 10)))