#lang sicp

; auxiliary procedures
; call all procedures sequently
(define (call-each procedures)
    (if (null? procedures)
        'done
        (begin ((car procedures))
               (call-each (cdr procedures)))
    )
)

; queue from Exercise3/3.22.Queue.rkt
(define (make-queue)
    (let ((front-ptr '())
          (rear-ptr '()))
        (define (empty-queue?) (null? front-ptr))
        (define (set-front-ptr! value) (set! front-ptr value))
        (define (set-rear-ptr! value) (set! rear-ptr value))
        (define (front-queue)
            (if (empty-queue?)
                (error "Call front-queue of a empty queue.")
                (car front-ptr)
            )
        )
        (define (insert-queue! value)
            (let ((new-pair (cons value '())))
                (cond ((empty-queue?) (set-front-ptr! new-pair)
                                      (set-rear-ptr! new-pair))
                      (else (set-cdr! rear-ptr new-pair)
                            (set-rear-ptr! new-pair))
                )
            )
        )
        (define (delete-queue!)
            (if (empty-queue?)
                (error "Delete front of a empty queue.")
                (set-front-ptr! (cdr front-ptr))
            )
        )
        (define (print-queue)
            (display "#queue (front ... rear) : ")
            (display front-ptr)
            (newline)
        )
        (define (dispatch m)
            (cond ((eq? m 'empty-queue?) (empty-queue?))
                  ((eq? m 'front-queue) (front-queue))
                  ((eq? m 'insert-queue!) insert-queue!)
                  ((eq? m 'delete-queue!) (delete-queue!))
                  ((eq? m 'print-queue) (print-queue))
                  (else (error "Unkown request to a queue, " m))
            )
        )
        dispatch
    )
)
(define (insert-queue! queue value) ((queue 'insert-queue!) value))
(define (delete-queue! queue) (queue 'delete-queue!))
(define (empty-queue? queue) (queue 'empty-queue?))
(define (front-queue queue) (queue 'front-queue))
(define (print-queue queue) (queue 'print-queue))

; wire
; construct a new wire, contain a signal value and a procedure list
(define (make-wire)
    (define signal-value 0)
    (define action-procedures '())
    (define (set-my-signal! new-value)
        (if (not (= signal-value new-value))
            (begin (set! signal-value new-value)
                   (call-each action-procedures))
            'done
        )
    )
    (define (accept-action-procedure! proc)
        (set! action-procedures (cons proc action-procedures))
        (proc) ; call proc at once
    )
    (define (dispatch m)
        (cond ((eq? m 'get-signal) signal-value)
              ((eq? m 'set-signal!) set-my-signal!)
              ((eq? m 'add-action!) accept-action-procedure!)
              (else (error "Unkown request -- in make-wire/dispatch, " m))
        )
    )
    dispatch
)
(define (get-signal wire) (wire 'get-signal)) ; get signal in wire
(define (set-signal! wire new-value) ((wire 'set-signal!) new-value)) ; set signal in wire to new value
(define (add-action! wire procedure) ((wire 'add-action!) procedure)) ; execute procedure after signal change in wire

; execute specific procedure after a specific delay
; using an agenda to implement after-delay
(define (after-delay delay action)
    (add-to-agenda! (+ delay (current-time the-agenda))
                    action
                    the-agenda
    )
)
; the agenda is driven by propagate
(define (propagate)
    (if (empty-agenda? the-agenda)
        'done
        (let ((first-item (first-agenda-item the-agenda)))
            (first-item)
            (remove-first-agenda-item! the-agenda)
            (propagate)
        )
    )
)

; the agenda is contructed by several time segments
(define (make-time-segment time queue) (cons time queue))
(define (segment-time s) (car s))
(define (segment-queue s) (cdr s))
; the agenda
(define (make-agenda) (list 0)) ; first element is current time
(define (current-time agenda) (car agenda))
(define (set-current-time! agenda time) (set-car! agenda time))
(define (segments agenda) (cdr agenda))
(define (set-segments! agenda segments) (set-cdr! agenda segments))
(define (first-segment agenda) (car (segments agenda)))
(define (rest-segments agenda) (cdr (segments agenda)))
(define (empty-agenda? agenda) (null? (segments agenda)))

; add action to the agenda
(define (add-to-agenda! time action agenda)
    (define (belongs-before? segments)
        (or (null? segments)
            (< time (segment-time (car segments)))
        )
    )
    (define (make-new-time-segment time action)
        (let ((q (make-queue)))
            (insert-queue! q action)
            (make-time-segment time q)
        )
    )
    (define (add-to-segments! segments)
        (if (= (segment-time (car segments)) time) ;
            (insert-queue! (segment-queue (car segments)) action)
            (let ((rest (cdr segments)))
                (if (belongs-before? rest)
                    (set-cdr! segments
                              (cons (make-new-time-segment time action) (cdr segments)))
                    (add-to-segments! rest)
                )
            )
        )
    )
    (let ((segs (segments agenda)))
        (if (belongs-before? segs)
            (set-segments! agenda
                           (cons (make-new-time-segment time action) segs))
            (add-to-segments! segs)
        )
    )
)

; remove first item from agenda
(define (remove-first-agenda-item! agenda)
    (let ((q (segment-queue (first-segment agenda))))
        (delete-queue! q)
        (if (empty-queue? q)
            (set-segments! agenda (rest-segments agenda))
        )
    )
)

; get first item from agenda
(define (first-agenda-item agenda)
    (if (empty-agenda? agenda)
        (error "Agenda is empty -- in procedure first-agenda-item.")
        (let ((first-seg (first-segment agenda)))
            (set-current-time! agenda (segment-time first-seg))
            (front-queue (segment-queue first-seg))
        )
    )
)

; basic logic gates
(define (inverter input output) ; aka not-gate
    (define (invert-input)
        (let ((new-value (logical-not (get-signal input))))
            (after-delay inverter-delay
                         (lambda () (set-signal! output new-value)))
        )
    )
    (add-action! input invert-input)
    'ok
)

(define (and-gate a1 a2 output)
    (define (and-action-procedure)
        (let ((new-value (logical-and (get-signal a1) (get-signal a2))))
            (after-delay and-gate-delay
                         (lambda () (set-signal! output new-value)))
        )
    )
    (add-action! a1 and-action-procedure)
    (add-action! a2 and-action-procedure)
    'ok
)

(define (or-gate o1 o2 output)
    (define (or-action-procedure)
        (let ((new-value (logical-or (get-signal o1) (get-signal o2))))
            (after-delay or-gate-delay
                         (lambda () (set-signal! output new-value)))
        )
    )
    (add-action! o1 or-action-procedure)
    (add-action! o2 or-action-procedure)
    'ok
)


; pure logical operations
(define (logical-not s)
    (cond ((= s 0) 1)
          ((= s 1) 0)
          (else (error "Invalid input signal for logical-not, " s))
    )
)
(define (logical-and a b)
    (cond ((and (= a 1) (= a 1)) 1)
          ((= a 0) 0)
          ((= b 0) 0)
          (else (error "Invalid input signal for logical-and, " a b))
    )
)
(define (logical-or a b)
    (cond ((and (= a 0) (= b 0)) 0)
          ((= a 1) 1)
          ((= b 1) 1)
          (else (error "Invalid input signal for logical-or, " a b))
    )
)

; half adder
(define (half-adder a b s c)
    (let ((d (make-wire))
          (e (make-wire)))
        (or-gate a b d)
        (and-gate a b c)
        (inverter c e)
        (and-gate d e s)
        'ok
    )
)

; test
(define (probe name wire)
    (add-action! wire
                 (lambda ()
                     (newline)
                     (display name)
                     (display " ")
                     (display (current-time the-agenda))
                     (display "  New value = ")
                     (display (get-signal wire))
                     (newline)
                 )
    )
)

(define the-agenda (make-agenda)) ; the global agenda
; delay constants
(define inverter-delay 2)
(define and-gate-delay 3)
(define or-gate-delay 5)

(define input-1 (make-wire))
(define input-2 (make-wire))
(define sum (make-wire))
(define carry (make-wire))
(probe 'sum sum)
(probe 'carry carry)
(half-adder input-1 input-2 sum carry)
(set-signal! input-1 1)
(propagate)
(set-signal! input-2 1)
(propagate)