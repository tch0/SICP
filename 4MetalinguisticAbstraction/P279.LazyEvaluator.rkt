#lang sicp

; lazy evaluation version of previous metacircular evaluator (version 1)
; use a thunk to save the informations that delayed object need (like the promise in native Scheme).
; the moments that need force the thunk:
; 1: deliver it to a primitive procedure as argument, and the primitive procedure need this value now.
; 2: when it's the predicate of a if expression.
; 3: when it's the value of a certain operator, and need apply it as a procedure.

; options: remember the result when force it the first time or not.
; out option is to remember the result cuz it must be more efficient than not.

; works:
; modify eval, do not evaluate arguments of application in eval.
; use actual values in application of primitive procedures and delay it in application of compund procedures.
; replace the above 3 occasions that need actual value from eval to actual-value.
; modify REPL.

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
(define (assignment-varaible exp) (cadr exp))
(define (assignment-value exp) (caddr exp))

; assignment
; the return value depends on implementation, so returning 'ok is fine here.
(define (eval-assignment exp env)
    (set-variable-value! (assignment-varaible exp)
                         (eval (assignment-value exp) env)
                         env
    )
    'ok
)

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

; definition, just like assignment, return 'ok same as assignment.
(define (eval-definition exp env)
    (define-variable! (definition-variable exp)
                      (eval (definition-value exp) env)
                      env
    )
    'ok
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

; evaluate if expression
(define (eval-if exp env)
    (if (true? (actual-value (if-predicate exp) env))
        (eval (if-consequent exp) env)
        (eval (if-alternative exp) env)
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

; evaluate a sequence of expressions, for begin and other
; just evaluate them sequently
(define (eval-sequence exps env)
    (cond ((last-exp? exps) (eval (first-exp exps) env))
          (else (eval (first-exp exps) env)
                (eval-sequence (rest-exps exps) env)
          )
    )
)

; ========================================= cond ================================================================================
; cond is a derived expression
; form1: (cond (<test> <action1> <action2> ... <actionn>) ...)
; form2: (cond (<test> => <recipient>) ...)

; abstraction of cond
(define (cond? exp) (tagged-list? exp 'cond))
(define (cond-clauses exp) (cdr exp))
(define (cond-else-clause? clause) (eq? (cond-predicate clause) 'else))
(define (cond-predicate clause) (car clause))
(define (cond-actions clause) (cdr clause))

; convert cond to if, treating cond as a derived expression is simple and easy to understand,
; but then we can not implement the => clause, so better simply implement an eval-cond like.

; ================= deprecated code ==============
; (define (cond->if exp)
;     (expand-clauses (cond-clauses exp))
; )
; (define (expand-clauses clauses)
;     (if (null? clauses)
;         'false
;         (let ((first (car clauses))
;               (rest (cdr clauses)))
;             (if (cond-else-clause? first)
;                 (if (null? rest)
;                     (sequence->exp (cond-actions first))
;                     (error "ELSE clause isn't the last clause -- in procedure cond->if, " clauses)
;                 )
;                 (make-if (cond-predicate first)
;                          (sequence->exp (cond-actions first))
;                          (expand-clauses rest)
;                 )
;             )
;         )
;     )
; )

; new code that support =>
; be careful not to evaluate the predicate twice (consider cases that the predicate expression has side effects).
(define (eval-cond exp env)
    (define (imply-clause? clause) (eq? (cadr clause) '=>))
    (define (else-clause? clause) (eq? (car clause) 'else))
    (define predicate car)
    (define consequent cdr)
    (define (eval-clauses clauses)
        (if (null? clauses)
            'false
            (let ((first-clause (car clauses))
                  (rest-clauses (cdr clauses)))
                (cond ((else-clause? first-clause) (eval-sequence (consequent first-clause) env)) ; else
                      ((imply-clause? first-clause) ; =>
                       (let ((predicate-result (eval (predicate first-clause) env)))
                            (if (true? predicate-result)
                                (apply- (eval (caddr first-clause) env) (list predicate-result) env)
                                (eval-clauses rest-clauses)
                            )
                       ))
                      (else (if (true? (eval (predicate first-clause) env)) ; normal clause
                                (eval-sequence (consequent first-clause))
                                (eval-clauses rest-clauses)
                            )
                      )
                )
            )
        )
    )
    (eval-clauses (cond-clauses exp))
)


; ========================================= and/or ==============================================================================
; form: (and/or <exp1> <exp2> ... <expn>), are special forms

; abstraction of and/or
(define (and? exp) (tagged-list? exp 'and))
(define (or? exp) (tagged-list? exp 'or))
(define (and-or-expressions exp) (cdr exp))
(define (and-or-first-expression exps) (car exps))
(define (and-or-rest-expressions exps) (cdr exps))
(define (and-or-no-expressions exps) (null? exps))

; evaluate and/or
(define (eval-and exps env)
    (cond ((and-or-no-expressions exps) 'true)
          ((not (true? (eval (and-or-first-expression exps) env))) 'false)
          (else (eval-and (and-or-rest-expressions exps) env))
    )
)
(define (eval-or exps env)
    (cond ((and-or-no-expressions exps) 'false)
          ((true? (eval (and-or-first-expression exps) env)) 'true)
          (else (eval-or (and-or-rest-expressions exps) env))
    )
)

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

; let
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

; let*
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

; named let
; form: (let <name> ((<var1> <exp1>) ... (<varn> <expn>)) <body>)
; convert to: ((lambda () (define <name> (<var1> ... <varn>) <body>) (<name> <exp1> ... <expn>)))
; named let is equivalent to a function definition and a call to this function
; attention: need to take care of the nameclash problem
(define (named-let->func exp)
    (make-procedure-definition (named-let-name exp) (named-let-vars exp) (named-let-body exp))
)

; letrec
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

; evaluate operands of a combinator
; the evaluation order of expressions in exps depends on the evaluation order of cons.
(define (list-of-values exps env)
    (if (no-operands? exps)
        '()
        (cons (eval (first-operand exps) env)
              (list-of-values (rest-operands exps) env)
        )
    )
)

; lazy evaluation
; get actual values of arugments
(define (list-of-arg-values exps env)
    (if (no-operands? exps)
        '()
        (cons (actual-value (first-operand exps) env)
              (list-of-arg-values (rest-operands exps) env))
    )
)
; delay arguments
(define (list-of-delayed-args exps env)
    (if (no-operands? exps)
        '()
        (cons (delay-it (first-operand exps) env)
              (list-of-delayed-args (rest-operands exps) env))
    )
)


; ========================================= eval ================================================================================
; eval
(define (eval exp env)
    (cond ((self-evaluating? exp) exp)
          ((variable? exp) (lookup-variable-value exp env))
          ((quoted? exp) (text-of-quotation exp))
          ((assignment? exp) (eval-assignment exp env))
          ((definition? exp) (eval-definition exp env))
          ((if? exp) (eval-if exp env))
          ((lambda? exp) (make-procedure (lambda-parameters exp) (lambda-body exp) env))
          ((begin? exp) (eval-sequence (begin-actions exp) env))
          ((cond? exp) (eval-cond exp env))
          ((let? exp) (eval (let->combination exp) env))
          ((let*? exp) (eval (let->combination (let*->nested-lets exp)) env))
          ((letrec? exp) (eval (let->combination (letrec->let exp)) env))
          ((while? exp) (eval (while->combination exp) env))
          ;((application? exp) (apply- (eval (operator exp) env) (list-of-values (operands exp) env)))
          ((application? exp) (apply- (actual-value (operator exp) env) (operands exp) env)) ; lazy evaluation now.
          (else (error "Unkown expression type -- in procedure eval, " exp))
    )
)

; ========================================= lazy evaluation =====================================================================
; abastraction of thunk
(define (thunk? obj) (tagged-list? obj 'thunk))
(define (make-thunk exp env) (list 'thunk exp env))
(define (thunk-exp obj) (cadr obj))
(define (thunk-env obj) (caddr obj))

; for thunk to memorize, when a thunk been evaluated, convert it into an evaluated thunk.
(define (evaluated-thunk? obj) (tagged-list? obj 'evaluated-thunk))
(define (thunk-value evaluated-thunk) (cadr evaluated-thunk))

; evaluate the actual value of an expression, eval then force
(define (actual-value exp env)
    (force-it (eval exp env))
)

; representation of thunk (aka promise object in native Scheme)
(define (force-it obj)
    (cond ((thunk? obj) ; not evaluated yet
           (let ((result (actual-value (thunk-exp obj) (thunk-env obj))))
               (set-car! obj 'evaluated-thunk)
               (set-car! (cdr obj) result) ; replace exp with its value
               (set-car! (cddr obj) '()) ; forget unneeded env
               result
           ))
          ((evaluated-thunk? obj) (thunk-value obj))
          (else obj) ; not thunk
    )
)

; delay an object
(define (delay-it exp env)
    (make-thunk exp env)
)

; ========================================= procedure calls =====================================================================
; abstraction of procedure
; primitive procedure: (primitive implementation)
(define (primitive-procedure? procedure) (tagged-list? procedure 'primitive))
(define (primitive-implementation procedure) (cadr procedure))
; compound procedure (self defined procedure)
(define (compound-procedure? procedure) (tagged-list? procedure 'procedure))
(define (make-procedure parameters body env) (list 'procedure parameters (scan-out-defines body) env)) ; construct compund procedures
(define (procedure-parameters exp) (cadr exp))
(define (procedure-body exp) (caddr exp))
(define (procedure-environment exp) (cadddr exp))

; evaluate primitive procedures
(define apply-in-underlying-scheme apply)
(define (apply-primitive-procedure procedure arguments)
    (apply-in-underlying-scheme (primitive-implementation procedure) arguments)
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

; ========================================= apply ================================================================================
; apply
; in order to avoid nameclash, need to rename apply to apply-,
; because there is no way to keep the underlying apply and define a new apply at same time.
(define (apply- procedure arguments env)
    (cond ((primitive-procedure? procedure) (apply-primitive-procedure procedure (list-of-arg-values arguments env))) ; changed, get actual values of arguments
          ((compound-procedure? procedure)
           (eval-sequence (procedure-body procedure)
                          (extend-environment (procedure-parameters procedure)
                                              (list-of-delayed-args arguments env) ; changed, pass delayed objects of arguments
                                              (procedure-environment procedure))
           ))
          (else (error "Unkown procedrue type -- in procedure apply-, " (list procedure arguments)))
    )
)

; ========================================= REPL ==================================================================================
; Read-Eval-Print-Loop
(define input-prompt ";;; L-Eval input: ")
(define output-prompt ";;; L-Eval value: ")
(define (driver-loop port)
    (prompt-for-input input-prompt)
    (let ((input (read port)))
        (if (eof-object? input)
            (display "====== eof ======")
            (begin (let ((output (actual-value input the-global-environment)))
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

; ========================================== test REPL ============================================================================
; run REPL
; run on Scheme test source file
(driver-loop (open-input-file "TestOfEvaluator.rkt"))
; all passed

; interactive mode
; (driver-loop (current-input-port))