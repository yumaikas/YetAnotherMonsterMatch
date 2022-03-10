(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp v f assets fennel)
(req {: iter : range} :f)
(req blood-drop :game.vectors.blood-drop)
(req zap :game.vectors.zap)
(local gfx love.graphics)

; Frankenstien -> Zaps
; Vampires -> blood
; Ghouls -> souls
; Zombies -> brains
; Werewolves -> Moons
; Dracula
; Igor


(fn update [me dt]
  (do)
  )

; TODO: Change this to screen relative coords
(fn draw [me] 

  (let [ [cols rows] me.cell-dims 
        images [blood-drop zap]
        ]
    (gfx-at 
      me.pos
      (each [r row (ipairs me.cells )]
        (each [c cell (ipairs row)]
          (gfx-at [(* (- c 1) 42) (* (- r 1) 42)]
                  (gfx.setColor [0 0.3 0])
                  (gfx.rectangle :line 2 2 38 38)
                  (cell.image:draw-at [13 7])
                  )
          )
        ))
    ))

(fn make-cell [image]
  {
   : image
   }
  )

(fn make-cells [cols rows images] 
  (icollect [r (range 1 rows)]
    (icollect [c (range 1 cols)]
      (make-cell (f.pick-rand images)))))

(fn make [pos [num-cols num-rows]] 
  (let [images [blood-drop zap]]
  {
   :cell-dims [num-cols num-rows]
   :cells (make-cells num-cols num-rows images)
   : pos 
   :cursor false
   :drag-begin false

   : update
   : draw
   }
  ))

{: make}
