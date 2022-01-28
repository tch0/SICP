#lang sicp
(#%require sicp-pict)

; 2.2.4 Example: A graphical language
; See https://docs.racket-lang.org/sicp-manual/SICP_Picture_Language.html
; See the picture output on DrRacket.

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
; see the painting of M.C.Escher: https://www.wikiart.org/en/m-c-escher/square-limit
(define (square-limit painter n)
    (let ((quarter (corner-split painter n)))
        (let ((half (beside (flip-horiz quarter) quarter)))
            (below (flip-vert half) half)
        )
    )
)

; test
(paint (flipped-pairs einstein))
(paint (right-split einstein 10))
(paint (corner-split einstein 10))
(paint (square-limit einstein 10))