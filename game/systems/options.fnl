(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp f)
(req {: view } :fennel)
(req {: color-of-hex} :vectron)
(req brain :game.vectors.brain)
(req blood :game.vectors.blood-drop)
(req zap :game.vectors.zap)
(req bone :game.vectors.bone)
(req moon :game.vectors.moon)
(local fs love.filesystem)

(local arcade
  {
   :clear [0 0 0]
   ; Missing: Soul, need to figure it out later
   :brain [1 0.47 1]
   :blood [1 0 0]
   :moon [1 0.5 0.2]
   :zap [1 1 0]
   :bone [0.77 0.78 0.8]
   })

(local low-contrast
  {
   :clear [0.1 0.1 0.1]
   :brain (color-of-hex "D5A7A7")
   :blood (color-of-hex "880022")
   :moon (color-of-hex "C07B44")
   :zap [0.7 0.7 0]
   :bone (color-of-hex "5D5E60")
   })

(fn load-settings []
  (if (fs.getInfo "settings.txt")
    (let [(settings n) (fs.read "settings.txt") ]
      (collect [k v (settings:gfind "(%S+)[\t ]+(%S+)")]
               k v))
    {}))

(fn save-settings [settings]
  (let [results []]
    (each [k v (pairs settings)]
      (table.insert results (.. k " "))
      (table.insert results (.. v "\r\n")))
    (fs.write "settings.txt" (table.concat results "")))
  )

(local options 
    { :colors { : arcade : low-contrast } }) 

(fn apply-settings [settings]
  (let [scheme (. options.colors settings.scheme)]
    (brain:map-color (fn [c] scheme.brain))
    (blood:map-color (fn [c] scheme.blood))
    (bone:map-color (fn [c] scheme.bone))
    (zap:map-color (fn [c] scheme.zap))
    (moon:map-color (fn [c] scheme.moon))
    ))

(local settings
  (let [
        derp (load-settings)
        ret (f.merge!  { :scheme :low-contrast } derp)]
    (apply-settings ret)
    ret))

(fn set-scheme [to] 
  (set settings.scheme to)
  (save-settings settings)
  (apply-settings settings))

{
 :colors (fn [] (. options.colors settings.scheme))
 :scheme (fn [] settings.scheme)
 :set-scheme (fn [scheme] (if (. options.colors scheme)
                           (set-scheme scheme)
                           (error (.. "Unknown color scheme " scheme))))
}
