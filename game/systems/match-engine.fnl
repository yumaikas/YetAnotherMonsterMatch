(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp v) (imp f)
(req {: iter : range} :f)
(imp assets)
(imp fennel)
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

  (let [ [cols rows] me.cell-dims ]
    (gfx-at 
      me.pos
      (each [r (range 0 rows)]
        (each [c (range 0 cols)]
          (gfx-at [(* c 42) (* r 42)]
                  (gfx.setColor [0 1 0])
                  (gfx.rectangle :line 2 2 38 38))
          )
        ))
    ))

(fn make [pos [num-cols num-rows]] 
  {
   :cell-dims [num-cols num-rows]
   : pos 
   :cursor false
   :drag-begin false

   : update
   : draw
   }
  )

{: make}
