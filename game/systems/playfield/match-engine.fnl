(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp grid)
(imp v f assets scenes)
(imp flux)
(req {: iter : range} :f)
(req blood-drop :game.vectors.blood-drop)
(req zap :game.vectors.zap)
(req moon :game.vectors.moon)
(req brain :game.vectors.brain)
(req soul :game.vectors.soul)
(req wand :game.vectors.wand)
(req bone :game.vectors.bone)
(req {: view } :fennel)
(local gfx love.graphics)

; Frankenstien -> Zaps -> Pick a cell, then pick 3 colors to flood fill into and zap all of the attached cells
; Vampires -> blood -> Pick cell to turn to blood, adjacent cells of the same color on diagonals also turn to blood
; Ghouls -> souls -> Soul Eater (pick X cells to nil out for points)
; Zombies -> brains -> Telekinesis (aka drag-swap-no-match mode)
; Werewolves -> Moons -> Were-moon (can match with anything, does not fall, "eats" on match, lasts X matchess)
; Skeletons -> Bones -> Swap one of a color, swap all of the rest in the same direction, if possible
; Magicians -> wands (switch to books?) -> Fireball (screen nuke, takes the most time to build)
; 
; Bombs?

; What powerups can one get?
; 
; Dracula
; Igor


(fn set-2d [t i j v] 
  (if (= (type (. t i)) :table)
    (tset t i j v)
    (tset t i { j v })))


(fn pick-proto [protos] 
  (f.pick-rand protos))

(comment
  (when f.all? protos #($.rolled))
  (each [f (iter protos)] (set f.rolled false))

  (let [ret (f.pick-rand (f.filter.i protos #(not $.rolled)))]
    (set ret.rolled true)
    ret))

(local dirs [[0 1] [0 -1] [1 0] [-1 0]])

(fn count-in [cells [r c] dir] 
  (let [cell (cells:at r c)]
    (if cell
      (let [ [r2 c2] (v.add [r c] dir)
            next-cell (cells:at r2 c2) ]
        (if (and next-cell (= next-cell.name cell.name))
          [cell.name 2]
          [cell.name 1]
          ))
      [nil 0]
      )))

(fn sum-cell [cells r c] 
  (local color-sum {})
  (each [dir (iter dirs)]
    (let [[color num] (count-in cells (v.add [r c] dir) dir)]
      (when color
        (tset color-sum color (+ (or (?. color-sum color) 0) num)))))
  color-sum)
  

(fn get-hints [cells [nr nc]]
  (var hints [])

  (each [r (range 1 nr)]
    (each [c (range 1 nc)]
      (when (f.any? (icollect [_ num (pairs (sum-cell cells r c))] num) #(> $ 2))
        (table.insert hints [r c]))))
  hints)

; Returns a list of cells that need to be removed
; and a list of cells that need to be placed
(fn scan-board [cells [nr nc]] 
  (local lines {})
  (local cols {})

  (var has-match false)

  (each [r (range 1 nr)]
    (var line [])
    (each [c (range 1 nc)]
      (let [
            prev-cell (cells:at r (- c 1))
            cell (cells:at r c)
            same?  (and prev-cell cell (= prev-cell.name cell.name))
            streak (length line) ] 
        (if 
          (and same? (f.empty? line))
          (do 
            ; (io.write "START ")
            (table.insert line prev-cell)
            (table.insert line cell))
          same? 
          (do
            ;(io.write "MID ")
            (table.insert line cell))

          (and (not same?) (> 3 streak))
          (do
            ; (io.write "BONK ")
            (set line []))
          (and (not same?) (<= 3 streak))
          (do
            ; (io.write "END ")
            (set has-match true)
            (each [marked (iter line)]
              (let [[r c] marked.coord]
                (set-2d lines r c line)))
            (set line [])
            )
          )
        )
      )
      (when (<= 3 (length line))
        ; (io.write "END ")
        (set has-match true)
        (each [marked (iter line)]
          (let [[r c] marked.coord]
            (set-2d lines r c line))))
    )

  (each [c (range 1 nc)]
    (var line [])
    ; (print "")
    (each [r (range 1 nr)]
      (let [
            prev-cell (cells:at (- r 1) c)
            cell (cells:at r c)
            same?  (and prev-cell cell (= prev-cell.name cell.name))
            streak (length line) ] 
        (if 
          (and same? (f.empty? line))
          (do 
            ; (io.write "START ")
            (table.insert line prev-cell)
            (table.insert line cell))
          same? 
          (do
            ;(io.write "MID ")
            (table.insert line cell))

          (and (not same?) (> 3 streak))
          (do
            ; (io.write "BONK ")
            (set line []))
          (and (not same?) (<= 3 streak))
          (do
            ; (io.write "END ")
            (set has-match true)
            (each [marked (iter line)]
              (let [[r c] marked.coord]
                (set-2d cols r c line)))
            (set line [])
            )
          )
        )
      )
      (when (<= 3 (length line))
        ; (io.write "END ")
        (set has-match true)
        (each [marked (iter line)]
          (let [[r c] marked.coord]
            (set-2d lines r c line))))
    )

  {: lines 
   : cols 
   :has-changes has-match
   })

(fn in-grid? [pos dims]
  (let [[x y] pos
        [w h] dims]
    (and 
      (>= x 1)
      (>= y 1)
      (<= x w)
      (<= y h))))

(fn fall-time [dist] 
  (math.sqrt (/ (* 2 dist) 3.3)))

(fn make-cell [proto r c]
  {
   :loc [r c]
   :coord [r c]
   :name proto.name
   :image proto.image
   }
  )

(fn set-fall-grid [{: cells :cell-dims [nr nc] : protos } on-complete] 

  (var num-falling 0)

  (fn fall-done [] 
    (-= num-falling 1)
    (when (f.zero? num-falling)
      (on-complete)))

  (local needed-per-col [])

  (each [c col-iter (cells:up-by-cols)]
    (var total-fall 0)
    (each [r cell col-iter]
      (if 
        (not cell)
        (+= total-fall 1)
        (> total-fall 0)
        (let [my-fall total-fall]
          (+= num-falling 1)
          (cells:put (+ r my-fall) c cell)
          (doto
            (flux.to cell.loc (fall-time my-fall) [(+ r my-fall) c])
            (: :ease :elasticout)
            (: :onupdate (fn [p] (when (> p 0.4) (fall-done))))))))
    (tset needed-per-col c total-fall))

  (comment each [c (range nc 1 -1)]
    (var total-fall 0)
    (each [r (range nr 1 -1)]
      (if 
        (not (cells:at r c))
        (+= total-fall 1)
        (> total-fall 0)
        (let [cell (cells:at r c)
              my-fall total-fall]
          (+= num-falling 1)
          (cells:put (+ r my-fall) c cell)
          (doto 
            (flux.to cell.loc (fall-time my-fall) [(+ r my-fall) c])
            (: :ease :elasticout)
            (: :onupdate (fn [p] (when (> p 0.4) (fall-done))))
            )
      )))
    (tset needed-per-col c total-fall))

  (each [c n (ipairs needed-per-col)]
    (+= num-falling n)
    (each [r (range n 1 -1)]
      (let [cell (make-cell (pick-proto protos) (- r) c)]
        (cells:put r c cell)
        (doto (flux.to cell.loc (fall-time n) [r c])
              (: :ease :elasticout)
              (: :onupdate (fn [p] (when (> p 0.4) (fall-done))))
              )
      )
    ))

  needed-per-col)


(fn handle-scan [me scan] 
  (let [{: lines : cols } scan
        [nr nc] me.cell-dims ]


    (var num-cells 0)
    (each [r row (pairs lines)]
      (each [l line (pairs row)]
        (each [c cell (pairs line)]
          (when (not cell.matched)
            (+= num-cells  1))
          (set cell.matched true))
        )
      ) 

    (each [r row (pairs cols)]
      (each [l line (pairs row)]
        (each [c cell (pairs line)]
          (when (not cell.matched)
            (+= num-cells 1))
          (set cell.matched true))) )

    (let [now-score (math.floor (+ 
                               (* 10 num-cells) 
                               (math.max 0 (* (- num-cells 3) 20))
                               (math.max 0 (* (- num-cells 5) 50))))]
      (when (> now-score 0)
        (set me.last-score now-score)
        (+= me.score now-score)))

    (each [r c cell (me.cells:every-cell)]
      (when cell.matched
        (me.cells:put r c nil)))

    (set me.hints (get-hints me.cells me.cell-dims))
    (set me.has-moves (not (f.empty? me.hints)))
    (set-fall-grid me (fn [] (set me.scanned false)
                        (set me.hints (get-hints me.cells me.cell-dims))
                        (set me.has-moves (not (f.empty? me.hints)))
                        ))
    )
  )

(fn anim-token-from-to [loc t target]
  (doto
    (flux.to loc t target)
    (: :ease :quadinout)))

(fn update [me dt]
  (let [(mxp myp) (gfx.inverseTransformPoint (love.mouse.getPosition))
        [mx my]  (v.sub [mxp myp] me.pos)
        [c r]  [
               (math.ceil (/ mx 42))
               (math.ceil (/ my 42))
               ] 
        cell (me.cells:at r c)]

    (unless me.scanned
      (let [scan (scan-board me.cells me.cell-dims)]
        (handle-scan me scan)
        (set me.scanned true)
      ))

    (when (and love.mouse.isJustPressed)
      (if
        (and (not me.has-moves) (= c 8) (= r 8))
        (set me.failed true) 
        (and cell me.picked (<= (v.dist me.picked.coord cell.coord) 1))
        (let [a me.picked
              b cell
              [ar ac] a.coord
              [br bc] b.coord
              ] 
          (anim-token-from-to 
            a.loc 0.3 (v.copy b.coord))
          (doto
            (anim-token-from-to
              b.loc 0.3 (v.copy a.coord))
            (: :oncomplete 
               (fn [] 
                 (me.cells:put ar ac b)
                 (me.cells:put br bc a)
                 (if (. (scan-board me.cells me.cell-dims) :has-changes)
                   (set me.scanned false)
                   (do
                     (me.cells:put ar ac a)
                     (me.cells:put br bc b)
                     (doto 
                       (flux.to a.loc 0.3 (v.copy a.coord)) 
                       (: :ease :quadinout))
                     (doto 
                       (flux.to b.loc 0.3 (v.copy b.coord)) 
                       (: :ease :quadinout))))
                 ))
            )
          (when (and me.hl me.hl.hl)
            (set me.hl.hl false))
          (set me.hl false)
          (set me.picked.picked false)
          (set me.picked false)
          )
        (= cell me.picked)
        (do 
          (set cell.picked false)
          (set me.picked false))
        cell
        (do
          (when me.picked
            (set me.picked.picked false))
          (set me.picked cell)
          (set cell.picked true)
          )))

    (when me.hl
      (set me.hl.hl nil)
      (set me.hl nil))
    (when cell
      (set me.hl cell)
      (set cell.hl true))
    )
  )

(fn draw-reticle [pos] 
  (gfx-at 
    pos
    (gfx.line 0 0 4 4)
    (gfx.line 40 0 36 4)
    (gfx.line 40 40 36 36)
    (gfx.line 0 40 4 36)
  )) 

(fn draw [me] 
  (let [ [cols rows] me.cell-dims ]
    (gfx-at 
      me.pos
      (var ncell 1)
      (each [r  (range 1 rows)]
        (+= ncell 1)
        (each [c (range 1 cols)]
          (+= ncell 1)
          (let [cell (me.cells:at r c) ]
            (when cell
              (local [r c] cell.loc)
              (gfx-at [(* (- c 1) 42) (* (- r 1) 42)]
                      (if cell.offset
                        (cell.image:draw-at (v.add [21 21] cell.offset))
                        (cell.image:draw-at [21 21]))
                      (if 
                        cell.hl (gfx.setColor [0 1 0])
                        cell.matched (gfx.setColor [1 0 0])
                        cell.picked (gfx.setColor [1 1 1])
                        (gfx.setColor [0.1 0.1 0]))
                      (when (or cell.hl cell.picked) (draw-reticle [0 0]))
                      )
              )))) 
      ; Debug prints here
      (when (and me.debug me.hl)
        (let [data (sum-cell me.cells (unpack me.hl.coord))]
            (gfx.print (view data) 10 470)
            (gfx.print (view me.hl.coord) 10 440)
            ))

      )))


(fn make-cells [cols rows protos] 
  (fn on-put [r c cell]
    (when cell
      (set cell.coord [r c])))

  (let [cells (grid.make cols rows { : on-put })]
    (each [r (range 1 rows)]
      (each [c (range 1 cols)]
        (cells:put r c (make-cell (f.pick-rand protos) r c))))
    cells))


(fn cell-protos [] 
  [
   {:name :brain :image brain :rolled false}
   {:name :zap :image zap :rolled false}
   {:name :blood :image blood-drop :rolled false}
   {:name :moon :image moon :rolled false}
   {:name :soul :image soul :rolled false}
   {:name :bone :image bone :rolled false}
   {:name :wand :image wand :rolled false}
   ]
  )

(fn make [pos [num-cols num-rows]] 
  (let [images (cell-protos)
        cells (make-cells num-cols num-rows images)
        {: lines : cols } (scan-board cells [num-rows num-cols]) ]

  {
   :scanned false
   :cell-dims [num-cols num-rows]
   :protos images
   :cells cells
   :score 0
   :last-score 0
   : pos 
   :cursor false
   :has-moves true
   :drag-begin false
   :hl false
   :picked false
   :failed false
   : update
   : draw
   }
  ))

{: make}
