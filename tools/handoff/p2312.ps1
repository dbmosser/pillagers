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

# RAID DETAILS ARE SHORT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(padOn()) return padB('LB or RB to your gun.');   // v13.52: no pad button reaches a digit; the bumpers walk the belt
'@ @'
  if(padOn()) return padB('[LB] [RB] GUN');   // v13.52: no pad button reaches a digit; the bumpers walk the belt   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
  return 'Press '+keyLabel('Digit'+(gc+1),String(gc+1))+' for your gun.';
'@ @'
  return '['+keyLabel('Digit'+(gc+1),String(gc+1))+'] GUN';   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
        else say('SURVIVOR FOUND','obj',{sub:'He needs '+aOrAn(ITEMS[e.want].name)+' '+ITEMS[e.want].name+'.'});
'@ @'
        else say('SURVIVOR FOUND','obj',{sub:'Needs '+ITEMS[e.want].name+'.'});   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
    else { say('HE NEEDS AMMUNITION','info',{sub:'You cannot spare '+need+' rounds.'}); return; }   // v22.xx (R54): a caps callout
'@ @'
    else { say('NOT ENOUGH AMMUNITION','info',{sub:'Needs '+need+' rounds.'}); return; }   // v22.xx (R54): a caps callout   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
      var _hotLine=G.sim?'':'Hot ground. Extra loot in here.';
'@ @'
      var _hotLine=G.sim?'':'HOT GROUND';   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
  if(_hotLine) sayWhenFree('HOT GROUND','obj',{sub:'Extra loot in here.'});   // v22.xx (R53): an objective row in caps
'@ @'
  if(_hotLine) sayWhenFree('HOT GROUND','obj',{sub:'Bonus loot.'});   // v22.xx (R53): an objective row in caps   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
    if(m.hot===1){ if(T) T.hotOpened=(T.hotOpened||0)+1; if(!G.sim) sayWhenFree('HOT GROUND','obj',{sub:'Extra loot in here.'}); }   // v20.39 (H59): the bonus the host rolled for this search   // v22.xx (R53): an objective row in caps
'@ @'
    if(m.hot===1){ if(T) T.hotOpened=(T.hotOpened||0)+1; if(!G.sim) sayWhenFree('HOT GROUND','obj',{sub:'Bonus loot.'}); }   // v20.39 (H59): the bonus the host rolled for this search   // v22.xx (R53): an objective row in caps   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
          say('SEAL BROKEN','obj',{sub:'What Meridian sealed is yours if you live.'});   // v22.xx (R53): an objective row in caps
'@ @'
          say('SEAL BROKEN','obj',{sub:'Seal payout dropped.'});   // v22.xx (R53): an objective row in caps   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
        say(String(e.name).toUpperCase()+' IS DEAD','obj',{sub:'You owe his family.'});   // v22.xx (R53): an objective row in caps
'@ @'
        say(String(e.name).toUpperCase()+' IS DEAD','obj',{sub:'Death benefit $'+MERC_DEATH.toLocaleString()+' owed.'});   // v22.xx (R53): an objective row in caps   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
  if(typeof G!=='undefined'&&G&&!G.over&&!G.sim&&typeof state!=='undefined'&&state==='raid'){ try{ if(!pauseOpen) togglePauseBox(true); }catch(_pd){} try{ say('CONTROLLER DISCONNECTED','sys',{sub:'Plug it in, then resume.'}); }catch(_pd2){} }   // v22.xx (R55): a system label in caps
'@ @'
  if(typeof G!=='undefined'&&G&&!G.over&&!G.sim&&typeof state!=='undefined'&&state==='raid'){ try{ if(!pauseOpen) togglePauseBox(true); }catch(_pd){} try{ say('CONTROLLER DISCONNECTED','sys',{sub:'RECONNECT TO RESUME'}); }catch(_pd2){} }   // v22.xx (R55): a system label in caps   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
  recTell('RECORDING','[F9] stops it, or it stops at 3:00.');   // v22.xx (R55): a system label in caps
'@ @'
  recTell('RECORDING','[F9] STOP  \u00b7  3:00 MAX');   // v22.xx (R55): a system label in caps   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
  attClipPut(b,function(ok){ recTell(ok?'RECORDING KEPT':'RECORDING NOT KEPT','A copy is in your downloads.'); });   // v22.xx (R55): a system label in caps
'@ @'
  attClipPut(b,function(ok){ recTell(ok?'RECORDING KEPT':'RECORDING NOT KEPT','SAVED TO DOWNLOADS'); });   // v22.xx (R55): a system label in caps   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
  if(!ITEMS['gun_'+g.id]){ say('CANNOT STOW THAT GUN','info',{sub:g.name+' has no backpack form.'}); return false; }   // v22.xx (R52)
'@ @'
  if(!ITEMS['gun_'+g.id]){ say('CANNOT STOW THAT GUN','info'); return false; }   // v22.xx (R52)   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
      var _loanLn='YOU CARRY A LOANER';   // v22.xx (R55): a system label in caps
'@ @'
      var _loanLn='LOANER GUN';   // v22.xx (R55): a system label in caps   // v23.xx (tr9fixm): a short detail, never an explaining sentence
'@

SubRx @'
var VER='23.11';
'@ @'
var VER='23.12';
'@

$pat = "(?m)^  now:'v23\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.12: Raid details are short callouts, and the gun key reads [5] GUN. Check 23.12 fails on v23.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
