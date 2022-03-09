-- bootstrap the compiler
fennel = require("fennel")
table.insert(package.loaders, fennel.make_searcher({correlate=true}))
pp = function(x) print(fennel.view(x)) end

local make_love_searcher = function(env)
   return function(module_name)
      local path = module_name:gsub("%.", "/") .. ".fnl"
      local folderPath = module_name:gsub("%.", "/") .. "/init.fnl"
      local libPath = "lib/" .. module_name:gsub("%.", "/") .. ".fnl"
      local libFolderPath = "lib/" .. module_name:gsub("%.", "/") .. "/init.fnl"

      if love.filesystem.getInfo(path) then
         return function(...)
            local code = love.filesystem.read(path)
            return fennel.eval(code, {env=env}, ...)
         end, path
      end
      if love.filesystem.getInfo(folderPath) then
         return function(...)
            local code = love.filesystem.read(folderPath)
            return fennel.eval(code, {env=env}, ...)
         end, folderPath
      end
      if love.filesystem.getInfo(libPath) then
         return function(...)
            local code = love.filesystem.read(libPath)
            return fennel.eval(code, {env=env}, ...)
         end, libPath
      end
      if love.filesystem.getInfo(libFolderPath) then
         return function(...)
            local code = love.filesystem.read(libFolderPath)
            return fennel.eval(code, {env=env}, ...)
         end, libFolderPath
      end
   end
end

table.insert(package.loaders, make_love_searcher(_G))
table.insert(fennel["macro-searchers"], make_love_searcher("_COMPILER"))
