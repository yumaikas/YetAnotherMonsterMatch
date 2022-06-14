(import-macros { : imp : req : += : -= : *= : unless } :m)
(imp v f assets fennel scenes)

(req match-engine :game.systems.playfield.match-engine)
(req ui :ui)
(req menu :ui.menu)

(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn draw [me] 
  (gfx.origin)
  (each [_ c (ipairs me.children)] (c:draw)))

(fn update [me dt]
  (set me.try-again-btn.enabled (not me.matcher.has-moves))
  (me.score-txt:set-text me.matcher.score)
  (me.last-score-txt:set-text me.matcher.last-score)

  (each [_ c (ipairs me.children)] (c:update dt)))

(fn retry-level [me]
  (let [n (scenes.get :classic)]
    (set me.next (n.make))))

(fn main-menu [me]
  (let [n (scenes.get :title)]
    (set me.next (n.make))))

(fn make []
  (let [
        me {}
        ui (ui.make-layer []) ]
    (f.merge!
      me 
      {
       : score-txt
       : last-score-txt
       : matcher
       : try-again-btn
       :children [matcher ui]
       :pos [40 40]
       :next false
       : update
       : draw
       })
      ))

{: make}

