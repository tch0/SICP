#lang sicp
(#%require sicp-pict)

; a)
; wave from Execise2/2.49.DefineSomePainters.rkt
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
                        (make-segment (make-vect 0.44 0.7) (make-vect 0.51 0.7)) 
                        ))
)

; ===============================================================================
; square-limit from 2DataAbstraction/P91.HighOrderPainterOperations.rkt

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

; b)
; quarter of the final paint
(define (corner-split painter n)
    (if (= n 0)
        painter
        (beside (below painter (up-split painter (- n 1)))
                (below (right-split painter (- n 1)) (corner-split painter (- n 1))))
    )
)

; a high order operation that manipulate pics in four corners
(define (square-of-four tl tr bl br)
    (lambda (painter)
        ;                   left        right
        (below (beside (bl painter) (br painter)) ; down
               (beside (tl painter) (tr painter))) ; up
    )
)

; c)
(define (square-limit painter n)
    ((square-of-four flip-vert rotate180 identity flip-horiz) (corner-split painter n))
)
; ===============================================================================

; test
; a)
(paint wave-painter)
; b)
(paint (corner-split wave-painter 10))
; c)
(paint (square-limit wave-painter 10))