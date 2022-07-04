(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp f json)
(req { : view } :fennel)

(local fs love.filesystem)

(fn progress-proto [] 
  {
   :last-level [ :intro 1 ]
   :modes { :quick false }
   :levels {
     :intro { :unlocked true }
     :gina { :unlocked false }
     :zeke { :unlocked false }
     :wilma { :unlocked false }
     :walton { :unlocked false }
     :sally { :unlocked false }
     :sam { :unlocked false }
     :victor { :unlocked false } }
   }
  )

(fn load-db []
  (if 
    (fs.getInfo "progress.sav")
    (let [(str n) (fs.read "progress.sav") 
          (ok val) (pcall #(json.decode str)) ]
      (print (view [ok val]))
      (if ok val {}))
    {}))

(fn save-db [progress] 
  (let [to-save (json.encode progress)]
    (fs.write "progress.sav" to-save)))

(fn update [fun]
  (let [saved (load-db)
        full-progress (f.merge! (progress-proto) saved)]
      (fun full-progress)
      (save-db full-progress)
      full-progress))

(fn get [] 
  (let [db (f.merge! (progress-proto) (load-db))]
    (print (view db))
    db))

{ : update : get }
