#lang sicp

; ============================================================================
; fold from Execise2/2.38.FoldLeft.rkt
(define (fold-right op initial sequence)
    (if (null? sequence)
        initial
        (op (car sequence)
            (fold-right op initial (cdr sequence)))
    )
)

(define (fold-left op initial sequence)
    (if (null? sequence)
        initial
        (fold-left op (op initial (car sequence)) (cdr sequence))
    )
)
; ============================================================================
; filter from 2DataAbstraction/P78.SequenceAsInterface.rkt
(define (filter predicate sequence)
    (cond ((null? sequence) nil)
          ((predicate (car sequence))
           (cons (car sequence) (filter predicate (cdr sequence))))
          (else (filter predicate (cdr sequence)))
    )
)
; ============================================================================
; enumerate-interval from 2DataAbstraction/P83.NestedMapping.rkt
(define (enumerate-interval a b)
    (if (> a b)
        nil
        (cons a (enumerate-interval (+ a 1) b))
    )
)
; flatmap from 2DataAbstraction/P83.NestedMapping.rkt
(define (flatmap proc seq)
    (fold-right append nil (map proc seq))
)
; ============================================================================

; N-皇后问题：N个皇后放在N*N的棋盘上，使任意两个皇后不能互相攻击（不位于同一行同一列同一对角线）
; 一种解决思路：按规则枚举，按行依次在每一列放置一个皇后，当放置第k个时，前k-1个已经放好符合规则，
;              每次考虑第k个不和前k-1个冲突即可，找到这样的位置，从第一列到第N列执行N次，枚举
;              出所有合法结果。
;   1 2 3 4 5 6 7 8
; 1
; 2
; 3
; 4
; 5
; 6
; 7
; 8

; 第k个皇后的位置是否合法：positions是后k列皇后位置，每个用(row col)列表表示
; 位于同一对角线：|(cur-row - exist-row)| = | (cur-col - exist-col)|
; 其实参数k没有必要传入。
(define (safe? k positions)
    (define (valid? cur exist)
        (let ((cur-row (car cur))
              (cur-col (cadr cur))
              (exist-row (car exist))
              (exist-col (cadr exist)))
            (and (not (= cur-row exist-row)) ; not same row
                 (not (= cur-col exist-col)) ; not same column
                 (not (= (abs (- cur-col exist-col)) (abs (- cur-row exist-row)))) ; not same digonal
            )
        )
    )
    (fold-left (lambda (prev pos) (and prev (valid? (car positions) pos)))
               #t
               (cdr positions))
)

; 添加一个新的皇后位置 (row col)
(define (adjoin-position row col rest)
    (cons (list row col) rest)
)

; 输入：行数/列数N（N-皇后问题）
; 输出：长度为N的列表为一个解法，最终输出为所有解法的集合/列表。
(define (queens board-size)
    ; 放置第k列的皇后，从board-size迭代到0
    (define (queen-cols k)
        (if (= k 0)
            (list nil) ; 需要对最开始的列表做map，所以需要是一个非空的列表
            ; 对新皇后的位置做筛选，只判断新加入的这个皇后，前面的已经经过判断
            (filter (lambda (positions) (safe? k positions))
                    (flatmap (lambda (rest-of-queens)
                                ; 将第k个皇后的可能位置追加到前k-1个皇后的位置取值集合上
                                (map (lambda (new-row)
                                             (adjoin-position new-row k rest-of-queens))
                                     (enumerate-interval 1 board-size)))
                             (queen-cols (- k 1))
                    )
            )
        )
    )
    (queen-cols board-size)
)

; test
; 每个皇后视为相同，八皇后有92种解法
(define 8-queens-result (queens 8))
(define (display-result res)
    (define (display-line line count)
        (display "result ")
        (display count)
        (display ": ")
        (display line)
        (newline)
    )
    (define (display-imp res count)
        (if (null? res)
            (display "end of result\n")
            (and (display-line (car res) count) 
                 (display-imp (cdr res) (+ count 1)))
        )
    )
    (display-imp res 1)
)
(display-result 8-queens-result)
(length 8-queens-result)