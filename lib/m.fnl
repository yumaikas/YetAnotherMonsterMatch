(fn check [exp err]
  `(or ,exp (error ,err)))

(fn each-in [ident tbl ...]
  `(let [tbl# ,tbl]
     (for [i# 1 (length tbl#)]
       (local ,ident (. tbl# i#))
       ,...)))

(fn += [x expr] `(set ,x (+ ,x ,expr)))

(fn -= [x expr] `(set ,x (- ,x ,expr)))

(fn *= [x expr] `(set ,x (* ,x ,expr)))

(fn imp [...]
  (let [names [...]
        binds (icollect [_ n (ipairs names) :into `[]] n)
        reqs (icollect [_ n (ipairs names) :into `[]] `(require ,(tostring n)))
        ] 

  `(local ,binds ,reqs)))

(fn req [name path]
  `(local ,name (require ,path)))

(fn unless [pred ...]
  `(when (not ,pred)
       ,...))

(fn gfx-at [pos ...] 
  (let [body (icollect [_ i (ipairs [...]) :into 
              `(let [[x# y#] ,pos]
                 (love.graphics.push)
                 (love.graphics.translate x# y#))] i)]
    (table.insert body `(love.graphics.pop))
    body))

{: check : each-in  : += : -= : *= : unless : imp : req : gfx-at}
