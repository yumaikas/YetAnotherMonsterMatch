(import-macros { : imp : req : += : -= : *= : unless } :m)
(imp v f assets fennel scenes)

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
  (each [_ c (ipairs me.children)] (c:update dt)))


(fn make []
  (let [
        me {}
        start-btn (menu.button [95 206] assets.big-font "CLASSIC" (fn [] (scenes.switch me :classic)))
        story-btn (menu.button [135 256] assets.big-font "STORY" (fn [] (scenes.switch me :story-base)))
        options-btn (menu.button [170 333] assets.big-font "OPTIONS" (fn [] (scenes.switch me :options)))
        ui (ui.make-layer [
                           (menu.text [30 30] assets.title-font [
                                                                 [1 1 0] "Y"
                                                                 [1 0.5 0.2] "A"
                                                                 [1 0.47 1] "M"
                                                                 [0.7 0.7 0.7] "M"
                                                                 ] )
                           start-btn
                           story-btn
                           options-btn
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

{: make}

