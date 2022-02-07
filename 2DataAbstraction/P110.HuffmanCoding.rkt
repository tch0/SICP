#lang sicp

; Huffman Coding

; representation of leaves of Huffman tree
(define (make-leaf symbol weight)
    (list 'leaf symbol weight)
)
(define (leaf? object)
    (and (list? object) (not (null? object)) (eq? (car object) 'leaf))
)
(define (symbol-leaf x) (cadr x))
(define (weight-leaf x) (caddr x))

; representation of Huffman tree
; (left branch, right branch, a symbol list, a weight)
(define (make-Huffman-tree left right)
    (list left
          right
          (append (symbols left) (symbols right))
          (+ (weight left) (weight right))
    )
)
(define (left-branch tree) (car tree))
(define (right-branch tree) (cadr tree))
(define (symbols tree)
    (if (leaf? tree)
        (list (symbol-leaf tree)) ; leaf node
        (caddr tree) ; non-leaf node
    )
)
(define (weight tree)
    (if (leaf? tree)
        (weight-leaf tree)
        (cadddr tree)
    )
)

; decoding of Huffman Coding
; given binary digits list(arg: bits) and the Huffman tree(arg: tree), decode to raw text.
(define (decode bits tree)
    (define (decode-1 bits current-branch)
        (if (null? bits)
            nil
            (let ((next-branch (choose-branch (car bits) current-branch)))
                (if (leaf? next-branch)
                    (cons (symbol-leaf next-branch) (decode-1 (cdr bits) tree))
                    (decode-1 (cdr bits) next-branch)
                )
            )
        )
    )
    (decode-1 bits tree)
)
; choose left or right branch based on one bit.
(define (choose-branch bit current-branch)
    (cond ((= bit 0) (left-branch current-branch))
          ((= bit 1) (right-branch current-branch))
          (else (error "bad bit -- in choose-branch" bit))
    )
)

; symbols set in tree nodes
; use ordered list represent set since we will serach the two smallest-weight nodes during every merge.
; sort by weight ascending
(define  (adjoin-set x set)
    (cond ((null? set) (list x))
          ((< (weight x) (weight (car set))) (cons x set))
          (else (cons (car set) (adjoin-set x (cdr set))))
    )
)

; construct symbol-weight set, input is list of (symbol frequency) pairs
(define (make-leaf-set pairs)
    (if (null? pairs)
        nil
        (let ((pair (car pairs)))
            (adjoin-set (make-leaf (car pair) ; symbol
                                   (cadr pair)) ; frequency, aka weight
                        (make-leaf-set (cdr pairs)))
        )
    )
)


; Ex 2.67
; define a sample tree and a sample message
;       ABCD,8
;    0 /   \ 1
;     A,4  BCD,4
;        0 /   \ 1
;         B,2   DC,2
;             0 /  \ 1
;              D,1  C,1
(define sample-tree
    (make-Huffman-tree (make-leaf 'A 4)
                       (make-Huffman-tree (make-leaf 'B 2)
                                          (make-Huffman-tree (make-leaf 'D 1)
                                                             (make-leaf 'C 1)))
    )
)
; 0 110 0 10 10 111 0
; A   D A  B  B   C A
(define sample-message '(0 1 1 0 0 1 0 1 0 1 1 1 0))
(display "Ex 2.67: ")
(decode sample-message sample-tree)
; rusult: (A D A B B C A)


; Ex 2.68
; encoding message to binary digits
(define (encode message tree)
    (if (null? message)
        nil
        (append (encode-symbol (car message) tree)
                (encode (cdr message) tree))
    )
)
(define (encode-symbol symb tree)
    (define (encode-1 current-branch result) ; iteration
        (if (memq symb (symbols current-branch))
            (if (leaf? current-branch)
                (reverse result) ; binary digits is in reverse order
                (if (memq symb (symbols (left-branch current-branch)))
                    (encode-1 (left-branch current-branch) (cons 0 result))
                    (encode-1 (right-branch current-branch) (cons 1 result))
                )
            )
            (error "missing symbol -- in encode-symbol" symb current-branch)
        )
    )
    (encode-1 tree nil)

)
; test
(display "Ex 2.68: ")
(encode '(A D A B B C A) sample-tree)
; result: (0 1 1 0 0 1 0 1 0 1 1 1 0)


; Ex 2.69
; generate Huffman tree, according to (symbol frequency) pair
(define (generate-Huffman-tree pairs)
    (successive-merge (make-leaf-set pairs))
)
(define (successive-merge trees)
    (cond ((null? trees) (error "input tree's set is empty -- in successive-merge"))
          ((= (length trees) 1) (car trees))
          (else (successive-merge (adjoin-set (make-Huffman-tree (car trees) (cadr trees))
                                              (cddr trees))))
    )
)
; test
(define test-huffman-tree
    (generate-Huffman-tree '((A 4) (B 2) (C 1) (D 1)))
)
(display "Ex 2.69: \nTree: ")
test-huffman-tree ; same as sample-tree in Ex 2.67, just coincidence.
(display "Encoding result: ")
(encode '(A D A B B C A) test-huffman-tree)
; (0 1 1 0 0 1 0 1 0 1 1 1 0)


; Ex 2.70
; encode a rock song
; symbol frequency pairs
(define rock-song-pairs
    '((A 2) (NA 16) (BOOM 1) (SHA 3) (GET 2) (YIP 9) (JOB 2) (WAH 1))
)
(define rock-song-tree (generate-Huffman-tree rock-song-pairs))
(display "Ex 2.70: \nTree :")
rock-song-tree
(define rock-song-message ; Now, I can only encode upper case words, how to encode lower?
    '(GET A JOB
      SHA NA NA NA NA NA NA NA NA
      GET A JOB
      SHA NA NA NA NA NA NA NA NA
      WAH YIP YIP YIP YIP YIP YIP YIP YIP YIP
      SHA BOOM)
)
(display "Encoding result: ")
(encode rock-song-message rock-song-tree)
(display "Length of result: ")
(length (encode rock-song-message rock-song-tree)) ; 84