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

# VOLUME: MASTER, MUSIC AND EFFECTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var BUS=null,PAN_OK=true;
'@ @'
var BUS=null,PAN_OK=true;
// v17.74, AAA CHECK (2026-10-02): VOLUME. Three Settings rows, Master, Music and Effects, each Off to Full. Effects ride the
// bus every sound goes through (BUS), music rides its own gain (MUS.g, whose level the music itself moves, so the setting
// multiplies the level it asks for), and Master multiplies both. Applied every frame from the loop, so a change lands at once.
var VOL_LAST='';
function volOf(k){ var v=+CFG[k]; return (isFinite(v)&&v>=0&&v<=1)?v:1; }
function volApply(){
  var m=volOf('volMaster'), f=volOf('volFx'), mu=volOf('volMusic'), key=m+'/'+f+'/'+mu, a;
  if(BUS&&BUS.gain){ try{ if(BUS.gain.value!==m*f) BUS.gain.value=m*f; }catch(_vb){} }
  if(key!==VOL_LAST){
    VOL_LAST=key;
    if(typeof MUS==='object'&&MUS&&MUS.g&&MUS.g.gain&&typeof MUS.lvl==='number'){ a=(typeof AC!=='undefined'&&AC)?AC.currentTime:0; try{ MUS.g.gain.setTargetAtTime(MUS.lvl*mu*m,a,0.5); }catch(_vm){} }
  }
  return key;
}
'@

SubRx @'
  MUS.g.gain.setTargetAtTime(lvl,a.currentTime,0.9);
'@ @'
  MUS.lvl=lvl; lvl=lvl*volOf('volMusic')*volOf('volMaster');   // v17.74: the volume rows scale the level the music asks for
  MUS.g.gain.setTargetAtTime(lvl,a.currentTime,0.9);
'@

SubRx @'
  if(frameCapSkip(ts)) return;   // v17.43: his pick 28, the frame cap
'@ @'
  try{ volApply(); }catch(_va){}   // v17.74: the volume rows, applied at once
  if(frameCapSkip(ts)) return;   // v17.43: his pick 28, the frame cap
'@

SubRx @'
  {k:'rumble', label:'Controller rumble',
'@ @'
  {k:'volMaster', label:'Master volume',
   hint:'Everything the game plays.',
   opts:[
     {n:'Off',  cfg:{volMaster:0}},
     {n:'25%',  cfg:{volMaster:0.25}},
     {n:'50%',  cfg:{volMaster:0.5}},
     {n:'75%',  cfg:{volMaster:0.75}},
     {n:'Full', cfg:{volMaster:1}}
   ], def:4},
  {k:'volMusic', label:'Music volume',
   hint:'The music on its own.',
   opts:[
     {n:'Off',  cfg:{volMusic:0}},
     {n:'25%',  cfg:{volMusic:0.25}},
     {n:'50%',  cfg:{volMusic:0.5}},
     {n:'75%',  cfg:{volMusic:0.75}},
     {n:'Full', cfg:{volMusic:1}}
   ], def:4},
  {k:'volFx', label:'Effects volume',
   hint:'Guns, footsteps, hits and the world.',
   opts:[
     {n:'Off',  cfg:{volFx:0}},
     {n:'25%',  cfg:{volFx:0.25}},
     {n:'50%',  cfg:{volFx:0.5}},
     {n:'75%',  cfg:{volFx:0.75}},
     {n:'Full', cfg:{volFx:1}}
   ], def:4},
  {k:'rumble', label:'Controller rumble',
'@

SubRx @'
var VER='17.73';
'@ @'
var VER='17.74';
'@

$pat = "(?m)^  now:'v17\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.74: Settings has Master, Music and Effects volume rows. Check 17.74 fails on v17.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
