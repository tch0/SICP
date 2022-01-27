#lang sicp

; 树的表示就是将列表中的节点换为列表，表示其孩子，其底层的cons逻辑结构等同于树的儿子兄弟链表示
; leaves of a tree
(define (count-leaves x)
    (cond ((null? x) 0)
          ((not (pair? x)) 1)
          (else (+ (count-leaves (car x)) (count-leaves (cdr x))))
    )
)

(count-leaves (cons (list 1 2) (list 3 4)))