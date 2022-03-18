param([switch] $serve)
try {

$paths = ls | ? { -not(($_.FullName -ilike "*love-bins*") `
                    -or ($_.FullName -ilike "*.ps1") `
                    -or ($_.FullName -ilike "*publish*") `
                    -or ($_.FullName -ilike "*\projects") `
                    -or ($_.FullName -ilike "*\.git\*") `
                    ) } | % { $_.FullName; }

echo $paths

ls -Recurse .\publish\faultLines\ | Remove-Item -Recurse -Force 

# New-Item .\publish\faultLines\ -ItemType Directory
Remove-Item -Recurse -Force .\publish\faultLines.love
Compress-Archive $paths publish\faultLines.love

Push-location publish\
"Yet Another Monster Match" | npx love.js faultLines.love faultLines -c -m (16777216*2)


# Uncomment once customization becomes a thing
# Copy-Item ..\projects\html\index.html .\faultLines\index.html
# Copy-Item ..\projects\html\love.css .\faultLines\love.css

cd faultLines
Compress-Archive -Force (ls) ..\faultLines.zip

if ($serve) {
web-dir
}
}
finally {
    Pop-location
}
# Compress-Archive (ls -Recurse) ..\CasterFightWeba.zip -Force
