(local {: view } (require :fennel))
(local data {})

{
 :get (fn [name] (. data name))
 :set (fn [name val] (tset data name val))
 :switch (fn [me name] 
           (let [s (. data name)]
             (if s
               (set me.next (s.make))
               (error (.. "Tried to switch to scene " name " that doesn't exist!")))))
 :debug (fn [] (print (view data)))
 }
