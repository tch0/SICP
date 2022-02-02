#lang sicp

; learning of quote/'

'(a b c)
(quote (a b c))
''a
'()

(memq 'b '(a b c))

(list 'a 'b 'c)
(list (list 'a))
(cdr '((x1 x2) (y1 y2)))
(cadr '((x1 x2) (y1 y2)))
(pair? (car '(a short list)))
(symbol? 'a)