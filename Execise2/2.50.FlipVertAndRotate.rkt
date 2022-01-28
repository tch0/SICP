#lang sicp
(#%require sicp-pict)

; flip-horiz
;               ^ y
;     __________|
;     |         |
;     |         |
;     |         |
; x <_|_________|_O
;               |
; O = (1.0, 0.0), x = (-1.0, 0), y = (1.0, 0.0)
(define (flip-horiz painter)
    (transform-painter painter
                       (make-vect 1.0 0.0)
                       (make-vect 0.0 0.0)
                       (make-vect 1.0 1.0))
)

; rotate180
; 
; x <____________ O
;     |         |
;     |         |
;     |         |
;     |_________|
;               | y
; O = (1.0, 1.0), x = (-1.0, 0.0), y = (0.0, -1.0)
(define (rotate180 painter)
    (transform-painter painter
                       (make-vect 1.0 1.0)
                       (make-vect 0.0 1.0)
                       (make-vect 1.0 0.0))
)


; rotate270
; 
; O____________> y
; |         |
; |         |
; |         |
; |_________|
; | 
; x
; O = (0.0, 1.0), x = (0.0, -1.0), y = (1.0, 0)
(define (rotate270 painter)
    (transform-painter painter
                       (make-vect 0.0 1.0)
                       (make-vect 0.0 0.0)
                       (make-vect 1.0 1.0))
)

; test
(paint einstein)
(paint (flip-horiz einstein))
(paint (rotate180 einstein))
(paint (rotate270 einstein))

; built-in
(paint (rotate90 einstein))