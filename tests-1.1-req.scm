(add-tests-with-string-output "integers"
  [0 => "0\n"]
  [1 => "1\n"]
  [-1 => "-1\n"]
  [10 => "10\n"]
  [-10 => "-10\n"]
  [2736 => "2736\n"]
  [-2736 => "-2736\n"]
  [268435455 => "268435455\n"]
  [-268435456 => "-268435456\n"]
)
