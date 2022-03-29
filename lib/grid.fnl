(fn make [w h] 
  (local grid {})

  (fn at [me x y] 
    ;(assert  (.. "x value: " x " out of range [1, " w"]"))
    ;(assert  (.. "y value: " y " out of range [1, " h "]"))
    (if (and (<= 1 x w) (<= 1 y h))
      (?. grid (+ (* w x) y))
      nil))

  (fn put [me x y val] 
    ;(assert (<= 0 x w) (.. "x value: " x " out of range [1, " w"]"))
    ;(assert (<= 0 y h) (.. "y value: " y " out of range [1, " h "]"))
    (if (and (<= 1 x w) (<= 1 y h))
      (tset grid (+ (* w x) y) val)))



  { : at : put })

{ : make }
