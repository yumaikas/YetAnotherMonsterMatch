(import-macros { : imp : req : += : -= : *= : unless } :m)
(imp v f assets fennel scenes)
(req { : view } :fennel)

(req fennel :fennel)
(req progress :game.systems.progressdb)

(req { : merge! } :f)

(req ui :ui)
(req menu :ui.menu)

(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn draw [me] 
  (gfx.origin)
  (each [_ c (ipairs me.children)] (c:draw)))


(fn load-settings [me]
  (let [(ok val) (pcall #(fennel.dofile (.. "./game/scenes/.title-ui-nowatch.fnl")))]
    (when ok
      (each [k v (pairs val)]
        (merge! (. me.ui-merge k) v)))
    (when (not ok)
      (print (view val)))))

(fn update [me dt]
  (each [_ c (ipairs me.children)] (c:update dt))
  (when (. love.keys.justPressed :r)
    (load-settings me)))

(fn make []
  (let [
        me {}
        progress (progress.get)
        start-btn (menu.button [95 206] assets.big-font "QUICK" (fn [] (scenes.switch me :classic)))
        story-btn (menu.button [130 140] assets.big-font "STORY" (fn [] (scenes.switch me :story-base)))
        options-btn (menu.button [170 333] assets.big-font "OPTIONS" (fn [] (scenes.switch me :options)))
        title-txt (menu.text [30 30] assets.title-font [ [0 1 0] "Zeke's\n"
                                                         [1 0.5 0.2] "Zoodle\n"
                                                         [1 0.47 1] "Incident"] )

        ui (ui.make-layer [title-txt
                           (when progress.modes.quick start-btn)
                           story-btn
                           options-btn
                           ])
        ]
    (doto
      me
      (f.merge! 
      {
       :children [ui]
       :next false
       :ui-merge { : start-btn : story-btn : options-btn }
       : update
       : draw
       })
      (load-settings)
      )
    ))

{: make}

