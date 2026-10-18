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

# MENUS BOUNCE ON OPEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
UIM.E={out:function(u){ u=1-u; return 1-u*u*u; },inn:function(u){ return u*u; },sm:function(u){ return u*u*(3-2*u); }};
'@ @'
// v28.xx (cw-bounce), his Q47 (2026-10-18): "livelier motion, with bounce". back is ease-out-back with c1 = 1.5: it runs past its target by 8 percent of the travel and settles (his range 6 to 10), so a window rises 24 px, then 1.9 px past, then home. Only position and slide use it; opacity never leaves 0 to 1.
UIM.E={out:function(u){ u=1-u; return 1-u*u*u; },inn:function(u){ return u*u; },sm:function(u){ return u*u*(3-2*u); },back:function(u){ var v=u-1; return 1+2.5*v*v*v+1.5*v*v; }};
'@

SubRx @'
  if(!busy){ s.a=0; s.y=16; }
  UIM.go(el,'a',1,240,'out',{full:1}); UIM.go(el,'y',0,240,'out',{full:16});
'@ @'
  if(!busy){ s.a=0; s.y=24; }   // v28.xx (cw-bounce): 24 px rise (was 16) that overshoots 8 percent
  UIM.go(el,'a',1,240,'out',{full:1}); UIM.go(el,'y',0,240,'back',{full:24});
'@

SubRx @'
q.a=0; q.y=12; UIM.go(kids[i],'a',1,240,'out',{delay:i*35}); UIM.go(kids[i],'y',0,240,'out',{delay:i*35});
'@ @'
q.a=0; q.y=16; UIM.go(kids[i],'a',1,240,'out',{delay:i*35}); UIM.go(kids[i],'y',0,240,'back',{delay:i*35});
'@

SubRx @'
UIM.go(pg,'x',0,200,'out',{full:24});
'@ @'
UIM.go(pg,'x',0,200,'back',{full:24});
'@

SubRx @'
p=0.06*Math.sin(Math.PI*u);
'@ @'
p=0.08*Math.sin(Math.PI*u); /* v28.xx (cw-bounce): the confirm pulse peaks at 1.08 (was 1.06) */
'@

SubRx @'
var VER='30.84';
'@ @'
var VER='30.85';
'@

$pat = "(?m)^  now:'v30\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.85: Menus open with a small bounce and buttons pop a little harder when pressed. Check 30.85 fails on v30.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
