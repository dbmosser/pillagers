$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
# ==== THE THIRD FONT IS THE 23 ON THE SHIRT, and it is art rather than menu text.
# ==== Traced by ancestor: SPAN inside SPAN inside a costile inside
# ==== #appavatarpicker, which is the clothing rack in the Fashion window. The
# ==== numeral on a jersey swatch is set in Impact on purpose, the way a number on
# ==== a shirt is, and the canvas draws its own 23 as rectangles rather than as
# ==== text at all. Named as an exception by WHERE IT LIVES, since the span itself
# ==== carries no class to name it by.
SubRx @'
       if(typeof c==='string'&&c.indexOf('avnum')>=0) return true;   // the 23 on the shirt
'@ @'
       if(typeof c==='string'&&c.indexOf('avnum')>=0) return true;   // the 23 on the shirt
       // and the same numeral wherever the racks draw it: the figure and the
       // swatches, both inside the Fashion window.
       var up=el, g=0;
       while(up&&g++<10){
         if(up.id==='appavatar'||up.id==='appavatarpicker') return true;
         up=up.parentElement;
       }
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
