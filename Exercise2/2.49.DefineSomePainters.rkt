#lang sicp
(#%require sicp-pict)

; define specific painters by using built-in procedures

; coordinate :
;    ^ y
;   1|-------
;    |      |
;    |      |
; ---|-------------> x
;   O|      1

; four corners
(define bl (make-vect 0 0))
(define br (make-vect 1 0))
(define tl (make-vect 0 1))
(define tr (make-vect 1 1))

; a) draw the rectangle box
; draw the box
(define box-painter
    (segments->painter (list (make-segment bl br)
                             (make-segment br tr)
                             (make-segment tr tl)
                             (make-segment tl tr))
    )
)

; b) draw a X
(define cross-painter
    (segments->painter (list (make-segment bl tr)
                             (make-segment tl br))
    )
)

; c) draw a rhombus
; mid points
(define (midpoint va vb) (vector-scale 0.5 (vector-add va vb)))
(define midl (midpoint tl bl))
(define midr (midpoint tr br))
(define midt (midpoint tl tr))
(define midb (midpoint bl br))

(define rhombus-painter
    (segments->painter (list (make-segment midl midt)
                             (make-segment midt midr)
                             (make-segment midr midb)
                             (make-segment midb midl))
    )
)

; d) draw a wave in previous example
; I admit I cheated, the answer is from SophiaG in  http://community.schemewiki.org/?sicp-ex-2.49
; the last one is a tedious work.
(define wave-painter 
    (segments->painter  (list 
                        (make-segment (make-vect .25 0) (make-vect .35 .5)) 
                        (make-segment (make-vect .35 .5) (make-vect .3 .6)) 
                        (make-segment (make-vect .3 .6) (make-vect .15 .4)) 
                        (make-segment (make-vect .15 .4) (make-vect 0 .65)) 
                        (make-segment (make-vect 0 .65) (make-vect 0 .85)) 
                        (make-segment (make-vect 0 .85) (make-vect .15 .6)) 
                        (make-segment (make-vect .15 .6) (make-vect .3 .65)) 
                        (make-segment (make-vect .3 .65) (make-vect .4 .65)) 
                        (make-segment (make-vect .4 .65) (make-vect .35 .85)) 
                        (make-segment (make-vect .35 .85) (make-vect .4 1)) 
                        (make-segment (make-vect .4 1) (make-vect .6 1)) 
                        (make-segment (make-vect .6 1) (make-vect .65 .85)) 
                        (make-segment (make-vect .65 .85) (make-vect .6 .65)) 
                        (make-segment (make-vect .6 .65) (make-vect .75 .65)) 
                        (make-segment (make-vect .75 .65) (make-vect 1 .35)) 
                        (make-segment (make-vect 1 .35) (make-vect 1 .15)) 
                        (make-segment (make-vect 1 .15) (make-vect .6 .45)) 
                        (make-segment (make-vect .6 .45) (make-vect .75 0)) 
                        (make-segment (make-vect .75 0) (make-vect .6 0)) 
                        (make-segment (make-vect .6 0) (make-vect .5 .3)) 
                        (make-segment (make-vect .5 .3) (make-vect .4 0)) 
                        (make-segment (make-vect .4 0) (make-vect .25 0)) 
                        ))
)

; test
(paint box-painter)
(paint cross-painter)
(paint rhombus-painter)
(paint wave-painter)



; having fun, draw square limit of wave
; ===============================================================================
; square-limit from 2DataAbstraction/P89.PictureLanguageExample.rkt
(define (flipped-pairs painter)
    (let ((painter2 (beside painter (flip-vert painter))))
        (below painter2 painter2)
    )
)

; ______________________________
; |             |  right-split |
; |             |      n-1     |
; |  identity   |--------------|
; |             |  right-split |
; |             |      n-1     |
; |_____________|______________|
(define (right-split painter n)
    (if (= n 0)
        painter
        (let ((smaller (right-split painter (- n 1))))
            (beside painter (below smaller smaller))
        )
    )
)

; like right-split, but exchange beside and below
(define (up-split painter n)
    (if (= n 0)
        painter
        (let ((smaller (up-split painter (- n 1))))
            (below painter (beside smaller smaller))
        )
    )
)

; quarter of the final paint
(define (corner-split painter n)
    (if (= n 0)
        painter
        (let ((up (up-split painter (- n 1)))
              (right (right-split painter (- n 1))))
            (let ((top-left (beside up up))
                  (bottom-right (below right right))
                  (corner (corner-split painter (- n 1))))
                (beside (below painter top-left)
                        (below bottom-right corner))
            )
        )
    )
)

; the example
; see the painting <Square Limit> of artist M.C.Escher: https://www.wikiart.org/en/m-c-escher/square-limit
(define (square-limit painter n)
    (let ((quarter (corner-split painter n)))
        (let ((half (beside (flip-horiz quarter) quarter)))
            (below (flip-vert half) half)
        )
    )
)
; ===============================================================================

; square limit of wave
(paint (square-limit wave-painter 10))