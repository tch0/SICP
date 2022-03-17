#lang sicp

; predicate
; all #t
(number? 3)
(integer? 3)
(rational? 3)
(real? 3)
(complex? 3)

; opeartions
(+ 3 (make-rectangular 1 2))

; exact or inexact
(exact? (sqrt 3))
(exact? (inexact->exact (sqrt 3)))

; rationalize
(rationalize
  (inexact->exact .3) 1/10) ;          ===> 1/3    ; exact
(rationalize .3 1/10)       ;          ===> #i1/3  ; inexact

; square root
(sqrt -1)