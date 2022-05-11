(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp f c)
(req {: iter} :f)
(import-macros {: check : each-in } :m)
(local {:view view} (require :fennel))
(local gfx love.graphics)

(local MODULE {})
(fn is-mine? [e] (= MODULE (. e MODULE)))
(fn annex [tbl] 
  (tset tbl MODULE MODULE)
  (tset tbl :enabled true)

  (comment useful for debugging
           (print "XEH")
           (print (view tbl)))
  tbl)

(fn pp [obj] (print (view obj)))

(var layers {})


(fn swap-layers [new-layers] 
  (check (f.all? new-layers is-mine?) "Layers constructed outside of UI module!")
  (set layers new-layers))

(fn get-layers [] 
  layers)

(fn update-layer [layer dt]
  (each [el (iter layer)]
    (when el.enabled
      (match el
        { :code {:update el-update } MODULE MODULE}
        (el-update el dt)
        {:type :text
         :pos [x y]
         :font fnt
         :text txt
         MODULE MODULE } 
        (do 
          (gfx.setFont fnt)
          (gfx.print txt x y))
        {:type :fps} (do)

        _ (error (.. "Unmatched element in update " (view el)))
        ))))



(fn update [dt] 
  (each [layer (iter layers)]
           (update-layer layer dt)))

(fn draw-layer [layer] 
  (each [el (iter layer)]
    (when el.enabled
      (match el
        { :code {:draw el-draw } MODULE MODULE}
        (el-draw el)
        { :pos [fx fy] :type "fps" MODULE MODULE } 
        (do
          (gfx.print (love.timer.getFPS) fx fy))
        {:type :text
         :pos [x y]
         :font fnt
         :text txt
         MODULE MODULE } 
        (do 
          (gfx.setColor [ 1 1 1 ])
          (gfx.setFont fnt)
          (gfx.print txt x y))
        _ (error (.. "Unmatched element in draw" (view el)))
        )
      )))


(fn draw [] 
  (local (mx my) (love.mouse.getPosition))
  (each-in layer layers
    (each-in el layer
      (match el
        { :code {:draw el-draw } MODULE MODULE}
        (el-draw el)
        { :pos [fx fy] :type "fps" MODULE MODULE } 
        (do
          (gfx.print (love.timer.getFPS) fx fy))
        {:type :text
         :pos [x y]
         :font fnt
         :text txt
         MODULE MODULE } 
        (do 
          (gfx.setColor [ 1 1 1 ])
          (gfx.setFont fnt)
          (gfx.print txt x y))
        _ (error (.. "Unmatched element in draw" (view el)))
        )
  )))

(fn make-layer [layer]
  (check (f.all? layer is-mine?) "Element constructed outside of module found!")
  (each-in child layer
    (when (and child.code child.code.layout)
      (child.code.layout child)))
  { :elems layer
   :update (fn [me dt]  (update-layer me.elems dt))
   :draw (fn [me] (draw-layer me.elems))
   }
  )

(fn add-layer [layer]
  (let [{:elems l} (make-layer layer)]
    (table.insert layers (annex l))))


{
 : add-layer
 : get-layers
 : swap-layers
 : draw-layer
 : update-layer
 : make-layer
 : update
 : draw
 : annex
 }
