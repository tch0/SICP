#lang sicp

; just apply-generic, can not test independently
(define (apply-generic op . args)
    (let ((type-tags (map type-tag args))) ; use list of tags as type
        (let ((proc (get op type-tags)))
            (if proc
                ; find procedure
                (apply proc (map contents args))
                ; no such a procedure
                (if (= (length args) 2)
                    (let ((type1 (car type-tags))
                          (type2 (cadr type-tags))
                          (a1 (car args))
                          (a2 (cadr args)))
                        (if (equal? type1 type2)
                            (error "no method for those types -- in function apply-generic, "
                                   (list op type-tags))
                            (let ((t1->t2 (get-coercoin type1 type2))
                                  (t2->t1 (get-coercoin type2 type1)))
                                (cond (t1->t2 (apply-generic op (t1->t2 a1) a2))
                                      (t2->t1 (apply-generic op a1 (t2->t1 a2)))
                                      (else (error "No method for these types -- in function apply-generic, "
                                                    (list op type-tags)))
                                )
                            )
                        )
                    )
                    (error "No method for these types -- in function apply-generic, "
                           (list op type-tags))
                )
            )
        )
    )
)

