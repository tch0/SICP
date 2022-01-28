#lang sicp
(#%require sicp-pict)

; a fake draw-line, no such a built-in draw-line, just use built-in segments->painter
(define (draw-line segment)
    0
)

; segement painter
(define (segments->painter segments-list)
    (lambda (frame)
        (for-each (lambda (segment)
                        (draw-line ((frame-coord-map frame) (segment-start segment))
                                   ((frame-coord-map frame) (segment-end segment))))
                  segments-list)
    )
)

; test : none