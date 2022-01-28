#lang sicp
(#%require sicp-pict)

; all built in transform of painter (high order painters):
;   transform-painter
;   flip-horiz
;   flip-vert
;   rotate90, rotate180, rotate270
;   beside
;   below
;   above3
;   superpose

(define (transfrom-painter painter origin corner1 corner2)
    (lambda (frame)
        (let ((m (frame-coord-map frame))) ; m is a function that vert? -> vert?
            (let ((new-origin (m origin)))
                (painter (make-frame new-origin
                                     (vector-sub (m corner1) new-origin)
                                     (vector-sub (m corner2) new-origin))
                )
            )
        )
    )
)

; use tranfrom-painter define other high order painters
; flip vertically
; O = (0.0, 1.0), x = (1.0, 0.0), y = (0.0, -1.0)
; x,y here is vector, not coordinate, O is coordinate, same below.
; O __________1_> x
;  |          |
;  |          |
;  |          |
; 1|__________|
;  |
;  y
(define (flip-vert painter)
    (transfrom-painter painter
                       (make-vect 0.0 1.0) ; new origin
                       (make-vect 1.0 1.0) ; new end of edge1
                       (make-vect 0.0 0.0) ; new end of edge2
    )
)

; shrink to upper left quarter
; O = (0.5, 0.5) x = (0.5, 0.0), y = (0.0, 0.5)
;       ^ y
;  _____|____
;  |    |    |
;  |____|____|__> x
;  |    O    |
;  |_________|
; 
(define (shrink-to-upper-right painter)
    (transfrom-painter painter
                       (make-vect 0.5 0.5) ; new origin
                       (make-vect 1.0 0.5) ; new end of edge1
                       (make-vect 0.5 1.0) ; new end of edge2
    )
)

; rotate 90 degree counterclockwise
;            ^ x
;    ________|
;    |       |
;    |       |
;  <_|_______|__
;  y         |O
; O = (1.0, 0.0) x = (0.0, 1.0), y = (-1.0, 0.0)
(define (rotate90 painter)
     (transfrom-painter painter
                       (make-vect 1.0 0.0) ; new origin
                       (make-vect 1.0 1.0) ; new end of edge1
                       (make-vect 0.0 0.0) ; new end of edge2
    )
)

; squash to a parallelogram 
; O = (0.0, 0.0), x = (0.65, 0.35), y = (0.35, 0.65)
(define (squash-inwards painter)
     (transfrom-painter painter
                       (make-vect 0.0 0.0) ; new origin
                       (make-vect 0.65 0.35) ; new end of edge1
                       (make-vect 0.35 0.65) ; new end of edge2
    )
)

; multiple painter combination and transformation
; (beside left right)
;  ^ y
; 1|______________
;  |      |      |
;  |      |      |
;  |      |      |
;  |______|______|__> x
;  O      0.5       1
; left: O = (0.0, 0.0) x = (0.5, 0.0) y = (0.0, 1.0)
; right: O = (0.5, 0.0) x = (0.5, 0.0) y = (0.0, 1.0)
(define (beside left right)
    (let ((painter-left (transfrom-painter left
                                           (make-vect 0.0 0.0)
                                           (make-vect 0.5 0.0)
                                           (make-vect 0.0 1.0)))
          (painter-right (transfrom-painter right
                                            (make-vect 0.5 0.0)
                                            (make-vect 1.0 0.0)
                                            (make-vect 0.5 1.0))))
        (lambda (frame)
            (painter-left frame)
            (painter-right frame)
        )
    )
)

; test
(paint (flip-vert einstein))
(paint (shrink-to-upper-right einstein))
(paint (rotate90 einstein))
(paint (squash-inwards einstein))
(paint (beside einstein einstein))