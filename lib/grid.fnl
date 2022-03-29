(fn make [w h] 
  (local grid {})

  (fn at [me x y] 
    ;(assert (<= 0 x w) (.. "x value: " x " out of range [1, " w"]"))
    ;(assert (<= 0 y h) (.. "y value: " y " out of range [1, " h "]"))
    (?. grid (+ (* w x) y)))

  (fn put [me x y val] 
    ;(assert (<= 0 x w) (.. "x value: " x " out of range [1, " w"]"))
    ;(assert (<= 0 y h) (.. "y value: " y " out of range [1, " h "]"))
    (tset grid (+ (* w x) y) val))



  { : at : put })

{ : make }
