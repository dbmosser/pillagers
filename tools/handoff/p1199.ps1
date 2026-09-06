$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# FROM THE 2026-09-06 MENU AUDIT (P2): the floor kept taking E, R, F and T
# behind the character screen, because #title is a .screen and not a .modal
# and hubModalOpen asks only for modals, the Stash screen, the pause box and
# the outcome card. At the lift, R ran commitKit and startRaid under the
# title. One line: the character screen counts.
SubRx @'
  if(document.getElementById('outcome').classList.contains('on')) return true;
  return !!document.querySelector('.modal.on');
}
function updateHubWorld(dt){
'@ @'
  if(document.getElementById('outcome').classList.contains('on')) return true;
  // v11.91, from the 2026-09-06 menu audit: and the character screen, which is
  // a .screen and not a .modal. Without this the floor took E, R, F and T
  // behind it, and R at the lift started a raid under the title.
  var _ttl=document.getElementById('title');
  if(_ttl&&_ttl.classList.contains('on')) return true;
  return !!document.querySelector('.modal.on');
}
function updateHubWorld(dt){
'@

# The keydown branch keeps its own hand-written copy of the same gate; the
# already-computed flag folds into it, so SPACE, H, TAB and I stop too.
SubRx @'
    var _hubBusy=!!(document.querySelector('.modal.on')||document.querySelector('.imenu')||
'@ @'
    var _hubBusy=!!(_titleUp||document.querySelector('.modal.on')||document.querySelector('.imenu')||   // v11.91: the character screen counts here too
'@
SubRx @'
      if(document.querySelector('.imenu')) _anyModal=true;
      if(!_anyModal){
'@ @'
      if(document.querySelector('.imenu')) _anyModal=true;
      if(_titleUp) _anyModal=true;   // v11.91
      if(!_anyModal){
'@

# STAMPS.
SubRx @'
var VER='11.90';
'@ @'
var VER='11.91';
'@
SubRx @'
var WHATSNEW_VER='11.90';
'@ @'
var WHATSNEW_VER='11.91';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE CHARACTER SCREEN NO LONGER LETS KEYS THROUGH TO THE FLOOR BEHIND IT. E, R, F and T reached the stations under it, and R at the lift started a raid.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.90:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.90 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.90:[^']*'",{ param($m) "now:'v11.91: from the 2026-09-06 menu audit, the floor kept taking station keys behind the character screen because hubModalOpen did not count #title (a .screen, not a .modal); at the lift R started a raid under the title. One line: the character screen counts as a modal. Check 11.91 turns the character screen on over the floor and requires the gate to read open, then off and requires it closed; fails on v11.90.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
