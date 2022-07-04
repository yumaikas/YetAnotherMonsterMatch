(fn load-level [path ...]
  (let [lvl (require (.. "game.levels." (table.concat path ".")))]
    (lvl.make ...)))

 { :load load-level }
