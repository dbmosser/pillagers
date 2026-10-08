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

# CO-OP SOUNDS PLAY ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sfx(type,wx,wy,wid){
'@ @'
// v20.40, from the whole-game bug hunt of 2026-10-08 (H52): A SOUND EVERY WINDOW MAKES FOR ITSELF IS NOT PASSED ON. sfx tells the
// party every positioned sound, which is right for a sound only this window makes. But lightning, the ring sounds and a
// teammate's hits are made on both windows, so each was heard twice in each window, a beat apart, with two rings. Those
// call sites play here only.
function sfxHere(type,wx,wy,wid){
  var on=(typeof NET==='object'&&NET), f=on?NET.fxIn:false;
  if(on) NET.fxIn=true;
  try{ sfx(type,wx,wy,wid); }finally{ if(on) NET.fxIn=f; }
}
function sfx(type,wx,wy,wid){
'@

SubRx @'
    if(!G.sim) sfx('charge',sx,sy);   // v11.59, HIS NOTE: a positioned sound marks itself
'@ @'
    if(!G.sim) sfxHere('charge',sx,sy);   // v11.59, HIS NOTE: a positioned sound marks itself; v20.40 (H52): the party makes its own from the world word
'@

SubRx @'
if(S.rm){ G.lightning=0.34; if(!G.sim) sfx('alarm',S.x,S.y); continue; }
'@ @'
if(S.rm){ G.lightning=0.34; if(!G.sim) sfxHere('alarm',S.x,S.y); continue; }
'@

SubRx @'
    G.lightning=0.34;                       // the flash the renderer has always had
    var d=dist(p,S);
    if(!G.sim) sfx('alarm',S.x,S.y);
'@ @'
    G.lightning=0.34;                       // the flash the renderer has always had
    var d=dist(p,S);
    if(!G.sim) sfxHere('alarm',S.x,S.y);   // v20.40 (H52): each window cracks its own bolt
'@

SubRx @'
if(z.pingT>=_iv){ z.pingT=0; sfx('inbound',z.x,z.y); }
'@ @'
if(z.pingT>=_iv){ z.pingT=0; sfxHere('inbound',z.x,z.y); }
'@

SubRx @'
if(dist(p,z)<1400){ sfx('touchdown',z.x,z.y); sfx('alarm',z.x,z.y);
'@ @'
if(dist(p,z)<1400){ sfxHere('touchdown',z.x,z.y); sfxHere('alarm',z.x,z.y);
'@

SubRx @'
      sfx('lastcall',z.x,z.y);   // v11.59: marks itself
'@ @'
      sfxHere('lastcall',z.x,z.y);   // v11.59: marks itself; v20.40 (H52): every window runs its own rings, so none passes its ring sounds on
'@

SubRx @'
    if(!G.sim) sfx('charge',S.x,S.y);
  }
  // v20.39, from the whole-game bug hunt
'@ @'
    if(!G.sim) sfxHere('charge',S.x,S.y);   // v20.40 (H52): heard here, never sent back to the host that sent the bolt
  }
  // v20.39, from the whole-game bug hunt
'@

SubRx @'
if(!G.sim){ if(e) sfx('alarm',e.x,e.y); if(mine) say('A crier has you. Kill it or move.'); }
'@ @'
if(!G.sim){ if(e) sfxHere('alarm',e.x,e.y); if(mine) say('A crier has you. Kill it or move.'); }
'@

SubRx @'
sfx("hit",en.x,en.y);
'@ @'
if(NET.on&&netEntsPeer()) sfxHere("hit",en.x,en.y); else sfx("hit",en.x,en.y);   // v20.40 (H52): the host plays this hit itself when it lands the round
'@

SubRx @'
if(!G.sim){ spark(e.x,e.y,e.kind==='raider'?'#ff5a4a':'#ffc25c',9,220); sfx('hit',e.x,e.y); }
'@ @'
if(!G.sim){ spark(e.x,e.y,e.kind==='raider'?'#ff5a4a':'#ffc25c',9,220); sfxHere('hit',e.x,e.y); }   // v20.40 (H52): the window that fired plays its own
'@

SubRx @'
var VER='20.39';
'@ @'
var VER='20.40';
'@

$pat = "(?m)^  now:'v20\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.40: In co-op, lightning, extraction rings and hits are heard once, not twice. Check 20.40 fails on v20.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
