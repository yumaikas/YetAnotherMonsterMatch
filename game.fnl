(import-macros { : imp : req : += : -= : *= : unless } :m)
(imp v f flux assets fennel scenes)
(req options :game.systems.options)

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

(var init-off [0 0])

(fn love.load [] 
  (let [(sx sy) (love.window.getSafeArea)]
    (set init-off [sx sy]))
   
  (each [_ p (ipairs (love.filesystem.getDirectoryItems "game/scenes"))]
    (let [(_ _ name) (p:find "([-%w]+)%.fnl$")]
      (scenes.set name (require (.. "game.scenes." name)))))

  ; Make these configurable?
  (gfx.setLineStyle :smooth)
  ; TODO: Switch to none
  (gfx.setLineJoin :none)
  (gfx.setLineWidth 2)

  (let [start (scenes.get :title)]
  (set MODE (start.make true)
       )))

(fn love.draw []

  ;(love.graphics.print (love.timer.getFPS) 10 10)
  (gfx.push)
  (gfx.translate (. init-off 1) (. init-off 2))
  (gfx.clear (. (options.colors) :clear))

  (when MODE.draw (MODE:draw))
  (gfx.pop))

(fn love.update [dt]

  (when (. love.keys.justPressed :escape)
    (love.event.quit))

  (flux.update dt)
  (when MODE.update (MODE:update dt))

  (set love.mouse.isJustPressed false)
  (set love.mouse.isJustReleased false)
  (set love.mouse.delta nil)

  (each [k (pairs love.keys.justPressed)]
    (tset love.keys.justPressed k nil))

  (when MODE.next
    (set MODE MODE.next)))
