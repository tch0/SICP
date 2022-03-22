#lang sicp

; make the front of the queue be car of the pair
; let the queue point to (front-ptr . rear-ptr)

; make an empty queue
(define (make-queue) (cons nil nil))
; front pointer of queue
(define (front-ptr q) (car q))
; rear point of queue
(define (rear-ptr q) (cdr q))
; set front pointer
(define (set-front-ptr! q value) (set-car! q value))
; set rear pointer
(define (set-rear-ptr! q value) (set-cdr! q value))

; is the queue empty
(define (empty-queue? q) (null? (front-ptr q)))
; return front element of the queue
(define (front-queue q)
    (if (empty-queue? q)
        (error "The queue is empty -- in front-queue.")
        (car (front-ptr q))
    )
)
; insert an element to the rear/tail of the queue, return the modified queue
(define (insert-queue! q value)
    (let ((new-pair (cons value nil)))
        (cond ((empty-queue? q) (set-front-ptr! q new-pair)
                                (set-rear-ptr! q new-pair)
                                q)
              (else (set-cdr! (rear-ptr q) new-pair)
                    (set-rear-ptr! q new-pair)
                    q)
        )
    )
)
; pop the front element of the queue, return the modified queue
(define (delete-queue! q)
    (if (empty-queue? q)
        (error "The queue is empty -- in delete-queue!.")
        (begin (set-front-ptr! q (cdr (front-ptr q)))
               q
        )
    )
)

; test
(define q (make-queue))
q
(empty-queue? q)
(insert-queue! q 1)
(insert-queue! q 2)
(insert-queue! q 3)
(insert-queue! q 4)
(empty-queue? q)
(front-queue q)
(delete-queue! q)
(delete-queue! q)
(delete-queue! q)
(front-queue q)
(delete-queue! q)
(insert-queue! q 10)

; Ex 3.21
(newline)
(define (print-queue q)
    (display "#queue (front ... rear) : ")
    (display (front-ptr q))
)
(print-queue q)
(insert-queue! q 1)
(insert-queue! q 2)
(insert-queue! q 3)
(print-queue q)