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

# TEAM LAMP AND HIRE BAND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
          {own:e2,team:'foe',moving:!!e2.moving,
'@ @'
          {own:e2,team:(e2.merc||e2.friendly)?'ally':'foe',merc:e2.merc?1:0,moving:!!e2.moving,
'@

SubRx @'
  if(_BLD==='broad') wc.fillRect(x-8.2+leanX,ty-18,16.4,2.4); else if(!_BLD) wc.fillRect(x-6.5+leanX,ty-18,13,2.4);   // v20.01: wider on Broad; Curved wears a belt instead
  }
'@ @'
  if(_BLD==='broad') wc.fillRect(x-8.2+leanX,ty-18,16.4,2.4); else if(!_BLD) wc.fillRect(x-6.5+leanX,ty-18,13,2.4);   // v20.01: wider on Broad; Curved wears a belt instead
  }
  // v23.xx (spr22), HIS ORDER (2026-10-12) "make them all look better" and his answer 24 (silhouettes for readability first):
  // TEAM LAMP AND HIRE BAND. A small lamp in the team colour rides on the left shoulder strap, so the side a body is on reads from
  // the strap as well as the shoulder caps (gfxsil), and the hire, who is on your side, wears your colour, not the foe red, with
  // a hi-vis amber band on his gun arm. Both players keep the one ally colour (v22.70, one teammate colour). Cosmetic only.
  if(_PC&&!(OUTF&&OUTF.norig)&&(st.team==='ally'||st.team==='foe')&&typeof TEAMCOL!=='undefined'){
    var _lmx=x+leanX+((_BLD==='broad')?-4.6:(_BLD==='curved'?-4.15:-3.2))-0.9, _lmy=ty-22.6;
    wc.fillStyle=INK; wc.fillRect(_lmx-0.5,_lmy-0.5,2.8,2.8);
    wc.fillStyle=TEAMCOL[st.team]; wc.fillRect(_lmx,_lmy,1.8,1.8);
    wc.fillStyle='#ffffff'; wc.fillRect(_lmx+0.2,_lmy+0.2,0.6,0.6);
  }
'@

SubRx @'
  if(_PC&&/^#[0-9a-fA-F]{6}$/.test(coat)){ var _ah=(_BLD==='broad')?3.3:(_BLD==='curved'?2.0:2.1); wc.fillStyle=litHex(coat,.22,true); wc.fillRect(1+ext,(Math.cos(face)>=0)?-_ah:_ah-0.9,6,0.9); }   // v23.xx (spr15): the sleeve, lit on its upper edge
'@ @'
  if(_PC&&/^#[0-9a-fA-F]{6}$/.test(coat)){ var _ah=(_BLD==='broad')?3.3:(_BLD==='curved'?2.0:2.1); wc.fillStyle=litHex(coat,.22,true); wc.fillRect(1+ext,(Math.cos(face)>=0)?-_ah:_ah-0.9,6,0.9); }   // v23.xx (spr15): the sleeve, lit on its upper edge
  if(st.merc||(st.own&&st.own.merc)){ var _mbh=(_BLD==='broad')?3.3:(_BLD==='curved'?2.0:(_PC?2.1:2.4));   // v23.xx (spr22): the hire's hi-vis armband
    wc.fillStyle=INK; wc.fillRect(2.9+ext,-_mbh,2.4,2*_mbh); wc.fillStyle='#f0a020'; wc.fillRect(3.3+ext,-_mbh,1.6,2*_mbh); wc.fillStyle='#ffd27a'; wc.fillRect(3.3+ext,-_mbh,1.6,0.6); }
'@

SubRx @'
var VER='24.60';
'@ @'
var VER='24.61';
'@

$pat = "(?m)^  now:'v24\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.61: A team lamp rides on every shoulder strap, and your hire wears your colour and an amber armband. Check 24.61 fails on v24.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
