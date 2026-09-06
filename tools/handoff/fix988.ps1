$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# v11.58 harness repair. Check 9.88's first control required the whole bottom
# band of the HUD canvas to be blank with the belt dial off, and used that as
# proof that the pixels it had counted were the belt. That was only ever true
# because the floor HUD was being erased every frame; with v11.58 the floor's
# own teaching line lives in that band, so the control fired on correct
# behaviour. It measures the belt's OWN cells now and requires the paint in
# them to collapse when the dial goes off, which is what it was always trying
# to prove.
$f = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($f)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(60,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
     var hb=__hubBelt();
'@ @'
     var hb=__hubBelt(), cellsOn=null, paintedOn=0;
'@

SubRx @'
       for(var c=0;c<hb.cells.length;c++) painted+=opaqueIn(hb.cells[c]);
'@ @'
       for(var c=0;c<hb.cells.length;c++) painted+=opaqueIn(hb.cells[c]);
       cellsOn=hb.cells.slice(); paintedOn=painted;
'@

SubRx @'
     if(opaqueIn({x:0,y:H-170,w:W,h:160})>0)
       bad.push('control: with hubBelt off the bottom of the HUD canvas still holds paint');
'@ @'
     // v11.58: this used to require the whole bottom band to be blank, which was
     // only true while the floor HUD was erased every frame. It measures the
     // belt's OWN cells now and requires their paint to collapse.
     if(cellsOn&&cellsOn.length){
       var offInk=0; for(var c2=0;c2<cellsOn.length;c2++) offInk+=opaqueIn(cellsOn[c2]);
       if(offInk>paintedOn*0.2)
         bad.push('control: with hubBelt off the belt cells still hold '+offInk+' opaque pixels against '+paintedOn+' with it on, so what was measured is not the belt');
     }
'@

if ($n -ne 3) { throw "expected 3 edits, made $n" }
[IO.File]::WriteAllText($f, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied to the live fixture source"
