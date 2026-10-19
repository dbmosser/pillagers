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

# A KEYBOARD MARKER ON THE WINDOW THE KEYS PLAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netPadFocused(){
'@ @'
// v31.xx (cw-kbmark), HIS ANSWER 3.5 c (2026-10-18): "as ordered, plus a marker on each screen showing where the keyboard is". With two windows paired,
// the one in front (the one the keys play, cw-p2keys) wears a small "keyboard" chip in its top left corner; the other wears none.
function kbMarkWant(same,partnerUp,focused){
  if(!focused) return false;
  if(same==='p2') return true;
  return same==='host'&&!!partnerUp;
}
function kbMarkSet(on){
  if(typeof document==='undefined'||!document.body) return false;
  var e=document.getElementById('kbmark');
  if(!e){
    if(!on) return false;
    e=document.createElement('div'); e.id='kbmark'; e.textContent='keyboard';
    e.style.cssText='position:fixed;left:10px;top:6px;z-index:60;pointer-events:none;font:700 16px/1 system-ui,Segoe UI,Arial,sans-serif;letter-spacing:1px;text-transform:none;color:#7fc4a0;background:rgba(6,9,13,.72);border:1px solid rgba(127,196,160,.6);border-radius:4px;padding:4px 8px;display:none';
    document.body.appendChild(e);
  }
  e.style.display=on?'block':'none';
  return !!on;
}
function kbMarkTick(){
  var up=false;
  try{ up=!!(typeof NET==='object'&&NET&&NET.same==='host'&&NET.p2win&&!NET.p2win.closed); }catch(_k){}
  var on=false; try{ on=kbMarkWant((typeof NET==='object'&&NET)?NET.same:'',up,netPadFocused()); }catch(_k2){}
  return kbMarkSet(on);
}
try{ if(typeof setInterval==='function') setInterval(function(){ try{ kbMarkTick(); }catch(_kt){} },500); }catch(_ki){}
function netPadFocused(){
'@

SubRx @'
var VER='31.80';
'@ @'
var VER='31.81';
'@

$pat = "(?m)^  now:'v31\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.81: With two windows paired, the one in front shows a small keyboard chip in its top left corner. Check 31.81 fails on v31.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
