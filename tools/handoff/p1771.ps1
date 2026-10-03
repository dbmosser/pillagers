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

# A KID MENU, WITH PLAYER 2 COMING BACK AFTER DEATH (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function afRowHtml(){
'@ @'
// v17.71, HIS ORDER 2026-10-02: A KID MENU. The kid rows sit under a KID MODE heading in Settings, and gain one: PLAYER 2 COMES
// BACK AFTER DEATH. With it on, a teammate who died can JOIN THE RAID IN PROGRESS again (the sit-out of v17.66 is for grown-ups);
// extracting still ends his raid. Either window can set it; the host carries it to the party in the world word (kb), as kid mode
// and auto-fire are carried. Saved with the profile.
function kbOwn(){ return !!(typeof P!=='undefined'&&P&&P.kidBack); }
function kbOn(){ return !!(kbOwn()||(typeof NET==='object'&&NET&&NET.kbHost===1)); }
function kbCycle(){ P.kidBack=kbOwn()?0:1; saveProfile(); return P.kidBack; }
function kidHeadHtml(){
  return '<div class="row" style="margin-top:14px;border-top:1px solid var(--steel-hi);padding-top:10px"><div style="flex:1"><b style="color:var(--amber);letter-spacing:.14em">KID MODE</b>'+
    '<div class="hint">For playing with a younger player 2. Either window can set these, and they change the raid at once.</div></div></div>';
}
function kbRowHtml(){
  var on=kbOwn();
  return '<div class="row"><div style="flex:1"><b>Player 2 comes back after death</b><div class="hint">When player 2 dies he can JOIN THE RAID IN PROGRESS again, from the Undercroft or the lift. Off, he sits that raid out.</div></div>'+
    '<button id="set_kb" style="padding:6px 12px;min-width:92px'+(on?';color:var(--amber)':'')+'">'+(on?'ON':'OFF')+'</button></div>';
}
function afRowHtml(){
'@

SubRx @'
  host.innerHTML=_go+kidRowHtml()+afRowHtml()+
'@ @'
  host.innerHTML=_go+kidHeadHtml()+kidRowHtml()+afRowHtml()+kbRowHtml()+   // v17.71: the kid menu
'@

SubRx @'
  (function(){ var _ab=document.getElementById('set_af'); if(_ab) _ab.onclick=function(){ afCycle(); renderSettings(); }; })();   // v16.83, his order: auto-fire for player 2
'@ @'
  (function(){ var _ab=document.getElementById('set_af'); if(_ab) _ab.onclick=function(){ afCycle(); renderSettings(); }; })();   // v16.83, his order: auto-fire for player 2
  (function(){ var _kb2=document.getElementById('set_kb'); if(_kb2) _kb2.onclick=function(){ kbCycle(); renderSettings(); }; })();   // v17.71: player 2 comes back after death
'@

SubRx @'
  m.kd=kidMulOwn();   // v16.44: kid mode as the host has it, live
'@ @'
  m.kd=kidMulOwn();   // v16.44: kid mode as the host has it, live
  m.kb=kbOwn()?1:0;   // v17.71: and whether player 2 comes back after death, as the host has it
'@

SubRx @'
  if(typeof m.kd==='number'&&isFinite(m.kd)) NET.kidHost=clamp(m.kd,KID_MIN,1);   // v16.44: kid mode as the host has it; v17.02, co-op hunt 2026-09-28: down to 1/20, not 1/10
'@ @'
  if(typeof m.kd==='number'&&isFinite(m.kd)) NET.kidHost=clamp(m.kd,KID_MIN,1);   // v16.44: kid mode as the host has it; v17.02, co-op hunt 2026-09-28: down to 1/20, not 1/10
  NET.kbHost=(m.kb===1)?1:((m.kb===0)?0:null);   // v17.71: player 2 comes back after death, as the host has it
'@

SubRx @'
  if(NET.role==='join'&&(how==='dead'||how==='extract')&&NET.upSeed) NET.lateBan=NET.upSeed>>>0;   // v17.66, his ruling 2026-10-01: no rejoining a raid you died or extracted in
'@ @'
  if(NET.role==='join'&&(how==='dead'||how==='extract')&&NET.upSeed&&!(how==='dead'&&kbOn())) NET.lateBan=NET.upSeed>>>0;   // v17.66, his ruling: no rejoining a raid you died or extracted in; v17.71: the kid menu lets player 2 back after death
'@

SubRx @'
  if(NET.role==='host'&&st==='out'&&(m.how==='dead'||m.how==='extract')&&NET.upWord){ if(!NET.lateOut) NET.lateOut={}; NET.lateOut[s]=NET.upWord.seed>>>0; }   // v17.66, his ruling: that seat sits this raid out
'@ @'
  if(NET.role==='host'&&st==='out'&&(m.how==='dead'||m.how==='extract')&&NET.upWord&&!(m.how==='dead'&&kbOn())){ if(!NET.lateOut) NET.lateOut={}; NET.lateOut[s]=NET.upWord.seed>>>0; }   // v17.66, his ruling: that seat sits this raid out
'@

SubRx @'
<b>Kid mode</b><div class="hint">Player 2 takes less damage:
'@ @'
<b>Player 2 takes less damage</b><div class="hint">Player 2 takes less damage:
'@

SubRx @'
var VER='17.70';
'@ @'
var VER='17.71';
'@

$pat = "(?m)^  now:'v17\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.71: Settings has a KID MODE section, and a new switch: PLAYER 2 COMES BACK AFTER DEATH, so a younger player 2 can rejoin the raid after dying. Check 17.71 fails on v17.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
