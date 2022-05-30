(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp grid)
(imp v f assets scenes)
(imp flux)
(req {: view } :fennel)
(local gfx love.graphics)


(fn draw-reticle [pos] 
  (gfx-at 
    pos
    (gfx.line 0 0 4 4)
    (gfx.line 40 0 36 4)
    (gfx.line 40 40 36 36)
    (gfx.line 0 40 4 36)
  )) 

(fn draw [me] 

  )

(fn update [me dt]
  (let [(mxp myp) (gfx.inverseTransformPoint (love.mouse.getPosition))
        [mx my] (v.sub [mxp myp] me.pos)
        [c r] [
               (math.ceil (/ mx 42))
               (math.ceil (/ my 42))
               ]
        ]

  ))

(fn make [pos grid]
  {
   : grid
   : hl-coord nil
   : update
   : draw
   }
  )
