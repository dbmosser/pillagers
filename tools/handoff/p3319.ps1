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

# LATE NIGHT AUDIO: A SETTING FOR SOFTER PEAKS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function volOf(k){ var v=+CFG[k]; return (isFinite(v)&&v>=0&&v<=1)?v:1; }

'@ @'
function volOf(k){ var v=+CFG[k]; return (isFinite(v)&&v>=0&&v<=1)?v:1; }
// v28.xx (cw-latenight), HIS YES (100 picks, 74 "party volume governor"): LATE NIGHT AUDIO. A setting in AUDIO, off by default, for a living room
// TV at night: the world compressor squeezes harder (3.5 to 6), the world limiter and the master limiter catch peaks 6 dB lower and the world trim
// drops 2 dB, so blasts and heavy guns stop being the loudest thing in the house while footsteps stay heard. Off is exactly the old mix. The
// numbers are in LATE_OFF and LATE_ON; lateNightApply writes them to the real nodes and is called from volApply every frame (it only writes on a change).
var LATE_OFF={cr:3.5,lt:-3,tr:0.5,mt:-2}, LATE_ON={cr:6,lt:-9,tr:0.4,mt:-8};
function lateNightOn(){ return CFG.lateNight===1; }
function lateNightParams(on){ return on?LATE_ON:LATE_OFF; }
function lateNightApply(S,ml,on){
  var p=lateNightParams(on), n=0;
  try{
    if(S&&S.comp&&S.comp.ratio&&S.comp.ratio.value!==p.cr){ S.comp.ratio.value=p.cr; n++; }
    if(S&&S.lim&&S.lim.threshold&&S.lim.threshold.value!==p.lt){ S.lim.threshold.value=p.lt; n++; }
    if(S&&S.trim&&S.trim.gain&&S.trim.gain.value!==p.tr){ S.trim.gain.value=p.tr; n++; }
    if(ml&&ml.threshold&&ml.threshold.value!==p.mt){ ml.threshold.value=p.mt; n++; }
  }catch(_ln){}
  return n;
}

'@

SubRx @'
  try{ monoApply(); }catch(_vm2){}   // v26.xx (settings1): MONO AUDIO

'@ @'
  try{ monoApply(); }catch(_vm2){}   // v26.xx (settings1): MONO AUDIO
  try{ lateNightApply(SND,(typeof AC!=='undefined'&&AC)?AC.__ml:null,lateNightOn()); }catch(_vln){}   // v28.xx (cw-latenight): LATE NIGHT AUDIO

'@

SubRx @'
  {k:'mono', label:'MONO AUDIO', sec:'AUDIO',
   hint:'One channel for everything, no left or right. For one ear or one speaker.',
   opts:[
     {n:'OFF', cfg:{mono:0}},
     {n:'ON',  cfg:{mono:1}}
   ], def:0},

'@ @'
  {k:'mono', label:'MONO AUDIO', sec:'AUDIO',
   hint:'One channel for everything, no left or right. For one ear or one speaker.',
   opts:[
     {n:'OFF', cfg:{mono:0}},
     {n:'ON',  cfg:{mono:1}}
   ], def:0},
  // v28.xx (cw-latenight), HIS YES (100 picks, 74): softer peaks for a quiet room. Off by default; see lateNightApply.
  {k:'lateNight', label:'LATE NIGHT AUDIO', sec:'AUDIO',
   hint:'Quieter blasts and heavy guns for a quiet room. Footsteps stay clear.',
   opts:[
     {n:'OFF', cfg:{lateNight:0}},
     {n:'ON',  cfg:{lateNight:1}}
   ], def:0},

'@

SubRx @'
var VER='33.18';
'@ @'
var VER='33.19';
'@

$pat = "(?m)^  now:'v33\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.19: Settings, AUDIO now has LATE NIGHT AUDIO. On, blasts and heavy guns hit softer and footsteps stay clear. Off is the old sound. Check 33.19 fails on v33.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
