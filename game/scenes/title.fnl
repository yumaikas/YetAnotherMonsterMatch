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

(fn start-classic [me]
  (let [n (scenes.get :classic)]
    (set me.next (n.make))))

(fn make []
  (let [
        me {}
        start-btn (menu.button [80 200] assets.big-font "PLAY" (fn [] (start-classic me)))
        ui (ui.make-layer [
                           (menu.text [30 30] assets.title-font [
                                                                 [1 1 0] "Y"
                                                                 [1 0.5 0.2] "A"
                                                                 [1 0.47 1] "M"
                                                                 [0.7 0.7 0.7] "M"
                                                                 ] )
                           start-btn])
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

