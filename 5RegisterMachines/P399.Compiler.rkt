#lang sicp

; compiler: generate assembly code of register machine, and executed by the register machine

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

; auxiliary procedures
(define (tagged-list? exp tag)
    (and (list? exp)
         (not (null? exp))
         (eq? (car exp) tag))
    ; (and (pair? exp) (eq? (car exp) tag)) ; in the book
)

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
(define the-global-environment (setup-environment))


; ========================================== compile ============================================================================

; top level dispatch
(define (compile exp target linkage)
    (cond ((self-evaluating? exp) (compile-self-evaluating exp target linkage))
          ((quoted? exp) (compile-quoted exp target linkage))
          ((variable? exp) (compile-variable exp target linkage))
          ((assignment? exp) (compile-assignment exp target linkage))
          ((definition? exp) (compile-definition exp target linkage))
          ((if? exp) (compile-if exp target linkage))
          ((lambda? exp) (compile-lambda exp target linkage))
          ((begin? exp) (compile-sequence (begin-actions exp) target linkage))
          ((cond? exp) (compile (cond->if exp) target linkage))
          ((application? exp) (compile-application exp target linkage))
          (else (error "Unknown expression type -- in procedure compile, " exp))
    )
)

; compile all kinds of expressions
; arguments:
;       target: is a register that the result of expression compiled will be saved in here.
;       linkage: when the compiled code has been executed, how to go on next?
;           1. next: continue executed next instruction in the sequence.
;           2. return: return from the compiled procedure.
;           3. a specific label: jump to an specific entry that is specified by a label.

; example: target is register val, and linkage is next, compiling the expression 5(it's a self-evaluating expression) will get:
;          (assign val (const 5))
;          while if linkage is return, the compiled result will be:
;          (assign val (const 5))
;          (goto (reg continue))

; compile linkage: the ending of all code-generator
(define (compile-linkage linkage)
    (cond ((eq? linkage 'return) (make-instruction-sequence '(continue) '() '((goto (reg continue)))))
          ((eq? linkage 'next) (empty-instruction-sequence))
          (else (make-instruction-sequence '() '() `((goto (label ,linkage))))) ; goto
    )
)
(define (end-with-linkage linkage instruction-sequence)
    (preserving '(continue) instruction-sequence (compile-linkage linkage))
)

; self-evaluating
; compile to: (assign target exp)
(define (compile-self-evaluating exp target linkage)
    (end-with-linkage linkage
                      (make-instruction-sequence '()
                                                 (list target)
                                                 `((assign ,target (const exp)))
                      )
    )
)

; quotation
; compile to: (assign target (text-of-quotation exp))
(define (compile-quoted exp target linkage)
    (end-with-linkage linkage
                      (make-instruction-sequence '()
                                                 (list target)
                                                 `((assign ,target (const ,(text-of-quotation exp))))
                      )
    )
)

; variable
; compile to: (assign target (lookup-variable-value exp env))
(define (compile-variable exp target linkage)
    (end-with-linkage linkage
                      (make-instruction-sequence '(env)
                                                 (list target)
                                                 `((assign ,target (op lookup-variable-value) (const ,exp) (reg env)))
                      )
    )
)

; assignment
; compile to: (set-variable-value! var val env)
(define (compile-assignment exp target linkage)
    (let ((var (assignment-variable exp))
          (get-value-code (compile (assignment-value exp) 'val 'next)))
        (end-with-linkage linkage
                          (preserving '(env) ; do not need val
                                      get-value-code ; the instruction sequence that save the result to reg val
                                      (make-instruction-sequence '(env val)
                                                                 (list target)
                                                                 `((perform (op set-variable-value!)
                                                                            (const ,var)
                                                                            (reg val)
                                                                            (reg env)))
                                      )
                          )
        )
    )
)

; definition
; compile to: (define-variable! var val env)
(define (compile-definition exp target linkage)
    (let ((var (assignment-variable exp))
          (get-value-code (compile (definition-value exp) 'val 'next)))
        (end-with-linkage linkage
                          (preserving '(env)
                                      get-value-code ; the instruction sequence that save the result to reg val
                                      (make-instruction-sequence '(env val)
                                                                 (list target)
                                                                 `((perform (op define-variable!)
                                                                           (const ,var)
                                                                           (ref val)
                                                                           (reg env)))
                                      )
                          )
        )
    )
)

; auxiliary procedure
(define label-counter 0)
(define (new-label-number)
    (set! label-counter (+ label-counter 1))
    label-counter
)
; generate a unique label (by add a unique number to a name) to prevent nameclash of labels
(define (make-label name)
    (string->symbol
        (string-append (symbol->string name)
                       (number->string (new-label-number))
        )
    )
)

; if
; compile to:
; compile predicate, target val, linkage next
;   (test (op false?) (reg val))
;   (branch label false-branch)
; true-branch
;   compiling result of consequent
; false-branch
;   compiling result of alternative
; after-if
(define (compile-if exp target linkage)
    (let ((t-branch (make-label 'true-branch))
          (f-branch (make-label 'false-branch))
          (after-if (make-label 'after-if)))
        (let ((consequent-linkage (if (eq? linkage 'next) after-if linkage)))
            (let ((p-code (compile (if-predicate exp) 'val 'next))
                  (c-code (compile (if-consequent exp) target consequent-linkage))
                  (a-code (compile (if-alternative exp) target linkage)))
                (preserving '(env continue) ; reserve env and continue, because consequent and alternative might use them.
                            p-code
                            (append-instruction-sequences (make-instruction-sequence '(val)
                                                                                     '()
                                                                                     `((test (op false?) (reg val))
                                                                                       (branch (label ,f-branch))))
                                                          (parallel-instruction-sequences (append-instruction-sequences t-branch c-code)
                                                                                          (append-instruction-sequences f-branch a-code)
                                                          )
                                                          after-if
                            )
                            
                )
            )
        )
    )
)

; lambda
; the result of lambda is a procedure
; the target code of a lambda must has a form like:
;       construct a procedure object and assign it to target register
;       link/(goto (label after-lambda))
;       the compiling result of the procedure body
;       after-lambda
; and the code of lambda body must be generated (even if it's not executing right now) when compiling.
(define (compile-lambda exp target linkage)
    (let ((proc-entry (make-label 'entry))
          (after-lambda (make-label 'after-lambda)))
        (let ((lambda-linkage (if (eq? linkage 'next)
                                  after-lambda
                                  linkage)))
            (append-instruction-sequences (tack-on-instrcution-sequence (end-with-linkage lambda-linkage
                                                                                          (make-instruction-sequence '(env)
                                                                                                                     (list target)
                                                                                                                     `((assign ,target
                                                                                                                               (op make-compiled-procedure)
                                                                                                                               (label ,proc-entry)
                                                                                                                               (reg env))
                                                                                                                      )
                                                                                          )
                                                                                          (compile-lambda-body exp proc-entry))
                                          ) 
                                          after-lambda
            )
        )
    )
)
; auxiliary procedures of lambda
(define (make-compiled-procedure entry env) (list 'compiled-procedure entry env))
(define (compiled-procedure? proc) (tagged-list? proc 'compiled-procedure))
(define (compiled-procedure-entry c-proc) (cadr c-proc))
(define (compiled-procedure-env c-proc) (caddr c-proc))

; sequence : from begin of procedure body
; compiling of expression sequence :
; compilie every expression separately and link last expression with the linkage of whole sequence
; front expressions will link with next
(define (compile-sequence seq target linkage)
    (if (last-exp? seq)
        (compile (first-exp seq) target linkage) ; last expression
        (preserving '(env continue)
                    (compile (first-exp seq) target 'next) ; front expressions, link with next
                    (compile-sequence (rest-exps seq) target linkage)
        )
    )
)
; compile body of lambda
(define (compile-lambda-body exp proc-entry)
    (let ((formals (lambda-parameters exp)))
        (append-instruction-sequences (make-instruction-sequence '(env proc argl)
                                                                '(env)
                                                                `(,proc-entry
                                                                  (assign env (op compiled-procedure-env) (reg proc))
                                                                  (assign env (op extend-environment (const ,formals) (reg argl) (reg env)))
                                                                ))
                                      (compile-sequence (lambda-body exp) 'val 'return)
        )
    )
)

; application
; form of compiled result:
;   compiled result of operator, linkage is next
;   evaluate arguments and construct arguments list, put into argl
;   use sepecific target and linkage link the call of compiled procedure
(define (compile-application exp target linkage)
    (let ((proc-code (compile (operator exp) 'proc 'next))
          (operand-codes (map (lambda (operand) (compile operand 'val 'next))
                              (operands exp))))
        (preserving '(env continue)
                    proc-code
                    (preserving '(proc continue)
                                (construct-arglist operand-codes)
                                (compile-procedure-call target linkage)
                    )
        )
    )
)
; construt arguments list
(define (construct-arglist operand-codes)
    (let ((operand-codes (reverse operand-codes)))
        (if (null? operand-codes)
            (make-instruction-sequence '()
                                       '(argl)
                                       '((assign argl (const ()))))
            (let ((code-to-get-last-arg (append-instruction-sequences (car operand-codes)
                                                                      (make-instruction-sequence '(val)
                                                                                                 '(argl)
                                                                                                 '((assign argl (op list) (reg val)))))))
                (if (null? (cdr operand-codes))
                    code-to-get-last-arg
                    (preserving '(env) code-to-get-last-arg (code-to-get-rest-args (cdr operand-codes)))
                )
            )
        )
    )
)
(define (code-to-get-rest-args operand-codes)
    (let ((code-for-next-arg (preserving '(argl)
                                          (car operand-codes)
                                          (make-instruction-sequence '(val argl)
                                                                     '(argl)
                                                                     '((assign argl (op cons) (reg val) (reg argl)))))))
        (if (null? (cdr operand-codes))
            code-for-next-arg
            (preserving '(env)
                        code-for-next-arg
                        (code-to-get-rest-args (cdr operand-codes))
            )
        )
    )
)

; application of procedure
(define (compile-procedure-call target linkage)
    (let ((primitive-branch (make-label 'primitive-branch))
          (compiled-branch (make-label 'compiled-branch))
          (after-call (make-label 'after-call)))
        (let ((compiled-linkage (if (eq? linkage 'next) ; not used?
                                    after-call
                                    linkage)))
            (append-instruction-sequences (make-instruction-sequence '(proc)
                                                                     '()
                                                                     '((test (op primitive-procedure?) (reg proc))
                                                                       (branch (label ,primitive-branch)))
                                          )
                                          (parallel-instruction-sequences (append-instruction-sequences compiled-branch
                                                                                                        (compile-proc-appl target linkage))
                                                                          (append-instruction-sequences primitive-branch
                                                                                                        (end-with-linkage linkage
                                                                                                                          (make-instruction-sequence '(proc argl)
                                                                                                                                                     (list target)
                                                                                                                                                     `((assign ,target
                                                                                                                                                               (op apply-primitive-procedure)
                                                                                                                                                               (reg proc)
                                                                                                                                                               (reg argl)))
                                                                                                                          )))
                                          )
                                          after-call
            
            )
        )
    )
)
; generate application of procedure
(define (compile-proc-appl target linkage)
    (cond ((and (eq? target 'val) (not (eq? linkage 'return)))
           (make-instruction-sequence '(proc)
                                      all-regs ;?
                                      `((assign continue (label ,linkage))
                                        (assign val (op compiled-procedure-entry) (reg proc))
                                        (goto (reg val)))
           ))
          ((and (not (eq? target 'val) (not (eq? linkage 'return))))
           (let ((proc-return (make-label 'proc-return)))
                (make-instruction-sequence '(proc)
                                            all-regs
                                            '((assign continue (label ,proc-return))
                                              (assign val (op compiled-procedure-entry) (reg proc))
                                              (goto (reg val))
                                              ,proc-return
                                              (assign ,target (reg val))
                                              (goto (label ,linkage)))
                )
           ))
          ((and (eq? target 'val) (eq? linkage 'return))
           (make-instruction-sequence '(proc continue)
                                      all-regs
                                      '((assign val (op compiled-procedure-entry) (reg proc))
                                        (goto (reg val)))
           ))
          ((and (not (eq? target 'val)) (eq? linkage 'return))
           (error "Return linkage, target not val -- in procedure compile-proc-appl, " target))
    )
)
(define all-regs '()) ; todo : what is this?

; =================================== instruction sequence ==================================================================

; an instruction sequence contains: 
;   1. registers that must be initialized before the executing of this sequence
;   2. registers that will be modified in the executing of this sequence
;   3. the actual instruction sequence (statements)

(define (make-instruction-sequence needs modifies statements) (list needs modifies statements))
(define (empty-instruction-sequence) (make-instruction-sequence '() '() '()))
(define (registers-needed s)
    (if (symbol? s)
        '()
        (car s)
    )
)
(define (registers-modified s)
    (if (symbol? s)
        '()
        (cadr s)
    )
)
(define (statements s)
    (if (symbol? s)
        (list s)
        (caddr s)
    )
)

; whether a certain instruction sequence need or need to modify a specific register
(define (needs-register? seq reg)
    (memq reg (registers-needed seq))
)
(define (modifies-register? seq reg)
    (memq reg (registers-modified seq))
)

; auxiliary list procedures
(define (list-union s1 s2)
    (cond ((null? s1) s2)
          ((memq (car s1) s2) (list-union (cdr s1) s2))
          (else (cons (car s1) (list-union (cdr s1) s2)))
    )
)
(define (list-difference s1 s2)
    (cond ((null? s1) '())
          ((memq (car s1) s2) (list-difference (cdr s1) s2))
          (else (cons (car s1) (list-difference (cdr s1) s2)))
    )
)

; the combination of instruction sequences

(define (append-instruction-sequences . seqs)
    (define (append-2-sequences seq1 seq2)
        (make-instruction-sequence (list-union (registers-needed seq1)
                                               (list-difference (registers-needed seq2)
                                                                (registers-modified seq1)))
                                   (list-union (registers-modified seq1)
                                               (registers-modified seq2))
                                   (append (statements seq1) (statements seq2))
        )
    )
    (define (append-seq-list seqs)
        (if (null? seqs)
            (empty-instruction-sequence)
            (append-2-sequences (car seqs)
                                (append-seq-list (cdr seqs)))
        )
    )
    (append-seq-list seqs)
)

; need erase the influence that first sequence make for the second, like the first modified a register while the second uses this register
; then the result should save and restore this register before and behind the first sequence respectively.
(define (preserving regs seq1 seq2)
    (if (null? regs)
        (append-instruction-sequences seq1 seq2)
        (let ((first-reg (car regs)))
            (if (and (needs-register? seq2 first-reg)
                     (modifies-register? seq1 first-reg))
                (preserving (cdr regs)
                            (make-instruction-sequence (list-union (list first-reg) (registers-needed seq1))
                                                       (list-difference (registers-modified seq1) (list first-reg))
                                                       (append `(('save ,first-reg))
                                                               (statements seq1)
                                                               `((restore ,first-reg))))
                            seq2
                )
                (preserving (cdr regs) seq1 seq2)
            )
        )
    )
)

; concat a procedure body and another sequence
(define (tack-on-instrcution-sequence seq body-seq)
    (make-instruction-sequence (registers-needed seq)
                               (registers-modified seq)
                               (append (statements seq) (statements body-seq))
    )
)

; for compile-if and compile procedure-call
(define (parallel-instruction-sequences seq1 seq2)
    (make-instruction-sequence (list-union (registers-needed seq1)
                                           (registers-needed seq2))
                               (list-union (registers-modified seq1)
                                           (registers-modified seq2))
                               (append (statements seq1) (statements seq2))
    )
)
