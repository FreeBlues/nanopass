(add-tests-with-string-output "flonum?"
  [(flonum? 0.0) => "#t\n"]
  [(flonum? -1.2) => "#t\n"]
  [(flonum? 0) => "#f\n"]
  [(flonum? '()) => "#f\n"]
  [(flonum? "s") => "#f\n"]
)

(add-tests-with-string-output "flonum"
  [(flonum 0) => "0.000000\n"]
  [(flonum 1) => "1.000000\n"]
  [(flonum -1) => "-1.000000\n"]
  [(flonum 42) => "42.000000\n"]
  [(fl+ 4.5 (flonum 42)) => "46.500000\n"]
)

(add-tests-with-string-output "fl+"
  [(fl+ 1.0 2.0) => "3.000000\n"]
  [(fl+ 1.0 -2.0) => "-1.000000\n"]
  [(fl+ -1.0 2.0) => "1.000000\n"]
  [(fl+ -1.0 -2.0) => "-3.000000\n"]
  [(fl+ 1.0 1.5) => "2.500000\n"]
  [(fl+ 100000.0 0.1) => "100000.062500\n"]
  [(fl+ (fl+ 1.1 2.2) 3.3) => "6.599995\n"]
  [(fl+ 1.1 (fl+ 2.2 3.3)) => "6.599995\n"]
  [(fl+ (fl+ (fl+ (fl+ 1.11 2.22) 3.33) 4.44) 5.55) => "16.649979\n"]
)

(add-tests-with-string-output "fl-"
  [(fl- 1.0 2.0) => "-1.000000\n"]
  [(fl- 2.0 1.0) => "1.000000\n"]
)

(add-tests-with-string-output "fl*"
  [(fl* 1.0 2.0) => "2.000000\n"]
  [(fl* 3.0 2.0) => "6.000000\n"]
  [(fl* 0.3 0.0) => "0.000000\n"]
  [(fl* 0.3 0.1) => "0.030000\n"]
  [(fl* -0.3 0.3) => "-0.090000\n"]
  [(fl* (fl* (fl* (fl* 1.11 2.22) 3.33) 4.44) 5.55) => "202.206421\n"]
)

(add-tests-with-string-output "fl/"
  [(fl/ 1.0 2.0) => "0.500000\n"]
  [(fl/ 0.0 2.0) => "0.000000\n"]
)

(add-tests-with-string-output "fl="
  [(fl= 1.0 1.0) => "#t\n"]
  [(fl= 1.0 1.1) => "#f\n"]
  [(fl= -0.0 0.0) => "#t\n"]
)

(add-tests-with-string-output "fl<"
  [(fl< 1.0 1.2) => "#t\n"]
  [(fl< 1.0 -1.2) => "#f\n"]
  [(fl< 2.0 1.2) => "#f\n"]
  [(fl< 1.0 1.0) => "#f\n"]
)

(add-tests-with-string-output "fl<="
  [(fl<= 1.0 1.2) => "#t\n"]
  [(fl<= 1.0 -1.2) => "#f\n"]
  [(fl<= 1.0 1.0) => "#t\n"]
)

(add-tests-with-string-output "flabs"
  [(flabs -1.0) => "1.000000\n"]
  [(flabs 1.0) => "1.000000\n"]
  [(flabs -8.5) => "8.500000\n"]
)
