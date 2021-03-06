(import-macros { : imp : req : += : -= : *= : unless } :m)
(imp v f assets fennel scenes)

(req ui :ui)
(req menu :ui.menu)
(req levels :game.systems.levels)
(req progress :game.systems.progressdb)

(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn draw [me] 
  (gfx.origin)
  (each [_ c (ipairs me.children)] (c:draw)))

(fn update [me dt]
  (each [_ c (ipairs me.children)] (c:update dt)))


(fn make []
  (let [
        me {}
        progress (progress.get)
        ui (ui.make-layer [ ])
        ]
    (f.merge! 
      me 
      {
       :children [ui]
       :next (match progress.last-level
               [ :intro 1 ] 
               (levels.load [ :intro 1 ])
               false)
       : update
       : draw
       })))

{: make}

