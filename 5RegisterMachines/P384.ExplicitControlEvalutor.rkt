#lang sicp

; an assembly implementation of Scheme metacircular evaluator

; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; register machine implementation from 5RegisterMachines/P360.RegisterMachineSimulator.rkt
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    (let ((contents '*unassigned*)
          (trace-on false)) ; trace register modification
        ; Ex 5.18
        (define (display-reg-info new-value)
            (display (list "***** Register" name "modification:" "original value:" contents ", new value:" new-value))
            (newline)
        )
        (define (dispatch message)
            (cond ((eq? message 'get) contents)
                  ((eq? message 'set) (lambda (value)
                                            ; trace register when set
                                            (if trace-on
                                                (display-reg-info value)
                                            )
                                            (set! contents value)
                                      ))
                  ((eq? message 'trace-on) (set! trace-on true))
                  ((eq? message 'trace-off) (set! trace-on false))
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
            (display (list "+++++ Stack:" 'total-pushes '= number-pushes 'maximum-depth '= max-depth))
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
          (the-instruction-sequence '())    ; instruction sequence
          (instruction-number 0)            ; count of instruction number executed
          (trace-on false))                 ; open instruction trace or not
        ; Ex 5.15
        (define (print-instruction-number)
            (display (list "Instructions that have already executed:" instruction-number))
            (newline)
        )
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
                        (begin ; Ex 5.16 , trace instruction currently executing
                               (if trace-on
                                   ; Ex 5.17 : trace label before every instruction (if exist)
                                   (begin (if (not (null? (instruction-label (car insts)))) 
                                              (begin (display (list "===== Label:" (instruction-label (car insts))))
                                                     (newline)
                                              )
                                          )
                                          (display (list "Instruction:" (caar insts)))
                                          (newline)
                                   )
                               )
                               ((instruction-execution-proc (car insts))) ; execute current instruction
                               (set! instruction-number (+ instruction-number 1))
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
                      ; for statistics and debug informations
                      ((eq? message 'instruction-number) (print-instruction-number))
                      ((eq? message 'trace-on) (set! trace-on true))
                      ((eq? message 'trace-off) (set! trace-on false))
                      ((eq? message 'register-trace-on) (lambda (register-name) ((lookup-register register-name) 'trace-on)))
                      ((eq? message 'register-trace-off) (lambda (register-name) ((lookup-register register-name) 'trace-off)))
                      (else (error "Unknown request -- in procedure make-new-machine/dispatch, " message))
                )
            )
            dispatch
        )
    )
)
; get register of register machine
(define (get-register machine register-name) ((machine 'get-register) register-name))
; trace of instruction on/off
(define (instruction-trace-on machine) (machine 'trace-on))
(define (instruction-trace-off machine) (machine 'trace-off))
; trace of register on/off
(define (register-trace-on machine register-name) ((machine 'register-trace-on) register-name))
(define (register-trace-off machine register-name) ((machine 'register-trace-off) register-name))

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
                                ; Ex 5.17
                                (begin
                                    ; save label to the instruction behind it
                                    (if (not (null? insts)) ; only when there are instructions behind the label
                                        (set-instruction-label (car insts) cur-inst)
                                    )
                                    ; result
                                    (receive insts
                                             (cons (make-label-entry cur-inst insts)
                                                   labels))
                                )
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

; Ex 5.17 : add lebel (just before the instruction) to the instruction sequence
; instruction: (instruction-text
;               label just before this instruction
;               execution procedure generated by make-execution-procedure)
(define (make-instruction text) (list text '() '()))
(define (make-instruction-with-label text label) (list text label '()))
(define (instruction-text inst) (car inst))
(define (instruction-label inst) (cadr inst))
(define (instruction-execution-proc inst) (caddr inst))
(define (set-instruction-execution-proc! inst proc) (set-car! (cddr inst) proc))
(define (set-instruction-label inst label) (set-car! (cdr inst) label))

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

; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; metacircular evaluator parts from 4MetalinguisticAbstraction/P252.MetacircularEvaluator.rkt
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; ========================================= auxiliary procedures ============================================================
; wrap definition and call in a call of no args lambda to constrain the scope
; for named let/iterations etc.
(define (wrap-in-no-args-lambda . body)
    (make-procedure-application (make-lambda '() body)
                                '()
    )
)

; ========================================= boolean values ==================================================================
; true and false
; 'true represent true, 'fasle represent false
; We can use truth values that are totally different from Scheme.
(define (true? x) (not (eq? x false)))
(define (false? x) (eq? x false))

; ========================================= self-evaluating values ===========================================================
; only numbers and strings are self-evaluating

(define (self-evaluating? exp)
    (cond ((number? exp) true)
          ((string? exp) true)
          (else false)
    )
)

; ========================================= variable ==========================================================================
; using symbol represent variable

(define (variable? exp) (symbol? exp))

; ========================================= quotation =========================================================================
; form: (quote <text-of-quotation>)

; abstraction of quotation
(define (quoted? exp) (tagged-list? exp 'quote)) ; evaluator see 'a as (quote a)
(define (text-of-quotation exp) (cadr exp)) ; evaluate quotation



; ========================================= assignment =========================================================================
; form: (set! <var> <value>)

; abstraction of assignment
(define (assignment? exp) (tagged-list? exp 'set!))
(define (make-assignment var exp) (list 'set! var exp))
(define (assignment-variable exp) (cadr exp))
(define (assignment-value exp) (caddr exp))

; ========================================= definition ==========================================================================
; form1 variable definition: (define <var> <value>)
; form2 procedure definition: (define (<var> <parameter1> ... <parametern>) <body>)
; form2 is equivalent to: (define <var> (lambda (<parameter1> ... <parametern>) <body>))

; abstraction of definition
(define (definition? exp) (tagged-list? exp 'define))
(define (definition-variable exp)
    (if (symbol? (cadr exp))
        (cadr exp)  ; variable name
        (caadr exp) ; procedure name
    )
)
(define (definition-value exp)
    (if (symbol? (cadr exp))
        (caddr exp)
        (make-lambda (cdadr exp) ; formal parameters
                     (cddr exp)) ; body
    )
)

; make a procedure definition
(define (make-procedure-definition name parameters body)
    (cons 'define (cons (cons name parameters) body))
)


; ========================================= lambda ==============================================================================
; form: (lambda (<parameter1> ... <parametern>) <body>)

; abstracion of lambda
(define (lambda? exp) (tagged-list? exp 'lambda))
(define (make-lambda parameters body) (cons 'lambda (cons parameters body)))
(define (lambda-parameters exp) (cadr exp))
(define (lambda-body exp) (cddr exp))

; ========================================= if ==================================================================================
; form1: (if <predicate> <consequent> <alternative>)
; form2: (if <predicate> <consequent>)

; abstraction of if
(define (if? exp) (tagged-list? exp 'if))
(define (make-if predicate consequent alternative) ; for cond->if
    (list 'if predicate consequent alternative)
)
(define (if-predicate exp) (cadr exp))
(define (if-consequent exp) (caddr exp))
(define (if-alternative exp)
    (if (not (null? (cdddr exp)))
        (cadddr exp)
        'false ; why quoted? ; return false if there is no else clause
    )
)

; ========================================= begin ===============================================================================
; form: (begin <exp1> ... <expn>)

; abstraction of begin expression
(define (begin? exp) (tagged-list? exp 'begin))
(define (make-begin seq) (cons 'begin seq))
(define (begin-actions exp) (cdr exp))
; abstraction of the expression sequence of begin, seq is (begin-actions exp)
(define (first-exp seq) (car seq))
(define (rest-exps seq) (cdr seq))
(define (last-exp? seq) (null? (cdr seq)))
; convert sequence to expression
(define (sequence->exp seq)
    (cond ((null? seq) seq)
          ((last-exp? seq) (first-exp seq))
          (else (make-begin seq))
    )
)

; ========================================= cond ================================================================================
; cond is a derived expression
; form1: (cond (<test> <action1> <action2> ... <actionn>) ...)
; form2: (cond (<test> => <recipient>) ...) ; Ex 4.5

; abstraction of cond
(define (cond? exp) (tagged-list? exp 'cond))
(define (cond-clauses exp) (cdr exp))
(define (cond-else-clause? clause) (eq? (cond-predicate clause) 'else))
(define (cond-predicate clause) (car clause))
(define (cond-actions clause) (cdr clause))

; convert cond to if, treating cond as a derived expression is simple and easy to understand,
; but then we can not implement the => clause, so better simply implement an eval-cond like.

; ================= deprecated code ==============
(define (cond->if exp)
    (expand-clauses (cond-clauses exp))
)
(define (expand-clauses clauses)
    (if (null? clauses)
        'false
        (let ((first (car clauses))
              (rest (cdr clauses)))
            (if (cond-else-clause? first)
                (if (null? rest)
                    (sequence->exp (cond-actions first))
                    (error "ELSE clause isn't the last clause -- in procedure cond->if, " clauses)
                )
                (make-if (cond-predicate first)
                         (sequence->exp (cond-actions first))
                         (expand-clauses rest)
                )
            )
        )
    )
)

; ========================================= and/or ==============================================================================
; Ex 4.4
; form: (and/or <exp1> <exp2> ... <expn>), are special forms

; abstraction of and/or
(define (and? exp) (tagged-list? exp 'and))
(define (or? exp) (tagged-list? exp 'or))
(define (and-or-expressions exp) (cdr exp))
(define (and-or-first-expression exps) (car exps))
(define (and-or-rest-expressions exps) (cdr exps))
(define (and-or-no-expressions exps) (null? exps))

; ========================================= let ================================================================================
; derived forms: let/let*/named let

; abstraction of let
(define (let? exp) (tagged-list? exp 'let))
(define (make-let bindings body) (cons 'let (cons bindings body)))
(define (let-vars exp) (map car (cadr exp)))
(define (let-vals exp) (map cadr (cadr exp))) ; list of initial values
(define (let-body exp) (cddr exp)) ; a sequence of expressions
; abstraction of let*
(define (let*? exp) (tagged-list? exp 'let*))
(define (let*-vars exp) (map car (cadr exp)))
(define (let*-vals exp) (map cadr (cadr exp)))
(define (let*-body exp) (cddr exp))
; abstraction of named let
(define (named-let? exp) (and (let? exp) (symbol? (cadr exp))))
(define (named-let-name exp) (cadr exp))
(define (named-let-vars exp) (map car (caddr exp)))
(define (named-let-vals exp) (map cadr (caddr exp)))
(define (named-let-body exp) (cdddr exp))
; abstraction of letrec
(define (letrec? exp) (tagged-list? exp 'letrec))
(define (letrec-vars exp) (map car (cadr exp)))
(define (letrec-vals exp) (map cadr (cadr exp)))
(define (letrec-inits exp) (cadr exp)) ; (var val) pair list
(define (letrec-body exp) (cddr exp))

; Ex 4.6 : let
; form: (let ((<var1> <exp1>) ... (<varn> <expn>)) <body>)
; convert to: ((lambda (<var1> ... <varn>) <body>) <exp1> ... <expn>)
; convert let to combination of above expressions
; convert named let to a call of a lambda with no args (to make a new scope to avoid nameclash problem)
(define (let->combination exp)
    (if (named-let? exp)
        (wrap-in-no-args-lambda (named-let->func exp) ; function definition
                                (make-procedure-application (named-let-name exp) (named-let-vals exp)) ; call to function
        )
        (make-procedure-application (make-lambda (let-vars exp) (let-body exp)) (let-vals exp)) ; normal let
    )
)

; Ex 4.7 : let*
; form: just like let
; could use begin for let*-body or just keep body as a sequence of expressions
(define (let*->nested-lets exp)
    (define (make-lets vars vals)
        (cond ((null? vars) (error "Let variables and vlaues can not be empty -- in let*->nested-lets"))
              ((= (length vars) 1) (cons 'let (cons (list (list (car vars) (car vals))) (let*-body exp))))
              (else (list 'let (list (list (car vars) (car vals))) (make-lets (cdr vars) (cdr vals))))
        )
    )
    (make-lets (let*-vars exp) (let*-vals exp))
)

; Ex 4.8 : named let
; form: (let <name> ((<var1> <exp1>) ... (<varn> <expn>)) <body>)
; convert to: ((lambda () (define <name> (<var1> ... <varn>) <body>) (<name> <exp1> ... <expn>)))
; named let is equivalent to a function definition and a call to this function
; attention: need to take care of the nameclash problem
(define (named-let->func exp)
    (make-procedure-definition (named-let-name exp) (named-let-vars exp) (named-let-body exp))
)

; Ex 4.20 : letrec
; just like inner definitions
; equal to:
; (lambda <vars>
;   (let ((u '*unassigned*)
;         (v '*unassigned*))
;       (set! u <e1>)
;       (set! u <e1>)
;       <e3>
;   )
; )
(define (letrec->let exp)
    (make-let (map (lambda (x) (list x '*unassigned*)) (letrec-vars exp)) ; ((u '*unassigned*) (v '*unassigned*))
              (append (map (lambda (x) (make-assignment (car x) (cadr x))) (letrec-inits exp)) ; (set! u <e1>) (set! u <e1>)
                      (letrec-body exp)) ; <e3>
    )
)


; ========================================= iteration structures =================================================================
; self-defined derived iteration structures
; form: (while <predicate> <body>)

; abstraction of while
(define (while? exp) (tagged-list? exp 'while))
(define (while-predicate exp) (cadr exp))
(define (while-body exp) (cddr exp))

; convert while to combination, don't use the return value of while expression.
(define (while->combination exp)
    (define (while->func name)
        (make-procedure-definition name
                                   '()
                                   (list (make-if (while-predicate exp)
                                                  (sequence->exp (append (while-body exp) (list (make-procedure-application name '()))))
                                                  'false)
                                   )
        )
    )
    ; wrap the procedure definition and call in a lambda to constrain its scope
    (wrap-in-no-args-lambda (while->func 'while-procedure)
                            (make-procedure-application 'while-procedure '())
    )
)

; other iteration structures todo : do, for, until

; ========================================= application =========================================================================
; form : (<operator> <operand1> ... <operandn>)

; abstraction of procedure application
(define (application? exp) (list? exp)) ; (pair? exp) in the book
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))
; operands, ops is (operands exp)
(define (no-operands? ops) (null? ops))
(define (first-operand ops) (car ops))
(define (rest-operands ops) (cdr ops))
(define (last-operand? ops) (null? (cdr ops)))

; ========================================= procedure calls =====================================================================
; abstraction of procedure
; primitive procedure: (primitive implementation)
(define (primitive-procedure? procedure) (tagged-list? procedure 'primitive))
(define (primitive-implementation procedure) (cadr procedure))
; compound procedure (self defined procedure)
(define (compound-procedure? procedure) (tagged-list? procedure 'procedure))
; (define (make-procedure parameters body env) (list 'procedure parameters (scan-out-defines body) env)) ; construct compund procedures
(define (make-procedure parameters body env) (list 'procedure parameters body env))
(define (procedure-parameters exp) (cadr exp))
(define (procedure-body exp) (caddr exp))
(define (procedure-environment exp) (cadddr exp))

; evaluate primitive procedures
(define apply-in-underlying-scheme apply)
(define (apply-primitive-procedure procedure arguments)
    (apply-in-underlying-scheme (primitive-implementation procedure) arguments) ; this apply- is the Scheme underlying apply.
)

; procedure application
(define (make-procedure-application procedure-name procedure-args)
    (cons procedure-name procedure-args)
)

; take care of inner definitions of a lambda
; form: 
; (lambda (vars)
;   (define u <e1>)
;   (define v <e2>)
;   <e3>
; )

; can be equivalent to:
; (lambda <vars>
;   (let ((u '*unassigned*)
;         (v '*unassigned*))
;       (set! u <e1>)
;       (set! u <e1>)
;       <e3>
;   )
; )
; convert a definition that contains inner definition into equivalent let form
; the input argument body is a list, and result should be a list too.
(define (scan-out-defines body)
    (define (collect seq defs exps)
        (if (null? seq)
            (cons defs exps) ; result
            (if (definition? (car seq))
                (collect (cdr seq) (cons (car seq) defs) exps) ; inner definition
                (collect (cdr seq) defs (cons (car seq) exps)) ; normal expression
            )
        )
    )
    (let ((pair (collect body '() '())))
        (let ((defs (car pair))
              (exps (cdr pair)))
            (if (null? defs)
                body ; no definition, just return body
                (list (make-let (map (lambda (def) ; construct a let expression
                                        (list (definition-variable def) '*unassigned*))
                                defs) ; ((u '*unassigned*) (v '*unassigned*))
                                (append (map (lambda (def)
                                                (make-assignment (definition-variable def) (definition-value def)))
                                             defs) ; (set! u <e1>) (set! u <e1>)
                                        exps ; <e3>
                                )
                      )
                )
            )
        )
    )
)

; ========================================= environment ==========================================================================
; abstraction of environment
; an environment is a list of frames
; the enclosing(outter) environment of an environment is the cdr of the environment
(define (enclosing-environment env) (cdr env))
(define (first-frame env) (car env))
(define the-empty-environment '())

; abstraction of frame
; a frame is a pair of variables and their corresponding values
(define (make-frame vars vals) (cons vars vals))
(define (frame-variables frame) (car frame))
(define (frame-values frame) (cdr frame))
(define (add-binding-to-frame! var val frame)
    (set-car! frame (cons var (car frame)))
    (set-cdr! frame (cons val (cdr frame)))
)

; higher operations to an environment

; extend a new frame to an environment
(define (extend-environment vars vals base-env)
    (if (= (length vars) (length vals))
        (cons (make-frame vars vals) base-env)
        (if (< (length vars) (length vals))
            (error "Too many arguments supplied -- in procedure extend-environment, " vars vals)
            (error "Too few arguments supplied -- in procedure extend-environment, " vars vals)
        )
    )
)

; define a variable in an environment
; lookup in first frame, if found then modify this binding, else add a new binding to first frame
(define (define-variable! var val env)
    (let ((frame (first-frame env)))
        (define (scan vars vals)
            (cond ((null? vars) (add-binding-to-frame! var val frame)) ; not found in this frame, add a new binding
                  ((eq? var (car vars)) (set-car! vals val)) ; found, modify to val
                  (else (scan (cdr vars) (cdr vals))) ; continue to scan in first frame
            )
        )
        (scan (frame-variables frame) (frame-values frame))
    )
)

; look up a value of variable from an environment
(define (lookup-variable-value var env)
    (define (env-loop env)
        (define (scan vars vals)
            (cond ((null? vars) (env-loop (enclosing-environment env))) ; not found in current frame, look up from outter frames
                  ((eq? var (car vars)) ; found
                   (if (eq? '*unassigned* (car vals)) ; found but unassigned for inner definitions
                       (error "Variable unsignd -- in procedure lookup-variable-value, " (car vars))
                       (car vals)
                   ))
                  (else (scan (cdr vars) (cdr vals))) ; continue to scan in this frame
            )
        )
        (if (eq? env the-empty-environment)
            (error "Unbound variable -- in procedure lookup-variable-value, " var) ; not found in the entire environment
            (let ((frame (first-frame env)))
                (scan (frame-variables frame) (frame-values frame))
            )
        )
    )
    (env-loop env)
)

; assign/modify a variable to a new value
(define (set-variable-value! var val env)
    (define (env-loop env)
        (define (scan vars vals)
            (cond ((null? vars) (env-loop (enclosing-environment env))) ; not found in current frame, look up from outter frames
                  ((eq? var (car vars)) (set-car! vals val)) ; found
                  (else (scan (cdr vars) (cdr vals))) ; continue to scan in this frame
            )
        )
        (if (eq? env the-empty-environment)
            (error "Unbound variable -- in set-variable-value!, " var) ; not found in the entire environment
            (let ((frame (first-frame env)))
                (scan (frame-variables frame) (frame-values frame))
            )
        )
    )
    (env-loop env)
)

; primitive procedures
(define primitive-procedures
    (list (list 'car car)
          (list 'cdr cdr)
          (list 'cons cons)
          (list 'null? null?)
          (list '+ +)
          (list '- -)
          (list '* *)
          (list '/ /)
          (list '= =)
          (list '> >)
          (list '>= >=)
          (list '< <)
          (list '<= <=)
          ; todo : other primitive procedures ...
    )
)
(define (primitive-procedure-names) (map car primitive-procedures))
(define (primitive-procedure-objects) (map (lambda (proc) (list 'primitive (cadr proc))) primitive-procedures))

; set up the initial environment
(define (setup-environment)
    (let ((initial-env (extend-environment (primitive-procedure-names)
                                           (primitive-procedure-objects)
                                           the-empty-environment)))
        ; add primitive variables' definition
        (define-variable! 'true true initial-env)
        (define-variable! 'false false initial-env)
        (define-variable! '*unassigned* 1 initial-env) ; not to be used, but need to be a variable, for inner definitions.
        initial-env
    )
)
; global environment
(define the-global-environment
    (let ((val (setup-environment)))
        (lambda () val)
    )
) ; change the-global-environment from variable to procedure

; ========================================= REPL ==================================================================================
; Read-Eval-Print-Loop
(define input-prompt ";;; EC-Eval input: ")
(define output-prompt ";;; EC-Eval value: ")
(define (driver-loop port)
    (prompt-for-input input-prompt)
    (let ((input (read port)))
        (if (eof-object? input)
            (display "====== eof ======")
            (begin (let ((output (eval input the-global-environment)))
                        (announce-output output-prompt)
                        (user-print output)
                    )
                    (driver-loop port)
            )
        )
    )
    
)
(define (prompt-for-input string)
    (newline)
    (newline)
    (display string)
)
(define (announce-output string)
    (newline)
    (display string)
)
(define (user-print object)
    (if (compound-procedure? object)
        (display (list 'compound-procedure
                        (procedure-parameters object)
                        (procedure-body object)
                        '<procedure-env>))
        (display object)
    )
)

; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Explicit-Control Evaluator %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

; ================================ Explicit-Control Evaluator ============================================================
; assembly language implementation of metacircular evaluator

; resources of our evaluator register machine
;   a stack
;   7 registers: 
;       exp : evaluated expression
;       env : the environment when evaluating
;       val : the result of evaluating expression in specific environment
;       continue : for implementation of recursion
;       proc : for application, saving procedure/operator
;       argl : for application, saving argument list
;       unev : saving unevaluated operand(s) (arguments or expressions or other)

(define explicit-control-evaluator-instructions
    '(
    ; Read-Eval-Print-Loop
    read-eval-print-loop
        (perform (op initialize-stack))
        (perform (op prompt-for-input) (const ";;; EC-Eval input: "))
        (assign exp (op read))
        (assign env (op the-global-environment))
        (assign continue (label print-result))
        (goto (label eval-dispatch))
    print-result
        (perform (op announce-output) (const ";;; EC-Eval value: "))
        (perform (op user-print) (reg val))
        (goto (label read-eval-print-loop))

    ; errors handling
    unknown-expression-type
        (assign val (const unknown-expression-type-error))
        (goto (label signal-error))
    unknown-procedure-type
        (restore continue) ; clean up stack for apply-dispatch
        (assign val (const unknown-procedure-type-error))
        (goto (label signal-error))
    signal-error
        (perform (op user-print) (reg val)) ; what error
        (goto (label read-eval-print-loop))

    ; the core of explicit control evaluator
    eval-dispatch
        ; self-evaluating
        (test (op self-evaluating?) (reg exp))
        (branch (label ev-self-eval))
        ; variable
        (test (op variable?) (reg exp))
        (branch (label ev-variable))
        ; quotation
        (test (op quoted?) (reg exp))
        (branch (label ev-quoted))
        ; assignment
        (test (op assignment?) (reg exp))
        (branch (label ev-assignment))
        ; definition
        (test (op definition?) (reg exp))
        (branch (label ev-definition))
        ; if
        (test (op if?) (reg exp))
        (branch (label ev-if))
        ; lambda
        (test (op lambda?) (reg exp))
        (branch (label ev-lambda))
        ; begin
        (test (op begin?) (reg exp))
        (branch (label ev-begin))
        ; Ex 5.23 cond and let
        (test (op cond?) (reg exp))
        (branch (label ev-cond))
        (test (op let?) (reg exp))
        (branch (label ev-let))
        ; application
        (test (op application?) (reg exp))
        (branch (label ev-application))
        ; unknown, error
        (goto (label unknown-expression-type))
        
    ; evaluation of simple expressions
    ; put the result to register val, then goto register continue to execute
    ev-self-eval
        (assign val (reg exp))
        (goto (reg continue))
    ev-variable
        (assign val (op lookup-variable-value) (reg exp) (reg env))
        (goto (reg continue))
    ev-quoted
        (assign val (op text-of-quotation) (reg exp))
        (goto (reg continue))
    ev-lambda
        (assign unev (op lambda-parameters) (reg exp))
        (assign exp (op lambda-body) (reg exp))
        (assign val (op make-procedure) (reg unev) (reg exp) (reg env))
        (goto (reg continue))

    ; evluation of application
    ev-application
        (save continue)
        (save env) ; save environment for evaluation of operands
        (assign unev (op operands) (reg exp)) ; extract operands and save to stack
        (save unev)
        ; evaluate operator first
        (assign exp (op operator) (reg exp))
        (assign continue (label ev-appl-did-operator))
        (goto (label eval-dispatch))        ; evaluate operator
    ev-appl-did-operator ; already did operator, evaluate operands now
        (restore unev)                      ; operands
        (restore env)
        (assign argl (op empty-arglist))    ; arguments
        (assign proc (reg val))             ; the operator
        (test (op no-operands?) (reg unev))
        (branch (label apply-dispatch)) ; apply operator to arguments
        (save proc)
    ev-appl-operand-loop ; loop of evaluating operands
        (save argl)
        (assign exp (op first-operand) (reg unev))
        (test (op last-operand?) (reg unev))
        (branch (label ev-appl-last-arg)) ; last argument, special treatment
        (save env)
        (save unev)
        (assign continue (label ev-appl-accumulate-arg))
        (goto (label eval-dispatch))
    ev-appl-accumulate-arg ; after accomplish the evaluation of an argument, the argument will be accmulated to argl
        (restore unev)
        (restore env)
        (restore argl)
        (assign argl (op adjoin-arg) (reg val) (reg argl)) ; add this argument to argument list
        (assign unev (op rest-operands) (reg unev)) ; rest arguments
        (goto (label ev-appl-operand-loop))
    ev-appl-last-arg ; last argument, do not need save environment and unevaluted arguments anymore
        (assign continue (label ev-appl-accum-last-arg))
        (goto (label eval-dispatch))
    ev-appl-accum-last-arg
        (restore argl)
        (assign argl (op adjoin-arg) (reg val) (reg argl)) ; add last argument to argument list
        (restore proc)
        (goto (label apply-dispatch)) ; apply operator to arguments
    apply-dispatch ; corresponds to apply of metacicular evluator
        ; now proc is the value of operator/procedure, argl is the argument list
        (test (op primitive-procedure?) (reg proc))
        (branch (label primitive-apply))
        (test (op compound-procedure?) (reg proc))
        (branch (label compound-apply))
        (goto (label unknown-procedure-type))
    primitive-apply
        (assign val (op apply-primitive-procedure) (reg proc) (reg argl))
        (restore continue) ; continue is in the top of stack, pushed when first goto ev-application
        (goto (reg continue))
    compound-apply
        (assign unev (op procedure-parameters) (reg proc))
        (assign env (op procedure-environment) (reg proc))
        (assign env (op extend-environment) (reg unev) (reg argl) (reg env))
        (assign unev (op procedure-body) (reg proc))
        (goto (label ev-sequence)) ; continue already in top of stack

    ; evaluation of sequence and tail recursion
    ; body of procedure / body of begin
    ev-begin
        (assign unev (op begin-actions) (reg exp))
        (save continue)
        (goto (label ev-sequence))
    ev-sequence
        (assign exp (op first-exp) (reg unev))
        (test (op last-exp?) (reg unev))
        (branch (label ev-sequence-last-exp))
        (save unev)
        (save env)
        (assign continue (label ev-sequence-continue))
        (goto (label eval-dispatch))
    ev-sequence-continue
        (restore env)
        (restore unev)
        (assign unev (op rest-exps) (reg unev))
        (goto (label ev-sequence))
    ev-sequence-last-exp
        (restore continue)
        (goto (label eval-dispatch)) ; after evaluate the last expression, just return, not need to return here again
        ; just goto eval-dispatch, it's a implementation of tail recursion

    ; evaluation of if
    ev-if
        (save exp)      ; save expressions for later
        (save env)
        (save continue)
        (assign continue (label ev-if-decide))
        (assign exp (op if-predicate) (reg exp))
        (goto (label eval-dispatch))
    ev-if-decide
        (restore continue)
        (restore env)
        (restore exp)
        (test (op true?) (reg val))
        (branch (label ev-if-consequent))
    ev-if-alternative
        (assign exp (op if-alternative) (reg exp))
        (goto (label eval-dispatch))
    ev-if-consequent
        (assign exp (op if-consequent) (reg exp))
        (goto (label eval-dispatch))

    ; evluation of assignment
    ev-assignment
        (assign unev (op assignment-variable) (reg exp)) ; save variable for later
        (save unev)
        (assign exp (op assignment-value) (reg exp))
        (save env)
        (save continue)
        (assign continue (label ev-assignment-1))
        (goto (label eval-dispatch)) ; evaluate the assignment value
    ev-assignment-1
        (restore continue)
        (restore env)
        (restore unev) ; variable
        (perform (op set-variable-value!) (reg unev) (reg val) (reg env))
        (assign val (const ok))
        (goto (reg continue))
    ; evaluation of definition
    ev-definition
        (assign unev (op definition-variable) (reg exp)) ; save variable for later
        (save unev)
        (assign exp (op definition-value) (reg exp))
        (save env)
        (save continue)
        (assign continue (label ev-definition-1))
        (goto (label eval-dispatch))
    ev-definition-1
        (restore continue)
        (restore env)
        (restore unev) ; variable
        (perform (op define-variable!) (reg unev) (reg val) (reg env))
        (assign val (const ok))
        (goto (reg continue))

    ; Ex 5.23
    ; evaluation of cond, using transformation
    ev-cond
        (assign exp (op cond->if) (reg exp))
        (goto (label eval-dispatch))
    ; evaluation of let, using transformation
    ev-let
        (assign exp (op let->combination) (reg exp))
        (goto (label eval-dispatch))
    )
)
; auxiliary procedures
(define (adjoin-arg arg arg-list) (cons arg arg-list))
(define (empty-arglist) '())

(define explicit-control-evaluator
    (make-machine '(exp env val continue proc argl unev)
                  (list (list 'read read)
                        (list 'prompt-for-input prompt-for-input)
                        (list 'announce-output announce-output)
                        (list 'user-print user-print)
                        (list 'the-global-environment the-global-environment)
                        (list 'self-evaluating? self-evaluating?)
                        (list 'variable? variable?)
                        (list 'lookup-variable-value lookup-variable-value)
                        (list 'quoted? quoted?)
                        (list 'text-of-quotation text-of-quotation)
                        (list 'assignment? assignment?)
                        (list 'assignment-variable assignment-variable)
                        (list 'assignment-value assignment-value)
                        (list 'set-variable-value! set-variable-value!)
                        (list 'definition? definition?)
                        (list 'definition-variable definition-variable)
                        (list 'definition-value definition-value)
                        (list 'define-variable! define-variable!)
                        (list 'if? if?)
                        (list 'true? true?)
                        (list 'if-predicate if-predicate)
                        (list 'if-consequent if-consequent)
                        (list 'if-alternative if-alternative)
                        (list 'lambda? lambda?)
                        (list 'lambda-parameters lambda-parameters)
                        (list 'lambda-body lambda-body)
                        (list 'begin? begin?)
                        (list 'begin-actions begin-actions)
                        (list 'first-exp first-exp)
                        (list 'rest-exps rest-exps)
                        (list 'last-exp? last-exp?)
                        (list 'cond? cond?)
                        (list 'cond->if cond->if)
                        (list 'let? let?)
                        (list 'let->combination let->combination)
                        (list 'application? application?)
                        (list 'operator operator)
                        (list 'operands operands)
                        (list 'no-operands? no-operands?)
                        (list 'first-operand first-operand)
                        (list 'rest-operands rest-operands)
                        (list 'last-operand? last-operand?)
                        (list 'primitive-procedure? primitive-procedure?)
                        (list 'compound-procedure? compound-procedure?)
                        (list 'make-procedure make-procedure)
                        (list 'procedure-parameters procedure-parameters)
                        (list 'procedure-body procedure-body)
                        (list 'procedure-environment procedure-environment)
                        (list 'apply-primitive-procedure apply-primitive-procedure)
                        (list 'extend-environment extend-environment)
                        (list 'empty-arglist empty-arglist)
                        (list 'adjoin-arg adjoin-arg)
                  )
                  ; instructions
                  explicit-control-evaluator-instructions
    )
)

(start explicit-control-evaluator)