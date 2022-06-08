(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp grid)
(imp v f assets scenes)
(imp flux)
(req {: view } :fennel)
(local gfx love.graphics)


(fn draw-reticle [pos] 
  (gfx-at 
    pos
    (gfx.line 0 0 4 4)
    (gfx.line 40 0 36 4)
    (gfx.line 40 40 36 36)
    (gfx.line 0 40 4 36)
  )) 

(fn draw [me] 
  (each [r c cell (me.state:every-set-cell)]
    (if
      (?. cell :picked)
      (gfx-at [(* (- c 1) 42) (* (- r 1) 42)]
              (gfx.setColor [1 1 1])
              (draw-reticle [0 0]))
      (?. cell :hl)
      (gfx-at [(* (- c 1) 42) (* (- r 1) 42)]
              (gfx.setColor [0 1 0])
              (draw-reticle [0 0]))))
  )

(fn unpick [cell] 
  (when cell
    (set cell.picked nil))
  cell)

(fn highlight-cell [cell]
  (let [c (or cell {})]
    (set c.hl true)
    c))

(fn update [me dt]
  ; clear HL cells in the cursor
  (each [r c cell (me.state:every-set-cell)]
    (when (and cell.hl (not cell.picked))
      (me.state:put r c nil)))

  (let [(mxp myp) (gfx.inverseTransformPoint (love.mouse.getPosition))
        [mx my]  (v.sub [mxp myp] me.pos)
        [c r]  [
               (math.ceil (/ mx 42))
               (math.ceil (/ my 42))
               ] 
        cursor (me.state:update r c highlight-cell)
        ]

    ; Make sure that we have a cursor present to handle these clicks
    (when (and love.mouse.isJustPressed cursor)
      (set cursor.picked true)
      (var b nil)
      (each [ir ic cell (me.state:around-point r c)]
        (when (and (not b) (?. cell :picked))
          (set b [ir ic])))

      (when b
        (let [[ir ic] b]
          (me.state:update r c unpick)
          (me.state:update ir ic unpick)
          (me.submit-moves [[:swap [r c] [ir ic]]])))

      ; Clear :picked on any cell that is not the currently picked cell
      (each [ir ic cell (me.state:every-set-cell)]
        (when (and 
                (?. cell :picked)
                (not= cell cursor))
          (me.state:update ir ic unpick)))
      )

  ))

(fn make [pos board submit-moves]
  (let [ [w h] (board:dims)]
    {
     :state (grid.make w h)
     : pos
     : board
     : submit-moves
     : update
     : draw
     }))

{ : make }
