(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp f)
(local {: view } (require :fennel))
(local gfx love.graphics)

(fn min [nums] 
  (accumulate 
    [val 999999999 
     _ n (ipairs nums)]
    (math.min n val)))

(fn max [nums] 
  (accumulate 
    [val -999999999 
     _ n (ipairs nums)]
    (math.max n val)))

(fn get-bounds [scene] 
  (let [
        xs (accumulate 
             [res [] 
              _ shape (ipairs scene)]
             (do
               (each [i (f.range 1 (length shape.points) 2)]
                 (table.insert res (. shape.points i)))
               res))
        ys (accumulate 
             [res [] 
              _ shape (ipairs scene)]
             (do
               (each [i (f.range 2 (length shape.points) 2)]
                 (table.insert res (. shape.points i)))
               res))
        max-x (max xs)
        min-x (min xs)
        max-y (max ys)
        min-y (min ys)
        ret [min-x min-y
             (- max-x min-x)
             (- max-y min-y)]
        ]
    ret))



(lambda draw [data] 
  (each [_ shape (ipairs data)]
    (gfx.setColor shape.color)
    (gfx.line shape.points)))

(fn draw-switch-color [data target new] 
  (local [tr tb tg] target)
  (each [_ shape (ipairs data)]
    (let [[r b g] shape.color]
    (if (and (= tr r) (= tb b) (= tg g))
      (gfx.setColor new)
      (gfx.setColor shape.color))
    (gfx.line shape.points))))

(fn center-norm [data]
  (let [[x y w h] (get-bounds data)
        cx (/ w 2)
        cy (/ h 2)]
    (each [_ shape (ipairs data)]
      (each [xi (f.range 1 (length shape.points) 2)]
        (tset shape.points xi 
              (- (. shape.points xi) x cx)))
      (each [yi (f.range 2 (length shape.points) 2)]
        (tset shape.points yi 
              (- (. shape.points yi) y cy))))
  {
   :shapes data
   :dims [x y w h]
   :draw (fn [me] (draw me.shapes))
   :draw-at (fn [me pos] (gfx-at pos (draw me.shapes)))
   }))

(fn corner-norm [data]
  (let [[x y w h] (get-bounds data)]
    (each [_ shape (ipairs data)]
      (each [xi (f.range 1 (length shape.points) 2)]
        (tset shape.points xi 
              (- (. shape.points xi) x)))
      (each [yi (f.range 2 (length shape.points) 2)]
        (tset shape.points yi 
              (- (. shape.points yi) y))))
  {
   :shapes data
   :dims [x y w h]
   :draw (fn [me] (draw me.shapes))
   :draw-at (fn [me pos] (gfx-at pos (draw me.shapes)))
   }))

{ : draw : draw-switch-color : center-norm : corner-norm }
