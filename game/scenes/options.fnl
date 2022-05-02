(import-macros { : imp : req : += : -= : *= : unless } :m)
(imp v f assets fennel scenes)

(req ui :ui)
(req menu :ui.menu)
(req opts :game.systems.options)

(local random love.math.random)
(local noise love.math.noise)
(local gfx love.graphics)

(fn draw [me] 
  (gfx.origin)
  (each [_ c (ipairs me.children)] (c:draw))
  )

(fn update [me dt]
  (each [_ c (ipairs me.children)] (c:update dt)))

(local schemes [:arcade :low-contrast :arcade])

(fn switch-color [] 
  (let [i (+ 1 (f.index-of schemes (opts.scheme)))]
    (opts.set-scheme (. schemes i))))

(fn make []
  (let [
        me {}
        ui (ui.make-layer [
                           (menu.text [30 30] 
                                      assets.title-font 
                                      [
                                       [1 0.5 0.2] "C"
                                       [1 0.47 1] "U"
                                       [0.7 0.7 0.7] "S"
                                       [1 1 0] "T"
                                       [1 0.47 1] "!"
                                       ])
                           (menu.button [80 160] assets.big-font [[1 1 1] "COLOR!"] #(switch-color))
                           (menu.button [110 240] assets.big-font "BACK" #(scenes.switch me :title))

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

