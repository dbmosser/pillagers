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

# No all-caps text anywhere (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function TX(s){
  if(typeof s!=='string'||!s) return s;

'@ @'
// v28.xx (cw-nocaps-net), HIS HARD RULE (2026-10-18): "NOTHING should be in all caps -- all text shown to the player, should never ever
// ever be in all caps". One door for the whole game: every canvas fillText, measureText and every text node under #root already goes
// through TX, so the case is fixed here, once, and nothing added later can escape it. A word of 3+ letters in capitals that is not an
// acronym below becomes lower case, and its first letter stays a capital at the start of the line or after a full stop or a dot. The
// CSS line at the top of the style block takes away text-transform:uppercase for the same reason.
var NCKEEP={SP:1,XP:1,HP:1,LMG:1,SMG:1,DMR:1,KIA:1,HUD:1,FPS:1,RPG:1,LMB:1,RMB:1,MMB:1,ADS:1,DPS:1,RPM:1,KPH:1,MPH:1,PVP:1,PVE:1,NPC:1,WASD:1,FOV:1,CPU:1,GPU:1,USB:1,URL:1,HDR:1,TNT:1,UFO:1,AI:1,UI:1,LB:1,RB:1,LT:1,RT:1,LS:1,RS:1,PC:1,TV:1,ID:1,KB:1,MG:1,AR:1,SR:1};
var NCKEYS={ESC:'Esc',TAB:'Tab',ENTER:'Enter',SPACE:'Space',SHIFT:'Shift',CTRL:'Ctrl',ALT:'Alt'};
var NCC={}, NCN=0, NCRE=/[A-Za-z][A-Za-z'\u2019]*/g;
function ncCand(w,o,s){
  var n=w.replace(/['\u2019]/g,'').length;
  if(n<2||w!==w.toUpperCase()||NCKEEP[w]||/^[IVX]+$/.test(w)) return 0;
  var pv=s.charAt(o-1), nx=s.charAt(o+w.length);
  if(/\d/.test(pv)||/\d/.test(nx)) return 0;
  if(n===2&&((pv==='-'&&/\d/.test(s.charAt(o-2)))||(nx==='-'&&/\d/.test(s.charAt(o+w.length+1))))) return 0;
  return n;
}
function ncFix(s){
  if(typeof s!=='string'||s.length<2||!/[A-Z][A-Z]/.test(s)) return s;
  var c=NCC[s]; if(c!==undefined) return c;
  var low=/[a-z]/.test(s), has3=0;
  s.replace(NCRE,function(w,o){ if(ncCand(w,o,s)>=3) has3=1; return w; });
  var r=s.replace(NCRE,function(w,o){
    var n=ncCand(w,o,s); if(!n) return w;
    if(n===2&&low&&!has3) return w;
    if(NCKEYS[w]) return NCKEYS[w];
    var lw=w.toLowerCase(), b=s.slice(0,o);
    if(/^[^A-Za-z0-9]*$/.test(b)||/[.!?\u00b7|]\s*$/.test(b)) lw=lw.charAt(0).toUpperCase()+lw.slice(1);
    return lw;
  });
  if(NCN>4000){ NCC={}; NCN=0; }
  NCC[s]=r; NCN++;
  return r;
}
function TX(s){ var r=TXRAW(s); return (typeof r==='string')?ncFix(r):r; }
function TXRAW(s){
  if(typeof s!=='string'||!s) return s;
'@

SubRx @'
<style>

'@ @'
<style>
/* v28.xx (cw-nocaps-net), HIS HARD RULE (2026-10-18): never any all-caps text. The words themselves are fixed in TX (ncFix). */
*{ text-transform:none !important; }

'@

SubRx @'
<title>PILLAGERS</title>
'@ @'
<title>Pillagers</title>
'@

SubRx @'
var VER='29.10';
'@ @'
var VER='29.11';
'@

$pat = "(?m)^  now:'v29\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.11: All text shows in sentence case, never in capitals. Check 29.11 fails on v29.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
