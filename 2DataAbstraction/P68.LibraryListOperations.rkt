#lang sicp

; https://docs.racket-lang.org/r5rs/r5rs-std/r5rs-Z-H-9.html#%_sec_6.3.2
; standard list procedures
(list-ref '(1 2 3 4) 2) ; visit by index
(null? '()) ; null?
(append '(1 2) '(3 4)) ; append list to another list
(length '(1 2 3)) ; length of list
(reverse '(1 2 3)) ; reverse a list
(list? nil) ; list?
(list-tail '(1 2 3) 1) ; get tail of list from specified index
(map (lambda (x) (* 2 x)) (list 1 2 3)) ; map