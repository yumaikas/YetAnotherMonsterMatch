(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp v f assets)
(req {: iter : range} :f)
(req blood-drop :game.vectors.blood-drop)
(req zap :game.vectors.zap)
(req moon :game.vectors.moon)
(req brain :game.vectors.brain)
(req {: view } :fennel)
(local gfx love.graphics)

; Frankenstien -> Zaps *
; Vampires -> blood *
; Ghouls -> souls
; Zombies -> brains *
; Werewolves -> Moons *
; Bombs?
; 
; Dracula
; Igor


(fn set-2d [t i j v] 
  (if (= (type (. t i)) :table)
    (tset t i j v)
    (tset t i { j v })))


; Returns a list of cells that need to be removed
; and a list of cells that need to be placed
(fn scan-board [cells [nr nc]] 
  (print (view [nr nc]))
  (local lines {})
  (local cols {})

  (each [r (range 1 nr)]
    (var line [])
    (print "")
    (each [c (range 1 nc)]
      (let [
            prev-cell (?. cells r (- c 1))
            cell (?. cells r c)
            same?  (and prev-cell cell (= prev-cell.name cell.name))
            streak (length line) ] 
        (if 
          (and same? (f.empty? line))
          (do 
            (io.write "START ")
            (table.insert line prev-cell)
            (table.insert line cell))
          same? 
          (do
            (io.write "MID ")
            (table.insert line cell))

          (and (not same?) (> 3 streak))
          (do
            (io.write "BONK ")
            (set line []))
          (and (not same?) (<= 3 streak))
          (do
            (io.write "END ")
            (each [marked (iter line)]
              (let [[r c] marked.loc]
                (set-2d lines r c line)))
            (set line [])
            )
          )
        )
      )
      (when (<= 3 (length line))
        (io.write "END ")
        (each [marked (iter line)]
          (let [[r c] marked.loc]
            (set-2d lines r c line))))
    )

  (each [c (range 1 nc)]
    (var line [])
    (print "")
    (each [r (range 1 nr)]
      (let [
            prev-cell (?. cells (- r 1) c)
            cell (?. cells r c)
            same?  (and prev-cell cell (= prev-cell.name cell.name))
            streak (length line) ] 
        (if 
          (and same? (f.empty? line))
          (do 
            (io.write "START ")
            (table.insert line prev-cell)
            (table.insert line cell))
          same? 
          (do
            (io.write "MID ")
            (table.insert line cell))

          (and (not same?) (> 3 streak))
          (do
            (io.write "BONK ")
            (set line []))
          (and (not same?) (<= 3 streak))
          (do
            (io.write "END ")
            (each [marked (iter line)]
              (let [[r c] marked.loc]
                (set-2d cols r c line)))
            (set line [])
            )
          )
        )
      )
      (when (<= 3 (length line))
        (io.write "END ")
        (each [marked (iter line)]
          (let [[r c] marked.loc]
            (set-2d lines r c line))))
    )

  {
   : lines 
   : cols 
   }
  )

(fn update [me dt]
  (let [(mxp myp) (gfx.inverseTransformPoint (love.mouse.getPosition))
        [mx my]  (v.sub [mxp myp] me.pos)
        [c r]  [
               (math.ceil (/ mx 42))
               (math.ceil (/ my 42))
               ] 
        cell (?. me.cells r c)
        ]
    (when me.hl
      (set me.hl.hl nil))
    (when cell
      (set me.hl cell)
      (set cell.hl true))
    )
  )

; TODO: Change this to screen relative coords
(fn draw [me] 

  (let [ [cols rows] me.cell-dims ]
    (gfx-at 
      me.pos
      (each [r row (ipairs me.cells )]
        (each [c cell (ipairs row)]
          (gfx-at [(* (- c 1) 42) (* (- r 1) 42)]
                  (if 
                    cell.hl (gfx.setColor [0 1 0])
                    cell.matched (gfx.setColor [1 0 0])
                    (gfx.setColor [0 0.3 0]))
                  (gfx.rectangle :line 2 2 38 38)
                  (cell.image:draw-at [21 21])
                  )
          )
        )
      (when me.hl
        (gfx.print (view me.hl.loc) 20 460)
        (gfx.print (view me.hl.matched) 20 480)
        (gfx.print (view me.hl.name) 20 500)
        )
      )
    ))

(fn make-cell [proto r c]
  {
   :loc [r c]
   :name proto.name
   :image proto.image
   }
  )

(fn make-cells [cols rows protos] 
  (icollect [r (range 1 rows)]
    (icollect [c (range 1 cols)]
      (make-cell (f.pick-rand protos) r c))))


(fn cell-protos [] 
  [
   {:name :brain :image brain}
   {:name :zap :image zap}
   {:name :blood :image blood-drop}
   {:name :moon :image moon}
   ]
  )

(fn make [pos [num-cols num-rows]] 
  (let [images (cell-protos)
        cells (make-cells num-cols num-rows images)
        {: lines : cols } (scan-board cells [num-rows num-cols]) ]

    (each [r row (pairs lines)]
      (each [l line (pairs row)]
        (each [c cell (pairs line)]
          (set cell.matched true)))) 
    (each [r row (pairs cols)]
      (each [l line (pairs row)]
        (each [c cell (pairs line)]
        (set cell.matched true)))) 

  {
   :cell-dims [num-cols num-rows]
   :cells cells
   : pos 
   :cursor false
   :drag-begin false
   :hl false

   : update
   : draw
   }
  ))

{: make}
