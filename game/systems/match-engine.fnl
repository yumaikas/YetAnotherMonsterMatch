(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp v f assets fennel)
(req {: iter : range} :f)
(req blood-drop :game.vectors.blood-drop)
(req zap :game.vectors.zap)
(req moon :game.vectors.moon)
(req brain :game.vectors.brain)
(local gfx love.graphics)

; Frankenstien -> Zaps *
; Vampires -> blood *
; Ghouls -> souls
; Zombies -> brains *
; Werewolves -> Moons *
; Dracula
; Igor



(fn update [me dt]
  (let [(mxp myp) (gfx.inverseTransformPoint (love.mouse.getPosition))
        [mx my]  (v.sub [mxp myp] me.pos)
        [c r]  [
               (math.ceil (/ mx 42))
               (math.ceil (/ my 42))
               ] 
        cell (?. me.cells r c)
        ]
    (when me.hl
      (set me.hl.hl nil))
    (when cell
      (set me.hl cell)
      (set cell.hl true))
    )
  )

; TODO: Change this to screen relative coords
(fn draw [me] 

  (let [ [cols rows] me.cell-dims ]
    (gfx-at 
      me.pos
      (each [r row (ipairs me.cells )]
        (each [c cell (ipairs row)]
          (gfx-at [(* (- c 1) 42) (* (- r 1) 42)]
                  (if cell.hl 
                    (gfx.setColor [0 1 0])
                    (gfx.setColor [0 0.3 0]))
                  (gfx.rectangle :line 2 2 38 38)
                  (cell.image:draw-at [21 21])
                  )
          )
        ))
    ))

(fn make-cell [proto]
  {
   :name proto.name
   :image proto.image
   }
  )

(fn make-cells [cols rows protos] 
  (icollect [r (range 1 rows)]
    (icollect [c (range 1 cols)]
      (make-cell (f.pick-rand protos)))))

(fn cell-protos [] 
  [
   {:name :brain :image brain}
   {:name :zap :image zap}
   {:name :blood :image blood-drop}
   {:name :moon :image moon}
   ]
  )

(fn make [pos [num-cols num-rows]] 
  (let [images (cell-protos)]
  {
   :cell-dims [num-cols num-rows]
   :cells (make-cells num-cols num-rows images)
   : pos 
   :cursor false
   :drag-begin false
   :hl false

   : update
   : draw
   }
  ))

{: make}
