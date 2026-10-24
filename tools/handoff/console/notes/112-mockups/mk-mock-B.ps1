# 112 mockup B (bare). Scratch copy only: tools\fixture.html + mock-B.js -> tools\fxmock-B.html. Never touches dark_raiders.html.
$k='B'; $root='C:\claudecode\dark raiders'
$src=[IO.File]::ReadAllText("$root\tools\fixture.html")
$js=[IO.File]::ReadAllText("$root\tools\handoff\console\notes\112-mockups\mock-$k.js")
$i=$src.LastIndexOf('</script>')
if($i -lt 0){ throw 'no </script>' }
$out=$src.Substring(0,$i+9)+"`r`n<script>`r`n"+$js+"</script>`r`n"+$src.Substring($i+9)
[IO.File]::WriteAllText("$root\tools\fxmock-$k.html",$out,(New-Object Text.UTF8Encoding($false)))
"written fxmock-$k.html"
