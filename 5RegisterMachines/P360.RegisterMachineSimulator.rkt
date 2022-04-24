#lang sicp

; the register machine simulator (aka the Virtual Machine of register machine)

; instruction set of the register machine:
; 1. (assign <register-name> (reg <register-name>))
; 2. (assign <register-name> (const <constant-value>))
; 3. (assign <regsiter-name> (op <operation-name>) <input1> ... <inputn>)
; 4. (perform (op <operation-name>) <input1> ... <inputn>)
; 5. (test (op <operation-name>) <input1> ... <inputn>)
; 6. (branch (label <label-name>))
; 7. (goto (label <label-name>))
; 8. (assign <register-name> (label <label-name>))
; 9. (goto (reg <register-name>))
; 10. (save <register-name>)
; 11. (restore <register-name>)

; ================================ regsiter machine simulator ============================================================

; construct and return the model of the register machine, consist of registers, operations and controller
; based on the basic machine model, add defined registers, operations, and install the instruction sequence of the controller to it.
(define (make-machine register-names operations controller-text)
    (let ((machine (make-new-machine)))
        (for-each (lambda (register-name)
                        ((machine 'allocate-register) register-name))
                  register-names
        )
        ((machine 'install-operations) operations)
        ((machine 'install-instruction-sequence) (assemble controller-text machine)) ; assemble the input instructions to procedures that can be executed directly.
        machine
    )
)

; save a value to a register of specific register machine
(define (set-register-contents! machine register-name value)
    (set-contents! (get-register machine register-name) value)
    'done
)

; get the value of specific register of specific register machine
(define (get-register-contents machine register-name)
    (get-contents (get-register machine register-name))
)

; simulate the execution of a register machine, start the register machine, from first instruction to the last one.
(define (start machine)
    (machine 'start)
)

; ================================ basic machine model ==================================================================
; basic parts: register, stack

; register
; implement as a procedure with local states
(define (make-register name)
    (let ((contents '*unassigned*))
        (define (dispatch message)
            (cond ((eq? message 'get) contents)
                  ((eq? message 'set) (lambda (value) (set! contents value)))
                  (else (error "Unknown message -- in procedure make-register/dispatch, " message))
            )
        )
        dispatch
    )
)
; visit register
(define (get-contents register) (register 'get))
(define (set-contents! register value) ((register 'set) value))

; stack
; implement as a procedure with local states too
(define (make-stack)
    (let ((s '())
          (number-pushes 0)
          (max-depth 0) ; record maximum depth all times
          (current-depth 0))
        (define (push x)
            (set! s (cons x s))
            (set! number-pushes (+ 1 number-pushes))
            (set! current-depth (+ 1 current-depth))
            (set! max-depth (max current-depth max-depth))
        )
        (define (pop)
            (if (null? s)
                (error "Empty stack -- in procedure make-stack/pop")
                (let ((top (car s)))
                    (set! s (cdr s))
                    (set! current-depth (- current-depth 1))
                    top
                )
            )
        )
        (define (initialize)
            (set! s '())
            (set! number-pushes 0)
            (set! max-depth 0)
            (set! current-depth 0)
            'done
        )
        (define (print-statistics)
            (display (list 'total-pushes '= number-pushes
                           'maximum-depth '= max-depth))
            (newline)
        )
        (define (dispatch message)
            (cond ((eq? message 'push) push)
                  ((eq? message 'pop) (pop))
                  ((eq? message 'initialize) (initialize))
                  ((eq? message 'print-statistics) (print-statistics))
                  (else (error "Unknown request -- in procedrue make-stack/dispatch, " message))
            )
        )
        dispatch
    )
)
; visit stack
(define (pop stack) (stack 'pop))
(define (push stack value) ((stack 'push) value))

; the basic machine model
; make a basic machine model, the common part of all register machine models
; consist of : several basic registers, stack, and a execution mechanism which execute the controller instrucions sequentially
(define (make-new-machine)
    (let ((pc (make-register 'pc))          ; program counter
          (flag (make-register 'flag))      ; test flag, control branch instruction
          (stack (make-stack))              ; stack
          (the-instruction-sequence '()))   ; instruction sequence
        (let ((the-ops (list (list 'initialize-stack (lambda () (stack 'initialize)))
                             (list 'print-stack-statistics (lambda () (stack 'print-statistics))))) ; operations
              (register-table (list (list 'pc pc) (list 'flag flag))))                  ; all registers
            ; allocate a register
            (define (allocate-register name)
                (if (assoc name register-table)
                    (error "Multiply defined register: " name)
                    (set! register-table
                          (cons (list name (make-register name)) register-table))
                )
                'register-allocated
            )
            ; return sepecific register
            (define (lookup-register name)
                (let ((val (assoc name register-table)))
                    (if val
                        (cadr val)
                        (error "Unknown register: " name)
                    )
                )
            )
            ; execute the instrcution sequence
            (define (execute)
                (let ((insts (get-contents pc)))
                    (if (null? insts)
                        'done ; to the end of the instruction sequence, done.
                        (begin ((instruction-execution-proc (car insts))) ; execute current instruction
                               (execute) ; continue to execute
                        )
                    )
                )
            )
            ; message dispatching
            (define (dispatch message)
                (cond ((eq? message 'start)
                       (set-contents! pc the-instruction-sequence) ; initialize the program counter and start to execute
                       (execute))
                      ((eq? message 'install-instruction-sequence) (lambda (seq) (set! the-instruction-sequence seq)))
                      ((eq? message 'allocate-register) allocate-register)
                      ((eq? message 'get-register) lookup-register)
                      ((eq? message 'install-operations) (lambda (ops) (set! the-ops (append the-ops ops))))
                      ((eq? message 'stack) stack)
                      ((eq? message 'operations) the-ops)
                      (else (error "Unknown request -- in procedure make-new-machine/dispatch, " message))
                )
            )
            dispatch
        )
    )
)
; get register of register machine
(define (get-register machine register-name) ((machine 'get-register) register-name))


; ================================ extract instructions and labels from controller text =================================

; assemble the controller text: return the instrction sequence (whose cdr are procedures that can be executed directly) that will be saved in the machine.
; labels are useful when and just when generating execution procedures in update-inst!.
(define (assemble controller-text machine)
    (extract-labels controller-text
                    (lambda (insts labels)
                        (update-insts! insts labels machine)
                        insts ; return value of assemble
                    )
    )
)

; extract instructions and labels from the initial instruction sequence.
; using of receive: a clever way of returning two values, (an alternative way: just return a pair of insts and labels, remove the paramter receive)
; a little bit hard to understand, it will be ok when you get used to it.
(define (extract-labels text receive)
    (if (null? text)
        (receive '() '())
        (extract-labels (cdr text)
            (lambda (insts labels) ; the result of extract-labels of (cdr text)
                (let ((cur-inst (car text)))
                    (if (symbol? cur-inst)
                        ; lebel (for Ex 5.8)
                        (let ((exist-label (assoc cur-inst labels)))
                            (if exist-label
                                ; already exist
                                (error ("Repeated label name -- in procedure extract-labels, " cur-inst))
                                ; new label
                                (receive insts
                                         (cons (make-label-entry cur-inst insts)
                                               labels))
                            )
                        )
                        ; instruction
                        (receive (cons (make-instruction cur-inst) insts)
                                 labels)
                    )
                )
            )
        )
    )
)

; modify instrction table, add corresponding execution procedure for instrction texts
(define (update-insts! insts lebels machine)
    (let ((pc (get-register machine 'pc))
          (flag (get-register machine 'flag))
          (stack (machine 'stack))
          (ops (machine 'operations)))
        (for-each (lambda (inst)
                        (set-instruction-execution-proc! inst
                                                        (make-execution-procedure (instruction-text inst)
                                                                                  lebels
                                                                                  machine
                                                                                  pc
                                                                                  flag
                                                                                  stack
                                                                                  ops))
                  )
                  insts
        )
    )
)

; instruction: (instruction-text . execution procedure generated by make-execution-procedure)
(define (make-instruction text) (cons text '()))
(define (instruction-text inst) (car inst))
(define (instruction-execution-proc inst) (cdr inst))
(define (set-instruction-execution-proc! inst proc) (set-cdr! inst proc))

; label: (label-name . instructions right behind it)
(define (make-label-entry label-name insts) (cons label-name insts))
(define (lookup-label labels label-name)
    (let ((val (assoc label-name labels)))
        (if val
            (cdr val) ; get instructions right behind it (exactly in pointer form)
            (error "Undefined label -- in procedure lookup-label, " label-name)
        )
    )
)

; ================================ the implementation of instrcution set =================================================

; generate an execution procedure (a no args lambda will be called by (machine 'execute)) for every instruction
; executing an instruction is equivalent to execute its execution procedure
(define (make-execution-procedure inst labels machine pc flag stack ops)
    (cond ((eq? (car inst) 'assign) (make-assign inst machine labels ops pc))
          ((eq? (car inst) 'test) (make-test inst machine labels ops flag pc))
          ((eq? (car inst) 'branch) (make-branch inst machine labels ops flag pc))
          ((eq? (car inst) 'goto) (make-goto inst machine labels pc))
          ((eq? (car inst) 'save) (make-save inst machine stack pc))
          ((eq? (car inst) 'restore) (make-restore inst machine stack pc))
          ((eq? (car inst) 'perform) (make-perform inst machine labels ops pc))
          (else (error "Unknown instruction type -- in procedure make-execution-procedure, " inst))
    )
)

; details of implementation of instructions

; auxiliary procedures
(define (tagged-list? exp tag)
    (and (list? exp)
         (not (null? exp))
         (eq? (car exp) tag))
    ; (and (pair? exp) (eq? (car exp) tag)) ; in the book
)

; operation expression : type of ((op <operation-name>) <input1> ... <inputn>)
(define (operation-exp? exp) ; exp is a list of expressions
    (and (pair? exp) (tagged-list? (car exp) 'op))
)
(define (operation-exp-op operation-exp) (cadr (car operation-exp)))
(define (operation-exp-operands operation-exp) (cdr operation-exp))
; create a execution procedure for operations
(define (make-operation-exp exp machine labels operations)
    (let ((op (lookup-prim (operation-exp-op exp) operations))
          (aprocs (map (lambda (e)
                            ; Ex 5.9 : can not operate label, only can operate registers and constants.
                            (if (or (register-exp? e) (constant-exp? e))
                                (make-primitive-exp e machine labels) ; generate execution procedures for operands
                                (error "Can't operate on label -- in procedure make-operation-exp, " exp)
                            )
                       )
                       (operation-exp-operands exp))
          ))
        (lambda ()
            (apply op (map (lambda (p) (p)) aprocs))
        )
    )
)
; lookup operation from operation table
(define (lookup-prim symbol operations)
    (let ((val (assoc symbol operations)))
        (if val
            (cadr val)
            (error "Unknown operation -- in procedure lookup-prim, " symbol)
        )
    )
)

; primitive expressions : type of (reg <register-name>)/(const <constant-value>)/(label <label-name>))
(define (make-primitive-exp exp machine labels) ; exp is just a expression
    (cond ((constant-exp? exp)
           (let ((c (constant-exp-value exp))) ; const
                (lambda () c)
           ))
          ((label-exp? exp)
           (let ((insts (lookup-label labels (label-exp-label exp)))) ; label
                (lambda () insts)
           ))
          ((register-exp? exp)
           (let ((r (get-register machine (register-exp-reg exp)))) ; register
                (lambda () (get-contents r))
           ))
          (else (error "Unknown exprssion type -- in procedure make-primitive-exp, " exp))
    )
)
; specific tyep of primitive expression
; reg
(define (register-exp? exp) (tagged-list? exp 'reg))
(define (register-exp-reg exp) (cadr exp))
; constant
(define (constant-exp? exp) (tagged-list? exp 'const))
(define (constant-exp-value exp) (cadr exp))
; label
(define (label-exp? exp) (tagged-list? exp 'label))
(define (label-exp-label exp) (cadr exp))

; advance pc to the next instruction / pc = pc + 1
(define (advanced-pc pc) (set-contents! pc (cdr (get-contents pc))))

; [assign]
; 1. (assign <register-name> (reg <register-name>))
; 2. (assign <register-name> (const <constant-value>))
; 3. (assign <regsiter-name> (op <operation-name>) <input1> ... <inputn>)
; 8. (assign <register-name> (label <label-name>))
(define (assign-reg-name inst) (cadr inst))
(define (assign-value-exp inst) (cddr inst)) ; all after <register-name>

(define (make-assign inst machine labels operations pc)
    (let ((target (get-register machine (assign-reg-name inst)))
          (value-exp (assign-value-exp inst)))
        (let ((value-proc (if (operation-exp? value-exp)
                              (make-operation-exp value-exp machine labels operations) ; type 3
                              (make-primitive-exp (car value-exp) machine labels)))) ; type 1,2,8
            (lambda () ; the execution procedure is a no args lambda
                (set-contents! target (value-proc))
                (advanced-pc pc) ; pc just move to next
            )
        )
    )
)

; [test]
; 5. (test (op <operation-name>) <input1> ... <inputn>)
(define (test-condition inst) (cdr inst))
(define (make-test inst machine labels operations flag pc)
    (let ((condition (test-condition inst)))
        (if (operation-exp? condition)
            (let ((condition-proc (make-operation-exp condition machine labels operations)))
                (lambda ()
                    (set-contents! flag (condition-proc)) ; just set flag to result
                    (advanced-pc pc)
                )
            )
            (error "Bad test instruction, not operation expression -- in procedure make-test, " inst)
        )
    )
)

; [branch]
; 6. (branch (label <label-name>))
(define (branch-dest inst) (cadr inst))
(define (make-branch inst machine labels operations flag pc)
    (let ((dest (branch-dest inst)))
        (if (label-exp? dest)
            (let ((insts (lookup-label labels (label-exp-label dest))))
                (lambda ()
                    (if (get-contents flag)
                        (set-contents! pc insts) ; flag is true, branch to label
                        (advanced-pc pc) ; flag is false, move to next
                    )
                )
            )
            (error "Bad branch instrucion, the target is not a label -- in procedure make-branch, " inst)
        )
    )
)

; [goto]
; 7. (goto (label <label-name>))
; 9. (goto (reg <register-name>))
(define (goto-dest inst) (cadr inst))
(define (make-goto inst machine labels pc)
    (let ((dest (goto-dest inst)))
        (cond ((label-exp? dest)
               (let ((insts (lookup-label labels (label-exp-label dest))))
                    (lambda () (set-contents! pc insts)) ; goto label
               ))
              ((register-exp? dest)
               (let ((reg (get-register machine (register-exp-reg dest))))
                    (lambda () (set-contents! pc (get-contents reg))) ; goto location that saved in register
               ))
              (else (error "Bad goto instruction, target should be label or register -- in procedure make-goto, " inst))
        )
    )
)

; [save]
; 10. (save <register-name>)
(define (stack-inst-reg-name inst) (cadr inst)) ; for save and restore
(define (make-save inst machine stack pc)
    (let ((reg (get-register machine (stack-inst-reg-name inst))))
        (lambda ()
            (push stack (get-contents reg)) ; push value into stack
            (advanced-pc pc)
        )
    )
)

; [restore]
; 11. (restore <register-name>)
(define (make-restore inst machine stack pc)
    (let ((reg (get-register machine (stack-inst-reg-name inst))))
        (lambda ()
            (set-contents! reg (pop stack))
            (advanced-pc pc)
        )
    )
)

; [perform]
; 4. (perform (op <operation-name>) <input1> ... <inputn>)
(define (perform-action inst) (cdr inst))

(define (make-perform inst machine labels operations pc)
    (let ((action (perform-action inst)))
        (if (operation-exp? action)
            (let ((action-proc (make-operation-exp action machine labels operations)))
                (lambda ()
                    (action-proc)
                    (advanced-pc pc)
                )
            )
            (error "Bad perform instruction, not operation expression -- in procedure make-perform, " inst)
        )
    )
)

; ================================ unit test of instructions =========================================================

(define (print info value)
    (display info)
    (display value)
    (newline)
)

; test of assign
; 1. (assign <register-name> (reg <register-name>))
; 2. (assign <register-name> (const <constant-value>))
; 3. (assign <regsiter-name> (op <operation-name>) <input1> ... <inputn>)
; 8. (assign <register-name> (label <label-name>))
(define test-machine
    (make-machine '(a b c d)
                  (list (list '+ +) (list '- -) (list '* *) (list '/ /) (list '= =))
                  '(
                      (assign a (const 0)) ; 2
                      (assign b (const 10))
                      (assign c (const 99))
                      (assign d (reg c)) ; 1
                      (assign c (reg a)) ; res : a-0 b-10 c-0 d-99
                      (assign b (op *) (reg b) (const 50)) ; 3
                    test-label
                      (assign a (label test-label)) ; 8
                  )
    )
)
(define (test-assign)
    (start test-machine)                                   ; should be:
    (print "a : " (get-register-contents test-machine 'a)) ; (((assign a (label test-label)) . #<procedure>))
    (print "b : " (get-register-contents test-machine 'b)) ; 500
    (print "c : " (get-register-contents test-machine 'c)) ; 0
    (print "d : " (get-register-contents test-machine 'd)) ; 99
)
(display "test of assign:\n")
(test-assign)

; test of perform
; 4. (perform (op <operation-name>) <input1> ... <inputn>)
(set! test-machine
      (make-machine '(a)
                    (list (list 'display display))
                    '(
                        (assign a (const 10))
                        (perform (op display) (const "the value of register a is : "))
                        (perform (op display) (reg a))
                        (perform (op display) (const "\n"))
                     )
      )
)
(define (test-perform)
    (start test-machine)
)
(display "\ntest of perform:\n")
(test-perform)

; test of test
; 5. (test (op <operation-name>) <input1> ... <inputn>)
(set! test-machine
      (make-machine '(a b flag1 flag2 flag3)
                    (list (list '> >) (list '= =) (list '< <))
                    '(
                        (assign a (const 10))
                        (assign b (const 20))
                        (test (op >) (const 10) (const 20)) ; #f
                        (assign flag1 (reg flag))
                        (test (op =) (const 10) (reg a)) ; #t
                        (assign flag2 (reg flag))
                        (test (op <) (reg a) (reg b)) ; #t
                        (assign flag3 (reg flag))
                    )
      )
)
(define (test-test)
    (start test-machine)
    (print "flag1 : " (get-register-contents test-machine 'flag1))
    (print "flag2 : " (get-register-contents test-machine 'flag2))
    (print "flag3 : " (get-register-contents test-machine 'flag3))
)
(display "\ntest of test:\n")
(test-test)

; test of branch
; 6. (branch (label <label-name>))
(set! test-machine
      (make-machine '(a)
                    (list (list '= =) (list '+ +))
                    '(
                        (assign a (const 10))
                        (test (op =) (reg a) (const 10))
                        (branch (label test-label))
                        (assign a (op +) (reg a) (const 10))
                    test-label
                        (assign a (op +) (reg a) (const 10)) ; should be 20
                    )
      )
)
(define (test-branch)
    (start test-machine)
    (print "value of a : " (get-register-contents test-machine 'a))
)
(display "\ntest of branch:\n")
(test-branch)

; test of goto
; 7. (goto (label <label-name>))
; 9. (goto (reg <register-name>))
(set! test-machine
    (make-machine '(a)
                  (list (list '+ +) (list '* *))
                  '(
                      (assign a (const 10))
                      (goto (label test-label2))
                    test-label1
                      (assign a (op *) (reg a) (const 10))
                      (goto (label end-label))
                    test-label2
                      (assign a (op +) (reg a) (const 5))
                      (goto (label test-label1))
                    end-label
                    ; a should be 150
                  )
    )
)
(define (test-goto)
    (start test-machine)
    (print "the value of a : " (get-register-contents test-machine 'a))
)
(display "\ntest of goto:\n")
(test-goto)

; test of save & restore
; 10. (save <register-name>)
; 11. (restore <register-name>)
(set! test-machine
    (make-machine '(a b c)
                  '()
                  '(
                      (assign a (const 10))
                      (assign b (const 20))
                      (assign c (const 30))
                      (save a)
                      (save b)
                      (save c)
                      (restore a) ; 30
                      (restore b) ; 20
                      (restore c) ; 10
                  )
    )
)
(define (test-save-restore)
    (start test-machine)
    (print "a : " (get-register-contents test-machine 'a))
    (print "b : " (get-register-contents test-machine 'b))
    (print "c : " (get-register-contents test-machine 'c))
)
(display "\ntest of save & restore:\n")
(test-save-restore)

; ================================ gcd test ==========================================================================

; test of gcd machine in section 5.1.1
(define gcd-machine
    (make-machine
        '(a b t) ; registers
        (list (list 'rem remainder) (list '= =)) ; operations
        '(test-b ; controller/instructions
            (test (op =) (reg b) (const 0))
            (branch (label gcd-done))
            (assign t (op rem) (reg a) (reg b))
            (assign a (reg b))
            (assign b (reg t))
            (perform (op print-stack-statistics))
            (goto (label test-b))
            gcd-done
        )
    )
)

; run the gcd-machine with specific inputs
(define (my-gcd a b)
    (set-register-contents! gcd-machine 'a a)
    (set-register-contents! gcd-machine 'b b)
    (start gcd-machine)
    (get-register-contents gcd-machine 'a) ; result is stored in register a
)

(display "\ngcd test : \n")
(my-gcd 130 40) ; 10