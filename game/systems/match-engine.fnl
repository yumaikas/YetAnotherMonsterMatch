(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp v f assets fennel)
(req {: iter : range} :f)
(req blood-drop :game.vectors.blood-drop)
(req zap :game.vectors.zap)
(req moon :game.vectors.moon)
(req brain :game.vectors.brain)
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
(fn scan-board [cells] 
  (local [nr nc] cells.dims)
  (local lines {})
  (local cols {})

  (each [r (range 1 nr)]
    (var line [])
    (each [c (range 1 nc)]
      (let [
            prev-cell (?. cells r (- 1 c))
            cell (?. cells r c)
            same? 
            (and prev-cell cell (= prev-cell.name cell.name))
            streak (length line) ] 
        (if 
          (and same? (f.empty? line))
          (do 
            (table.insert line prev-cell)
            (table.insert line cell))

          same?  (table.insert line cell)

          (and (not same?) (>= 3 streak))
          (each [marked (iter line)]
            (set-2d lines (unpack marked.loc) line))
          )
        )
      ))

  (each [c (range 1 nc)]
    (var col [])
    (each [r (range 1 nr)]
      (let [
            prev-cell (?. cells (- r 1) c)
            cell (?. cells r c)
            same? 
            (and prev-cell cell (= prev-cell.name cell.name))
            streak (length col) ] 
        (if 
          (and same? (f.empty? col))
          (do 
            (table.insert col prev-cell)
            (table.insert col cell))

          same?  (table.insert cols cell)

          (and (not same?) (>= 3 streak))
          (each [marked (iter col)]
            (set-2d cols (unpack marked.loc) col))
          )
        )
      ))
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
                  (if cell.hl 
                    (gfx.setColor [0 1 0])
                    (gfx.setColor [0 0.3 0]))
                  (gfx.rectangle :line 2 2 38 38)
                  (cell.image:draw-at [21 21])
                  )
          )
        ))
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
      (make-cell (f.pick-rand protos r c)))))

(fn cell-protos [] 
  [
   {:name :brain :image brain}
   {:name :zap :image zap}
   {:name :blood :image blood-drop}
   {:name :moon :image moon}
   ]
  )

(fn make [pos [num-cols num-rows]] 
  (let [images (cell-protos)]
  {
   :cell-dims [num-cols num-rows]
   :cells (make-cells num-cols num-rows images)
   : pos 
   :cursor false
   :drag-begin false
   :hl false

   : update
   : draw
   }
  ))

{: make}
