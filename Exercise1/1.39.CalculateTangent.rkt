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

; infinite continued fraction representation of tan(x)
; N_i = x, i = 1
;       -x^2, else
; D_i = 2*i - 1
; x uses radius as unit

(define (tan-cf x k)
    (define (N i)
        (if (= i 1)
            x
            (- (* x x)))
    )
    (define (D i) (- (* 2 i) 1))
    (cont-frac N D k)
)

(define PI 3.14159265358979323846)

; test
(tan-cf (/ PI 4) 5)
(tan-cf (/ PI 4) 20)
(tan-cf (/ PI 3) 5)
(tan-cf (/ PI 3) 20) ; precision when k=20 is enough
(tan-cf (/ PI 3) 100)
(tan-cf (/ PI 6) 10)
