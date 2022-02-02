#lang sicp

; from 2DataAbstraction/P106.BinaryTreeAsSet.rkt
; bst type and selector
; nil as empty tree
(define (entry tree) (car tree)) ; first
(define (left-branch tree) (cadr tree)) ; second 
(define (right-branch tree) (caddr tree)) ; thrid

(define (make-tree root left right) (list root left right))

; use bst as dictionary, implement lookup
; given a specific key, return corresponding record.
(define (lookup given-key set-of-records)
    (cond ((null? set-of-records) #f) ; why return false, why not return nil?
          ((= given-key (key (entry set-of-records))) (entry set-of-records))
          ((< given-key (key (entry set-of-records))) (lookup given-key (left-branch set-of-records)))
          (else (lookup given-key (right-branch set-of-records)))
    )
)

; define your own record structure in dictionary, the selector key is the key point.
(define (make-record key value) (cons key value))
(define (key record) (car record))

; test
(define test-dict (list (make-record 10 "hello")
                        (list (make-record 5 "world") nil)
                        nil))
(lookup 10 test-dict)
(lookup 5 test-dict)
(lookup 1 test-dict)