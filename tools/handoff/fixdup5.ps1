$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# fixdrafts5.ps1 ran twice (it stopped on a wrong anchor count the first
# time) and its idempotency guard does not fire when the new text contains
# the old, so six insertions were made twice. Each block below must occur
# exactly twice; the second copy is removed. Idempotent: once is fine.
$enc = New-Object Text.UTF8Encoding $false
function Dedupe([string]$file, [string[]]$lines) {
  $path = 'C:\claudecode\dark raiders\tools\handoff\' + $file
  $s = [IO.File]::ReadAllText($path)
  $pat = (($lines | ForEach-Object { [regex]::Escape($_) }) -join "\r?\n") + "\r?\n"
  $m = [regex]::Matches($s, $pat)
  if ($m.Count -eq 1) { Write-Output ($file + ': single, fine'); return }
  if ($m.Count -ne 2) { throw ($file + ': block occurs ' + $m.Count + ' times: ' + $lines[0].Substring(0, [Math]::Min(50, $lines[0].Length))) }
  $second = $m[1]
  $s = $s.Substring(0, $second.Index) + $s.Substring($second.Index + $second.Length)
  [IO.File]::WriteAllText($path, $s, $enc)
  Write-Output ($file + ': second copy removed')
}
Dedupe 'f1192.ps1' @("     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';")
Dedupe 'p1194.ps1' @(
  "SubRx @'",
  "  var note=document.getElementById('pausenote').value.trim();",
  "  if(note&&G){ G.tel.notes.push({t:Math.round(elapsed()),txt:note}); document.getElementById('pausenote').value=''; }",
  "  togglePauseBox(false);",
  "this.style.display='none';",
  "'@ @'",
  "  togglePauseBox(false);   // v11.94: the close banks the note",
  "this.style.display='none';",
  "'@",
  "")
Dedupe 'p1195.ps1' @(
  "SubRx @'",
  "  log:[],pack:0,contracts:[],cfg:null,lastSim:null,autoExport:true,autoDownload:false,",
  "'@ @'",
  "  log:[],pack:0,contracts:[],cfg:null,menuZoom:1.3,lastSim:null,autoExport:true,autoDownload:false,",
  "'@",
  "SubRx @'",
  "  try{ applyMenuZoom(); }catch(_am){}",
  "'@ @'",
  "  try{ applyGameOpts(); }catch(_ag2){}   // v11.95: once more here, where a loader that threw part way cannot skip it",
  "  try{ applyMenuZoom(); }catch(_am){}",
  "'@",
  "")
Dedupe 'f1196.ps1' @("       if(txt.indexOf('KILLED IN ACTION')<0) bad.push('control: the card did not open on the death');")
Dedupe 'f1197.ps1' @(
  "       // FIVE: a Medkit over running Bandages is still taken; the queue delivers only to their ceiling.",
  "       g.bag=['medkit']; p.hp=cap-20; p.healQ=25; p.healCap=cap; p.prep=null; window.__lastSay=null;",
  "       var r5=useMedical();",
  "       if(!r5||g.bag.length!==0) bad.push('a Medkit over running Bandages was refused (""'+String(window.__lastSay||'')+'"")');",
  "       p.healQ=0; p.healCap=undefined; p.prep=null;")
Dedupe 'f1198.ps1' @(
  "       var C=(typeof HUDBOX!=='undefined')&&HUDBOX.cond;",
  "       if(ln&&C&&ln.y>C.y&&ln.y<C.y+C.h) bad.push('the notes line is drawn at y '+Math.round(ln.y)+', inside the conditions panel at '+Math.round(C.y)+' to '+Math.round(C.y+C.h));")
