(import-macros { : imp : req : += : -= : *= : unless } :m)
(imp v f assets fennel scenes)

(req match-engine :game.systems.match-engine)
(req ui :ui)
(req menu :ui.menu)

(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn draw [me] 
  (gfx.origin)
  (each [_ c (ipairs me.children)] (c:draw))
  )

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
        matcher (match-engine.make [10 40] [8 8])
        try-again-btn (menu.button [40 470] assets.big-font [ [1 1 1] "TRY AGAIN?"] (fn [] (retry-level me)))
        menu-btn (menu.button [40 520] assets.big-font [[1 1 0] "MAIN MENU"] (fn [] (main-menu me)))
        score-label (menu.text [20 390] assets.font [[1 1 1] "SCORE: "])
        score-txt (menu.text [85 390] assets.font "0")
        last-score-label (menu.text [20 420] assets.font [[1 1 1] "MOVE SCORE: "])
        last-score-txt (menu.text [140 420] assets.font "0")
        ui (ui.make-layer [try-again-btn menu-btn score-label score-txt last-score-label last-score-txt ])
        ]
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

