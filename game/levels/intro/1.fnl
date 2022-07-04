(import-macros { : imp : req : += : -= : *= : unless } :m)
(imp v f assets fennel scenes)

(req ui :ui)
(req menu :ui.menu)
(req progress :game.systems.progressdb)

(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn draw [me] 
  (gfx.origin)
  (each [_ c (ipairs me.children)] (c:draw)))

(fn complete-intro [me]
  (progress.update 
    (fn [db] 
      (set db.levels.zeke.unlocked true)
      (set db.modes.quick true)))
  (scenes.switch me :title))

(fn update [me dt]
  (each [_ c (ipairs me.children)] (c:update dt)))

(fn make []
  (let [
        me {}
        progress (progress.get)
        ui (ui.make-layer [ 
                           (menu.text [30 30] assets.big-font "Intro")
                           (menu.button [40 70] assets.big-font 
                                        [[1 1 0] "We haven't met"] 
                                        (fn [] (complete-intro me)))
                           ])
        ]
    (f.merge! 
      me 
      {
       :children [ui]
       :next false
       : update
       : draw
       })))

{: make }
