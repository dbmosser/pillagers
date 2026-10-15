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

# PAD PROMPTS NAME THE BUTTONS AS SET (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(findHeal()>=0){ say('NO HEAL ON BELT','info',{sub:(padOn()?padB('VIEW  BACKPACK'):('['+keyLabel('KeyB','B')+'] BACKPACK'))}); return false; }
'@ @'
    if(findHeal()>=0){ say('NO HEAL ON BELT','info',{sub:(padOn()?padB(pbn(8)+'  BACKPACK'):('['+keyLabel('KeyB','B')+'] BACKPACK'))}); return false; }  // v27.70 (cloud-menus-pad-prompts-follow-binds), CLOUD HUNT 2026-10-15: the NO HEAL ON BELT line named VIEW for the backpack after CHANGE PAD BUTTONS moved it; it names the button the backpack is on
'@

SubRx @'
    ctx.fillText(padOn()?padB('VIEW  BACKPACK'):(keyLabel('KeyB','B')+' / '+keyLabel('KeyI','I')+'  BACKPACK'),W-16,by-LH(70));   // v13.52: pad B is the dodge roll
'@ @'
    ctx.fillText(padOn()?padB(pbn(8)+'  BACKPACK'):(keyLabel('KeyB','B')+' / '+keyLabel('KeyI','I')+'  BACKPACK'),W-16,by-LH(70));   // v13.52: pad B is the dodge roll  // v27.70 (cloud-menus-pad-prompts-follow-binds), CLOUD HUNT 2026-10-15: the backpack cue said VIEW after the backpack moved to another button, and VIEW no longer opened it; it names the button it is on
'@

SubRx @'
    if(!G.sim) say(String(sl[i].name||'Gun').toUpperCase(),'info',{sub:padB('RT TO DRAW')});
'@ @'
    if(!G.sim) say(String(sl[i].name||'Gun').toUpperCase(),'info',{sub:padB(pbn(7)+' TO DRAW')});  // v27.70 (cloud-menus-pad-prompts-follow-binds), CLOUD HUNT 2026-10-15: the belt said RT TO DRAW after fire moved off RT; it names the fire button as set
'@

SubRx @'
          _lootSub=(padOn()?padB('LB or RB to swap'):('Press '+keyLabel('Digit'+(_swk+1),String(_swk+1))+' to swap')).toUpperCase();
'@ @'
          _lootSub=(padOn()?padB(pbn(4)+' or '+pbn(5)+' to swap'):('Press '+keyLabel('Digit'+(_swk+1),String(_swk+1))+' to swap')).toUpperCase();  // v27.70 (cloud-menus-pad-prompts-follow-binds), CLOUD HUNT 2026-10-15: the pickup line said LB or RB after the belt buttons moved; it names them as set
'@

SubRx @'
    _lootSub=(padOn()?padB('LB or RB to swap'):('Press '+keyLabel('Digit'+((k<0?1:k)+1),String((k<0?1:k)+1))+' to swap')).toUpperCase();
'@ @'
    _lootSub=(padOn()?padB(pbn(4)+' or '+pbn(5)+' to swap'):('Press '+keyLabel('Digit'+((k<0?1:k)+1),String((k<0?1:k)+1))+' to swap')).toUpperCase();  // v27.70 (cloud-menus-pad-prompts-follow-binds), CLOUD HUNT 2026-10-15: the pickup line said LB or RB after the belt buttons moved; it names them as set
'@

SubRx @'
      var _skey='['+((G.nearPad&&padOn())?padB('Y'):keyLabel('KeyE','E'))+'] SEARCH ', _ft, _fcr=null, _fsub='', _fsc=null;
'@ @'
      var _skey='['+((G.nearPad&&padOn())?padB(pbn(3)):keyLabel('KeyE','E'))+'] SEARCH ', _ft, _fcr=null, _fsub='', _fsc=null;  // v27.70 (cloud-menus-pad-prompts-follow-binds), CLOUD HUNT 2026-10-15: the ring prompt said [Y] SEARCH after the ring search moved off Y; it names the button as set
'@

SubRx @'
var VER='27.69';
'@ @'
var VER='27.70';
'@

$pat = "(?m)^  now:'v27\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.70: With the controller buttons changed, the raid prompts name the buttons you set. Check 27.70 fails on v27.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
