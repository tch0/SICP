#lang sicp

; ========================================================================
; infinite continued fraction
(define (cont-frac n d k)
    (define (cont-frac-iter i result)
        (if (= i 0)
            result
            (cont-frac-iter (dec i) (/ (n i) (+ (d i) result)))
        )
    )
    (cont-frac-iter k 0)
)
; ========================================================================

; calculate e by using infinite continued fraction
; N_i is always 1
; D_i is 1,2,1,1,4,1,1,6,1,1,8,...
; result is e-2
; D_i = 2(i+1)/3, if (i-2)%3 == 0
;       1, else
(define (N i) 1.0)
(define (D i)
    (if (= (remainder (- i 2) 3) 0)
        (/ (* 2 (+ i 1)) 3)
        1
    )
)

; calculate e
; 2.7182818284590455
(+ 2 (cont-frac N D 100))