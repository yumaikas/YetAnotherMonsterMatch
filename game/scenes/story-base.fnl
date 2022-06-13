(import-macros { : imp : req : += : -= : *= : unless } :m)
(imp v f assets fennel scenes)

(fn make [] 
  {
   :update (fn [me dt] 
             (scenes.switch me :character-picker)
             )
   }
  )

{ : make }
