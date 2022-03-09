(import-macros { : imp : req : += : -= : *= : unless } :m)
(imp v) (imp f)
(imp assets)
(imp fennel)
(imp scenes)

(local gfx love.graphics)

(var MODE {})

(set love.keys {})
(set love.keys.justPressed {})
(set love.keys.down {})

(fn get-window-size [] [(love.graphics.getWidth) (love.graphics.getHeight)])

(fn get-center [] (icollect [_ attr (ipairs (get-window-size))] (/ attr 2)))

(fn love.mousepressed [x y button istouch presses]
  (set love.mouse.isJustPressed true))

(fn love.mousereleased [x y button istouch]
  (set love.mouse.isJustReleased true))

(fn love.mousemoved [x y dx dy] 
  (when (or (not= dx 0) (not= dy 0))
    (set love.mouse.delta [dx dy])))

(fn love.keypressed [_ scancode isrepeat] 
  (tset love.keys.down scancode true)
  (tset love.keys.justPressed scancode true))

(fn love.keyreleased [_ scancode] 
  (tset love.keys.down scancode nil))

(var effect nil)

(fn love.load [] 
  (each [_ [name r] 
         (ipairs 
           [[:title :game.scenes.title] 
            ])]
    (scenes.set name (require r)))

  (love.math.setRandomSeed (love.timer.getTime))
  ; Make these configurable?
  (gfx.setLineStyle :rough)
  ; TODO: Switch to none
  (gfx.setLineJoin :miter)
  (gfx.setLineWidth 1)

  (let [start (scenes.get :title)]
  (set MODE (start.make true)
       )))

(fn love.draw []

  ;(love.graphics.print (love.timer.getFPS) 10 10)
  (gfx.push)
  (when MODE.draw (MODE:draw))
  (gfx.pop))

(fn love.update [dt]

  (each [k (pairs love.keys.justPressed)]
    (when (= k :escape)
      (love.event.quit))
    (tset love.keys.justPressed k nil))

  (when MODE.update (MODE:update dt))

  (set love.mouse.isJustPressed false)
  (set love.mouse.isJustReleased false)
  (set love.mouse.delta nil)

  (when MODE.next
    (set MODE MODE.next)))
