(use util.match)

(define library
  '(
    (define-macro swap!
      (lambda (a b)
        (let ([tmp (gensym)])
          `(let ([,tmp ,a])
             (set! ,a ,b)
             (set! ,b ,tmp)))))

    (define-macro let
      (lambda (decls . bodies)
        (if (pair? decls)
            (let ([vars (map car decls)]
                  [vals (map cadr decls)])
              `((lambda ,vars ,@bodies) ,@vals))
            (let ([vars (map car (car bodies))]
                  [vals (map cadr (car bodies))])
              `(letrec ([,decls (lambda ,vars ,@(cdr bodies))])
                 (,decls ,@vals))))))

    (define-macro let*
      (lambda (decls . bodies)
        (if (null? (cdr decls))
            `(let (,(car decls)) ,@bodies)
            `(let (,(car decls)) (let* ,(cdr decls) ,@bodies)))))

    (define-macro letrec
      (lambda (decls . bodies)
        (let ([vars (map car decls)]
              [vals (map cadr decls)])
          (let ([holders (map (lambda (x) #f) vars)]
                [assigns (map (lambda (v e) `(set! ,v ,e)) vars vals)])
            `((lambda ,vars ,@assigns ,@bodies) ,@holders)))))

    (define-macro cond
      (lambda args
        (if (null? args)
            #f
            (if (eq? (caar args) 'else)
                `(begin ,@(cdar args))
                (if (null? (cdar args))
                    (let ([var (gensym)])
                      `(let ([,var ,(caar args)])
                         (if ,var ,var (cond ,@(cdr args)))))
                    `(if ,(caar args)
                         (begin ,@(cdar args))
                         (cond ,@(cdr args))))))))

    (define-macro and
      (lambda (a b)
        `(if ,a (if ,b ,b #f) #f)))

    (define-macro or
      (lambda (a b)
        `(if ,a ,a (if ,b ,b #f))))

    (define-macro not
      (lambda (obj)
        `(if ,obj #f #t)))

    (define-macro do
      (lambda (var-form test-form . args)
        (let ([vars (map car var-form)]
              [vals (map cadr var-form)]
              [step (map cddr var-form)])
          `(letrec ([loop (lambda ,vars
                            (if ,(car test-form)
                                (begin ,@(cdr test-form))
                                (begin
                                  ,@args
                                  (loop ,@(map (lambda (x y)
                                                 (if (null? x) y (car x)))
                                               step
                                               vars)))))])
             (loop ,@vals)))))

    (define box-tag         0)
    (define bytevector-tag  1)

    ;; wraps primitives
    (define eq? (lambda (x1 x2) (%eq? x1 x2)))
    (define fixnum? (lambda (obj) (%fixnum? obj)))
    (define fixnum (lambda (x) (%fixnum x)))
    (define fx+ (lambda (x1 x2) (%fx+ x1 x2)))
    (define fx- (lambda (x1 x2) (%fx- x1 x2)))
    (define fx* (lambda (x1 x2) (%fx* x1 x2)))
    (define fx/ (lambda (x1 x2) (%fx/ x1 x2)))
    (define modulo (lambda (x1 x2) (%modulo x1 x2)))
    (define fx= (lambda (x1 x2) (%eq? x1 x2)))
    (define fx< (lambda (x1 x2) (%fx< x1 x2)))
    (define fx<= (lambda (x1 x2) (%fx<= x1 x2)))
    (define fxabs (lambda (x) (if (fx< 0 x) x (fx- 0 x))))
    (define flonum? (lambda (obj) (%flonum? obj)))
    (define flonum (lambda (x) (%flonum x)))
    (define fl+ (lambda (x1 x2) (%fl+ x1 x2)))
    (define fl- (lambda (x1 x2) (%fl- x1 x2)))
    (define fl* (lambda (x1 x2) (%fl* x1 x2)))
    (define fl/ (lambda (x1 x2) (%fl/ x1 x2)))
    (define fl= (lambda (x1 x2) (%fl= x1 x2)))
    (define fl< (lambda (x1 x2) (%fl< x1 x2)))
    (define fl<= (lambda (x1 x2) (%fl<= x1 x2)))
    (define flabs (lambda (x) (if (fl< 0.0 x) x (fl- 0.0 x))))
    (define + fx+)
    (define - fx-)
    (define = fx=)
    (define < fx<)
    (define boolean? (lambda (obj) (%boolean? obj)))
    (define car (lambda (x) (%car x)))
    (define cdr (lambda (x) (%cdr x)))
    (define cons (lambda (x1 x2) (%cons x1 x2)))
    (define null? (lambda (obj) (%null? obj)))
    (define string->uninterned-symbol (lambda (x) (%string->uninterned-symbol x)))
    (define string? (lambda (obj) (%string? obj)))
    (define make-vector (lambda (k) (%make-vector k)))
    (define vector-ref (lambda (v k) (%vector-ref v k)))
    (define vector-set! (lambda (v k obj) (%vector-set! v k obj)))
    (define make-byte-string (lambda (k) (%make-byte-string k)))
    (define string-size (lambda (str) (%string-size str)))
    (define string-byte-ref (lambda (str k) (%string-byte-ref str k)))
    (define string-byte-set! (lambda (str k n) (%string-byte-set! str k n)))
    (define string-int-ref (lambda (str k) (%string-int-ref str k)))
    (define string-int-set! (lambda (str k n) (%string-int-set! str k n)))
    (define string-float-ref (lambda (str k) (%string-float-ref str k)))
    (define string-float-set! (lambda (str k n) (%string-float-set! str k n)))
    (define object-tag-set! (lambda (obj tag) (%object-tag-set! obj tag)))
    (define object-tag-ref (lambda (obj) (%object-tag-ref obj)))
    (define dlsym (lambda (asciiz) (%dlsym asciiz)))
    (define foreign-call (lambda (fptr args size) (%foreign-call fptr args size)))
    (define foreign-call-int (lambda (fptr args size) (%foreign-call-int fptr args size)))
    (define foreign-call-float (lambda (fptr args size) (%foreign-call-float fptr args size)))
    (define foreign-call-bool (lambda (fptr args size) (if (= (foreign-call-int fptr args size) 0) #f #t)))
    (define set-global-refs! (lambda (obj) (%set-global-refs! obj)))
    (define global-refs (lambda () (%global-refs)))
    (define apply (lambda (proc args) (%apply proc args)))

    (define caar (lambda (x) (car (car x))))
    (define cadr (lambda (x) (car (cdr x))))
    (define cdar (lambda (x) (cdr (car x))))
    (define cddr (lambda (x) (cdr (cdr x))))
    (define caaar (lambda (x) (car (car (car x)))))
    (define caadr (lambda (x) (car (car (cdr x)))))
    (define cadar (lambda (x) (car (cdr (car x)))))
    (define caddr (lambda (x) (car (cdr (cdr x)))))
    (define cdaar (lambda (x) (cdr (car (car x)))))
    (define cdadr (lambda (x) (cdr (car (cdr x)))))
    (define cddar (lambda (x) (cdr (cdr (car x)))))
    (define cdddr (lambda (x) (cdr (cdr (cdr x)))))

    (define list (lambda x x))

    (define length
      (lambda (ls)
        (if (null? ls)
            0
            (+ 1 (length (cdr ls))))))

    (define map
      (lambda (proc ls)
        (if (null? ls)
            '()
            (cons (proc (car ls)) (map proc (cdr ls))))))

    (define reverse
      (lambda (ls)
        (let loop ([ls ls] [a '()])
          (if (null? ls)
              a
              (loop (cdr ls) (cons (car ls) a))))))

    (define mutated-string?
      (lambda (obj tag)
        (if (string? obj)
            (= (object-tag-ref obj) tag)
            #f)))

    (define box?
      (lambda (obj)
        (mutated-string? obj box-tag)))

    (define bytevector?
      (lambda (obj)
        (mutated-string? obj bytevector-tag)))

    (define make-bytevector
      (lambda (k)
        (let ([str (make-byte-string k)])
          (object-tag-set! str bytevector-tag)
          str)))

    (define string->asciiz
      (lambda (str)
        (let* ([size (string-size str)]
               [bv (make-bytevector (+ size 1))])
          (let loop ([k 0])
            (if (= k size)
                (begin
                  (string-byte-set! bv k 0)
                  bv)
                (begin
                  (string-byte-set! bv k (string-byte-ref str k))
                  (loop (+ k 1))))))))

    (define asciiz-length
      (lambda (bv)
        (let ([limit (string-size bv)])
          (let loop ([i 0])
            (cond [(= i limit) limit]
                  [(= (string-byte-ref bv i) 0) i]
                  [else (loop (+ i 1))])))))

    (define asciiz->string
      (lambda (bv)
        (let* ([len (asciiz-length bv)]
               [s (make-byte-string len)])
          (do ((i 0 (+ i 1)))
              ((= i len) s)
            (string-byte-set! s i (string-byte-ref bv i))))))

    (define cproc
      (lambda (return-type name)
        (let ([fptr (dlsym (string->asciiz name))]
              [convert-argument
                (lambda (x)
                  (cond [(fixnum? x) x]
                        [(flonum? x) x]
                        [(boolean? x) (if x 1 0)]
                        [(box? x) x]
                        [(bytevector? x) x]
                        [(string? x) (string->asciiz x)]
                        [else 0]))]
              [fcall
                (cond [(eq? return-type 'int) foreign-call-int]
                      [(eq? return-type 'void) foreign-call-int]
                      [(eq? return-type 'float) foreign-call-float]
                      [(eq? return-type 'bool) foreign-call-bool]
                      [else foreign-call])])
          (lambda args
            (let ([converted-args (map convert-argument args)])
              (fcall fptr (reverse converted-args) (length converted-args)))))))

    (define display (cproc 'int "printf"))
))

(define append-library
  (lambda (exp)
    (if (not (begin-exp? exp))
        `(begin ,@library ,exp)
        `(begin ,@library ,@(cdr exp)))))

(define macroless-form
  (lambda (exp)
    (if (not (begin-exp? exp))
        exp
        `(begin ,@(remove define-macro-exp? (expand-top-level (cdr exp)))))))

(define expand-top-level
  (lambda (exps)
    (let ([env (make-module #f)])
      (map
        (lambda (e)
          (match e
            [('define-macro _ _)
             (eval e env)
             e]
            [else
             (expand e env)]))
        exps))))

(define expand
  (lambda (exp env)
    (if (not (pair? exp))
        exp
        (match exp
          [('define var e)
           `(define ,var ,(expand e env))]
          [('quote obj)
           `(quote ,obj)]
          [('begin . exps)
           `(begin ,@(map (lambda (e) (expand e env)) exps))]
          [('if t c a)
           (let ([t-exp (expand t env)]
                 [c-exp (expand c env)]
                 [a-exp (expand a env)])
             `(if ,t-exp ,c-exp ,a-exp))]
          [('set! v e)
           `(set! ,v ,(expand e env))]
          [('lambda formals . bodies)
           `(lambda ,formals ,@(map (lambda (e) (expand e env)) bodies))]
          [else
           (let ([r (eval `(macroexpand ',exp) env)])
             (if (equal? exp r)
                 (map (lambda (e) (expand e env)) r)
                 (expand r env)))]))))

(define define-macro-exp?
  (lambda (exp)
    (exp? exp 'define-macro)))
