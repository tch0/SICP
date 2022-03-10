#lang sicp
(#%require sicp-pict)

; below
;   ^ y
;   |__________
;   |         |
;O2 |_________|__> x2
;   |         |
;O1 |_________|__> x1
; (below down up)
; down: O = (0.0, 0.0), x = (1.0, 0.0), y = (0.0, 0.5)
; up: O = (0.0, 0.5), x = (1.0, 0.0), y = (0.0, 0.5)
(define (below down up)
    (let ((down-painter (transform-painter down
                                           (make-vect 0.0 0.0)
                                           (make-vect 1.0 0.0)
                                           (make-vect 0.0 0.5)))
          (up-painter (transform-painter up
                                         (make-vect 0.0 0.5)
                                         (make-vect 1.0 0.5)
                                         (make-vect 0.0 1.0))))
        (lambda (frame)
            (down-painter frame)
            (up-painter frame)
        )
    )
)

; below2, use beside
(define (below2 down up)
    (rotate90 (beside (rotate270 down) (rotate270 up)))
)

; test
(paint (below einstein (escher)))
(paint (below2 einstein (escher)))