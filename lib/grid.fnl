(local {: view } (require :fennel))

(fn make [w h opts] 
  (local grid {})
  (for [i 1 h] 
    (tset grid i {}))

  (and 
    (?. opts :on-put)
    (or (= (type opts.on-put) :function)
        (error "Grid expects on-put to be either not defined!")))

  (fn at [me x y] (?. grid x y))

  (fn put [me x y val] 
    ;(assert (<= 0 x w) (.. "x value: " x " out of range [1, " w"]"))
    ;(assert (<= 0 y h) (.. "y value: " y " out of range [1, " h "]"))
    (tset grid x y val)
    (when (?. opts :on-put)
      (opts.on-put x y val)))

  (fn update [me x y f]
    (when (and 
            (<= 1 x w)
            (<= 1 y h))
      (let [cell (?. grid x y)]
        (tset grid x y (f cell))
        (when (?. opts :on-put)
          (opts.on-put x y cell))
        (?. grid x y))))

  (fn dims [] [w h])

  (local dirs [[0 1] [0 -1] [1 0] [-1 0]])

  (fn around-point [me x y]
    (var idx 0)
    (fn []
      (when (< idx (length dirs))
        (set idx (+ idx 1))
        (let [[dy dx] (. dirs idx)
              ix (+ x dx)
              iy (+ y dy) ]
        (values ix iy (?. grid ix iy))
        ))))

  (fn every-cell [me]
    (var c 0)
    (var r 1)
    (fn [] 
      (set c (+ c 1))
      (when  (> c w)
        (set c 1)
        (set r (+ r 1)))
      (when 
        (<= r h)
        (values r c (?. grid r c)))))

  (fn every-set-cell [me]
    (var c 0)
    (var r 1)
    (fn [] 
      ; Advance c and r until we find a set cell
      (var keep-going true)
      (while keep-going
        (set c (+ c 1))
        (when (> c w)
          (set c 1)
          (set r (+ r 1)))
        (set keep-going 
             (and (not (?. grid r c))
                  (<= r h))))
      (when (and (<= r h) (?. grid r c))
        (values r c (?. grid r c)))
      ))

  (fn by-rows [me]
    (var r 1)
    (fn []
      (var c 0)
      (when (<= r h)
        (fn []
          (set c (+ c 1))
          (if (< c w)
            (values r c (?. grid r c))
            (do
              (set r (+ r 1)) 
              nil))))))

  (fn up-by-cols [me]
    (var c 1)
    (fn []
      (var r (+ h 1))
      (when (<= c w)
        (values
          c 
          (fn []
            (set r (- r 1))
            (if (> r 0)
              (values r (?. grid r c))
              (do
                (set c (+ c 1)) 
                nil)))))))

  { : at : put : dims : every-cell : every-set-cell : by-rows : up-by-cols : update : around-point })

(fn test []
  (let [g (make 4 6)]
    (g:put 1 1 :a)
    (g:put 1 2 :b)
    (g:put 1 3 :c)
    (g:put 2 1 :e)
    (g:put 2 2 :f)
    (g:put 2 3 :g)
    (g:put 3 1 :h)
    (g:put 3 2 :i)
    (g:put 3 3 :j)
    (each [r c t (g:every-cell)]
      (print r c t))
    ))

{ : make : test }


