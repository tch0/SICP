#lang sicp
(#%require sicp-pict)

; High order operations

; corner-split from 2DataAbstraction/P89.PictureLanguageExample.rkt
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

; a high order operation that manipulate pics in four corners
(define (square-of-four tl tr bl br)
    (lambda (painter)
        ;                   left        right
        (below (beside (bl painter) (br painter)) ; down
               (beside (tl painter) (tr painter))) ; up
    )
)

(define (flipped-pairs painter)
    ((square-of-four identity flip-vert identity flip-vert) painter)
)

(define (square-limit painter n)
    ((square-of-four flip-horiz identity rotate180 flip-vert) (corner-split painter n))
)

; Ex 2.45
; right-split and up-split

; high order function
(define (split outter inner)
    (define (split-imp painter n)
        (if (= n 0)
            painter
            (let ((smaller (split-imp painter (- n 1))))
                (outter painter (inner smaller smaller)))
        )
    )
    split-imp
)

; define right-split and up-split
(define right-split (split beside below))
(define up-split (split below beside))

; test
(paint (corner-split einstein 10))
(paint (square-limit einstein 10))