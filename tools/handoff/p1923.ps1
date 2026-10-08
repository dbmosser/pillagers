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

# THE SHOP PANEL SHOWS WHAT ITEMS DO (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    h+='<div class="vdesc">'+escHtml(it?(itemBlurb(o.k)||''):'')+'</div>';
'@ @'
    h+='<div class="vdesc">'+escHtml(it?(itemBlurb(o.k)||''):'')+'</div>';
    h+=itemStatsHTML(o.k);   // v19.23: what it does in numbers, as the guns have
'@

SubRx @'
function itemBlurb(k){
'@ @'
// v19.23, seen on the 4K shop screenshot (2026-10-08): a gun on the cream panel shows its damage, magazine and range, but a Bandage,
// a Medkit, a plate, a stim or a frag showed one sentence over a blank panel. They now show what they do in numbers: how much, over
// how long, up to what, and how long they take to put on. Read from the same numbers the game uses, so they cannot drift.
function itemStatsHTML(k){
  var it=ITEMS[k], R=[], i, s='';
  if(!it) return '';
  function sec(v){ return (Math.round(v*10)/10)+' s'; }
  if(it.use==='heal'){
    R.push(['Heals',(it.amt||0)+' health']);
    if(it.hot) R.push(['Over',sec(it.hot)]);
    R.push(['Heals up to',(it.capHp||100)+' health']);
    R.push(['Takes',sec(CFG.healPrep===undefined?1.5:CFG.healPrep)+' to put on']);
  } else if(it.use==='armor'){
    R.push(['Armour','+'+(it.amt||0)]);
    R.push(['Takes',sec(CFG.armorPrep===undefined?2:CFG.armorPrep)+' to slot']);
  } else if(it.use==='ammo'){
    R.push(['Rounds',String(it.amt||0)]);
  } else if(it.use==='stim'){
    R.push(['Lasts',sec(STIM_SEC)]);
    R.push(['Speed','+'+Math.round((STIM_SPD-1)*100)+'%']);
    R.push(['Stamina','unlimited']);
  } else if(it.use==='throw'&&it.tk==='frag'){
    R.push(['Blast',Math.round((CFG.fragR===undefined?190:CFG.fragR)/10)+'m']);
  }
  for(i=0;i<R.length;i++) s+='<div class="vstat" style="font-size:15px;padding:4px 0;border-bottom:1px solid #ddd5c4"><span>'+escHtml(R[i][0])+'</span><b>'+escHtml(String(R[i][1]))+'</b></div>';
  return s?('<div class="vstats" style="margin:-4px 0 18px">'+s+'</div>'):'';
}function itemBlurb(k){
'@

SubRx @'
var VER='19.22';
'@ @'
var VER='19.23';
'@

$pat = "(?m)^  now:'v19\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.23: The shop says what a Bandage, Medkit, plate, stim or frag does in numbers. Check 19.23 fails on v19.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
