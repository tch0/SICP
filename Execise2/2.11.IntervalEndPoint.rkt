#lang sicp

; abstraction of interval
(define (make-interval a b)
    (if (> a b)
        (cons b a)
        (cons a b))
)
(define (lower-bound x) (car x))
(define (upper-bound x) (cdr x))

; operations of interval
(define (add-interval x y)
    (make-interval (+ (lower-bound x) (lower-bound y))
                   (+ (upper-bound x) (upper-bound y))
    )
)

; First of all, Ben is mean.
; discuss by cases of endpoint
; cases:
;   x     y    
; lx ux ly uy  min    max
; +  +  +  +  lx ly  ux uy
; +  +  -  +  ux ly  ux uy
; +  +  -  -  ux ly  lx uy
; -  +  +  +  lx uy  ux uy
; -  +  -  +  trouble case
; -  +  -  -  ux ly  lx ly
; -  -  +  +  lx uy  ux ly
; -  -  -  +  lx uy  lx ly
; -  -  -  -  ux uy  lx ly
; such a mess, WTF!
; Is Ben truly a programmer?
(define (mul-interval x y)
    (define (+? x) (> x 0))
    (define (-? x) (< x 0))
    (let ((lx (lower-bound x))
          (ux (upper-bound x))
          (ly (lower-bound y))
          (uy (upper-bound y)))
        (cond ((and (+? lx) (+? ux) (+? ly) (+? uy)) (make-interval (* lx ly) (* ux uy)))
              ((and (+? lx) (+? ux) (-? ly) (+? uy)) (make-interval (* ux ly) (* ux uy)))
              ((and (+? lx) (+? ux) (-? ly) (-? uy)) (make-interval (* ux ly) (* lx uy)))
              ((and (-? lx) (+? ux) (+? ly) (+? uy)) (make-interval (* lx uy) (* ux uy)))
              ((and (-? lx) (+? ux) (-? ly) (-? uy)) (make-interval (* ux ly) (* lx ly)))
              ((and (-? lx) (-? ux) (+? ly) (+? uy)) (make-interval (* lx uy) (* ux ly)))
              ((and (-? lx) (-? ux) (-? ly) (+? uy)) (make-interval (* lx uy) (* lx ly)))
              ((and (-? lx) (-? ux) (-? ly) (-? uy)) (make-interval (* ux uy) (* lx ly)))
              ; the trouble case
              ((and (-? lx) (+? ux) (-? ly) (+? uy))
               (let ((p1 (* lx ly))
                     (p2 (* lx uy))
                     (p3 (* ux ly))
                     (p4 (* ux uy)))
                    (make-interval (min p1 p2 p3 p4) (max p1 p2 p3 p4))
               ))
        )
    )
)

; test
(mul-interval (make-interval -1 1) (make-interval -5 5))
(mul-interval (make-interval 1 2) (make-interval 3 4))
(mul-interval (make-interval 1 2) (make-interval -1 2))
(mul-interval (make-interval 1 2) (make-interval -2 -1))
(mul-interval (make-interval -1 2) (make-interval 1 2))
(mul-interval (make-interval -1 2) (make-interval -2 -1))
(mul-interval (make-interval -2 -1) (make-interval 1 2))
(mul-interval (make-interval -2 -1) (make-interval -1 2))
(mul-interval (make-interval -2 -1) (make-interval -2 -1))