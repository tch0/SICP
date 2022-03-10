#lang sicp

; calculate infinite continued fraction
; 无穷连分式
; f = N1 / (D1 + (N2 / (D2 + N3 / D3 + ...)))
; when Ni = Di = 1, f = (sqrt(5) - 1) / 2

; use finite continued fraction to approach the final result
; n and d are function get Ni/Di, k is the last index
; recursion
(define (cont-frac n d k)
    (define (cont-frac-inner i)
        (if (= i k)
            (/ (n i) (d i))
            (/ (n i) (+ (d i) (cont-frac-inner (inc i))))
        )
    )
    (cont-frac-inner 1)
)

; iteration
; calculate from k to 1
(define (cont-frac2 n d k)
    (define (cont-frac-iter i result)
        (if (= i 0)
            result
            (cont-frac-iter (dec i) (/ (n i) (+ (d i) result)))
        )
    )
    (cont-frac-iter k 0)
)

; a) b)
(define (good-enough? precision a b)
    (if (< (abs (- a b)) precision)
        #t
        #f)
)
; get how many steps should calculate to get close enough to 1/phi: (1+sqrt(5)) / 2
(define (get-calculate-steps precision cont-frac-func)
    (define phi1 (/ (- (sqrt 5) 1) 2)) ; 1 / phi
    (define (close-enough-to-phi1? x) (good-enough? precision x phi1))
    (define phi-n (lambda (x) 1.0))
    (define phi-d (lambda (x) 1.0))
    (define (inner-iter k-count)
        (display k-count)
        (display " : ")
        (display (cont-frac-func phi-n phi-d k-count))
        (newline)
        (let ((result (cont-frac-func phi-n phi-d k-count)))
            (if (close-enough-to-phi1? result)
                k-count
                (inner-iter (inc k-count))
            )
        )
    )
    (inner-iter 1)
)


; when Ni = Di = 1, f = (sqrt(5) - 1) / 2
(cont-frac (lambda (x) 1.0) (lambda (x) 1.0) 100)
(cont-frac2 (lambda (x) 1.0) (lambda (x) 1.0) 100)
(define phi1 (/ (- (sqrt 5) 1) 2)) ; 1 / phi
phi1
(newline)

; test
(get-calculate-steps 0.0001 cont-frac)
(get-calculate-steps 0.0001 cont-frac2)
