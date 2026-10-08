$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# A PLAYSTATION PAD IS TOLD ITS OWN BUTTONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function padBodyCls(){ var on=!!(PAD&&PAD.on); if(PAD._bodyOn!==on){ PAD._bodyOn=on; try{ document.body.classList.toggle('padon',on); }catch(_b){} } }
'@ @'
// v19.86, from the code review of 2026-10-08: on a PlayStation pad the stash pad row (v19.70) named Xbox buttons. The row is written
// through padB whenever the pad comes or goes or its make changes, as the canvas hints are.
function padBodyCls(){ var on=!!(PAD&&PAD.on), r; if(PAD._bodyOn!==on||PAD._bodyBr!==PAD.brand){ PAD._bodyOn=on; PAD._bodyBr=PAD.brand; try{ document.body.classList.toggle('padon',on); }catch(_b){} try{ r=document.getElementById('invkeybarpad'); if(r){ if(!r.dataset.src) r.dataset.src=r.innerHTML; r.innerHTML=padB(r.dataset.src); } }catch(_r){} } }
'@

SubRx @'
return '<b style="color:var(--bone)">'+r[0]+'</b> '+r[1]; }
'@ @'
return '<b style="color:var(--bone)">'+padB(r[0])+'</b> '+r[1]; }   /* v19.86, code review: through padB, so a PlayStation pad reads SQUARE reload as the H panel does */
'@

SubRx @'
var VER='19.85';
'@ @'
var VER='19.86';
'@

$pat = "(?m)^  now:'v19\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.86: On a PlayStation controller the pause box and the stash name the PlayStation buttons. Check 19.86 fails on v19.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
