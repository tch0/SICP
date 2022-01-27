#lang sicp

; accumulate (from right to left, aka foldr)
(define (accumulate op initial sequence)
    (if (null? sequence)
        initial
        (op (car sequence)
            (accumulate op initial (cdr sequence)))
    )
)

; accumulate list of list, reuslt is a list
(define (accumulate-n op initial seqs)
    (if (null? (car seqs))
        nil
        (cons (accumulate op initial (map car seqs))
              (accumulate-n op initial (map cdr seqs)))
    )
)
; ====================================================================================

; using list of vector(list, line vector) represents matrix
; example: 
; ((1 2 3 4) (4 5 6 7) (6 7 8 9)) represents
; [1 2 3 4]
; [4 5 6 7]
; [6 7 8 9]

; vector v dot vector w : \sum_i vi*wi
(define (dot-product v w)
    (accumulate + 0 (map * v w))
)

; matrix multiply vector, v is column vector
; m is rank m*n, then v is n*1, result is m*1
(define (matrix-*-vector m v)
    (map (lambda (line)
            (accumulate +
                        0
                        (map (lambda (x y) (* x (car y))) line v)))
         m)
)

; matrix multiply matrix
; m : a*b , n : b*c, transpose n : c*b
; result : a*c
; line of m : length b list
; result of line: length c list
(define (matrix-*-matrix m n)
    (let ((cols (transpose n)))
        (map (lambda (line) (matrix-*-vector cols (transpose (list line)))) m)
    )
)

; transpose a matrix
(define (transpose mat)
    (accumulate-n cons nil mat)
)

; test
(define test-m '((1 2 3 4) (4 5 6 7) (6 7 8 9))) ; rank 3*4
(dot-product '(1 2 3 4) '(1 1 1 1))
(matrix-*-vector test-m (transpose '((1 1 1 1))))
(transpose '((1 1 1 1)))
(matrix-*-matrix test-m (transpose '((1 1 1 1) (1 1 1 1))))

; this is first attempt : too complicated !!!
; 这里实现时将matrix-*-vector的第二个向量参数解释为了列向量（也就是列表的列表），带来了不必要的复杂度
; 如果直接使用列表表示这里的向量将会简单很多。
; 见 2.37.MatrixVectorOperations2.rkt