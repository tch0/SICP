#lang sicp

; mobile has two branches
(define (make-mobile left right) (list left right))
; branch has length and structure, structure is either a mobile or a weight(number)
(define (make-branch length structure) (list length structure))

; abstract type of mobile and branch, make abstract barrier more solid.
(define mobile? list?)
(define branch? list?)

; a)
(define (left-branch mobile) (car mobile))
(define (right-branch mobile) (cadr mobile))
(define (branch-length branch) (car branch))
(define (branch-structure branch) (cadr branch))

; test of a)
(define m (make-mobile (make-branch 2 3) (make-branch 3 4)))
(display "test of a)\n")
(left-branch m)
(right-branch m)
(branch-length (left-branch m))
(branch-structure (right-branch m))
(newline)

; b)
(define (total-weight mobile)
    (let ((left-mobile (branch-structure (left-branch mobile)))
          (right-mobile (branch-structure (right-branch mobile))))
        (+ (if (mobile? left-mobile)
               (total-weight left-mobile)
               left-mobile)
           (if (mobile? right-mobile)
               (total-weight right-mobile)
               right-mobile)
        )
    )
)

; test of b)
(display "test of b)\n")
(total-weight m)
(newline)

; c)
(define (weight-or-mobile-weight mobile-or-weight)
    (if (mobile? mobile-or-weight)
        (total-weight mobile-or-weight)
        mobile-or-weight
    )
)
(define (mobile-balance? mobile)
    (define (sub-balance? mobile-or-weight)
        (if (mobile? mobile-or-weight)
            (mobile-balance? mobile-or-weight)
            #t)
    )
    (let ((left-len (branch-length (left-branch mobile)))
          (left-mobile (branch-structure (left-branch mobile)))
          (right-len (branch-length (right-branch mobile)))
          (right-mobile (branch-structure (right-branch mobile))))
        (and (= (* left-len (weight-or-mobile-weight left-mobile))
                (* right-len (weight-or-mobile-weight right-mobile)))
             (sub-balance? left-mobile)
             (sub-balance? right-mobile)
        )
    )
)

; test of c)
(display "test of c)\n")
(define test-mobile-c
    (make-mobile (make-branch 10
                              (make-mobile (make-branch 5 30) (make-branch 3 50))) ; left weight: 80
                 (make-branch 20 40)
    )
)
; 10 * 80 == 20 * 40
(mobile-balance? test-mobile-c)
(newline)

; d)
; just redefine slectors, we have abstract barrier!