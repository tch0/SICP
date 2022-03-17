#lang sicp

; dotted notation of pair
'(1 . (2 . (3 . ())))
'(1 2 3)

'(1 . 2 . 3) ; why?
'(1 2 . 3)

; improper list
(append '(1 2) '(3 . 4))

; memq/memv/member
(member '(1) '((1) 2 3))

; assq/assv/assoc
(assoc 1 '((1 . 2) (2 . 3) (3 . 4)))