(local {: view } (require :fennel))
(local data {})

{:get (fn [name] (. data name))
 :set (fn [name val] (tset data name val))
 :debug (fn [] (print (view data)))
 }
