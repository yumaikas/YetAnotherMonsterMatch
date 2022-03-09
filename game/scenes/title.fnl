(import-macros { : imp : req : += : -= : *= : unless } :m)
(imp v) (imp f) (imp assets) (imp fennel)

(req match-engine :game.systems.match-engine)

(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn draw [me] 
  (gfx.origin)
  (gfx.setColor [0.4 0.4 1])
  (gfx.setFont assets.font)
  (gfx.print "MONSTER MATCH" 20 20)
  (each [_ c (ipairs me.children)] (c:draw)))

(fn update [me dt]
  (if love.mouse.isJustPressed
    (do))

  (each [_ c (ipairs me.children)] (c:update dt)))

(fn make []
  (let [matcher (match-engine.make [10 40] [7 7])]
    {
     :children [matcher]
     :pos [40 40]
     :next false
     : update
     : draw
     }))

{: make}

