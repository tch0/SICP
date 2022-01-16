#lang sicp

; =====================================================================
; find fixed point
(define tolerance 0.00001)
(define (fixed-point f first-guess)
    (define (close-enough? v1 v2)
        (< (abs (- v1 v2)) tolerance)
    )
    (define (try guess)
        (let ((next (f guess)))
            (if (close-enough? guess next)
                next
                (try next)
            )
        )
    )
    (try first-guess)
)
; =====================================================================
; apply function repeatedly
(define (repeated f n)
    (if (= n 1)
        f
        (lambda (x)
            (let ((fs (repeated f (- n 1))))
                (fs (f x))
            )
        )
    )
)
; =====================================================================
; average damping
(define (average x y) (/ (+ x y) 2.0))
(define (average-damp f)
    (lambda (x)
        (average (f x) x)
    )
)
; =====================================================================


; =====================================================================
; do many times of average damping for convergence of y^n = x

; example: root of y^4 = x, do 2 times average damping
(define (4th-power x) (* x x x x))
(define (4th-root x)
    (fixed-point ((repeated average-damp 2) (lambda (y) (/ x (* y y y))))
                 1.0)
)

; test
(4th-root 10)
(4th-root (4th-power 41685815.13489))


; general n-th root avaerage damping
(define (damped-nth-root n damp-times)
    (lambda (x)
        (fixed-point ((repeated average-damp damp-times) (lambda (y) (/ x (expt y (- n 1)))))
                     1.0)
    )
)

; find root of y^n = x
; 经过充分测试，y^n = x需要logn向下取整次平均阻尼就能收敛，不能收敛时会进入无限循环。
((damped-nth-root 4 2) (4th-power 10.5))

; ceiling(logn), base = 2
; the library (log x) is natural log
(define (lg n)
    (cond ((> (/ n 2) 1) (+ 1 (lg (/ n 2))))
          ((< (/ n 2) 1) 0)
          (else 1)
    )
)

(define (nth-root n)
    (damped-nth-root n (lg n))
)

((nth-root 4) (expt 10.5 4))
((nth-root 10) (expt 12380.2134 10))
((nth-root 30) (expt 4635.4534343 30))
