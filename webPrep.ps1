param([switch] $serve)
try {

$paths = ls | ? { -not(($_.FullName -ilike "*love-bins*") `
                    -or ($_.FullName -ilike "*.ps1") `
                    -or ($_.FullName -ilike "*publish*") `
                    -or ($_.FullName -ilike "*\projects") `
                    -or ($_.FullName -ilike "*\.git\*") `
                    ) } | % { $_.FullName; }

echo $paths

ls -Recurse .\publish\yamm\ | Remove-Item -Recurse -Force 

# New-Item .\publish\faultLines\ -ItemType Directory
Remove-Item -Recurse -Force .\publish\yamm.love
Compress-Archive $paths publish\yamm.love

Push-location publish\
"Yet Another Monster Match" | npx love.js yamm.love yamm -c -m (16777216*2)


# Uncomment once customization becomes a thing
# Copy-Item ..\projects\html\index.html .\faultLines\index.html
# Copy-Item ..\projects\html\love.css .\faultLines\love.css

cd yamm
Compress-Archive -Force (ls) ..\yamm.zip

if ($serve) {
web-dir
}
}
finally {
    Pop-location
}
# Compress-Archive (ls -Recurse) ..\CasterFightWeba.zip -Force
