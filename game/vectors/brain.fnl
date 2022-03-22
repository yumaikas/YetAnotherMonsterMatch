(import-macros { : imp : req : += : -= : *= : unless : gfx-at } :m)
(imp vectron)
(req {: color-of-hex} :vectron)

(let [pink (color-of-hex "D5A7A7")]
(vectron.center-norm
[   
 { :color pink :points [ 204 212 206 206 204 206 194 205 185 202 213 205 216 200 213 199 208 200 212 199 214 192 209 189 203 187 203 190 199 186 195 190 188 194 184 202 ] }  { :color pink :points [ 205 191 201 194 196 189 ] }  { :color pink :points [ 210 197 206 197 205 193 200 195 207 199 207 204 ] }  { :color pink :points [ 192 197 193 192 195 197 198 198 189 200 202 201 ] } ]))
