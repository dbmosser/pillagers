$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'34.67',what:")) { throw "check 34.67 is in the fixture already" }

SubRx @'
  {v:'34.66',what:
'@ @'
  {v:'34.67',what:'the two in-raid demo cards are solid dialogs clear of the controls legend, and the press a title names the lost pad',
   run:function(){
     if(typeof dlgCard!=='function') return 'no dialog card layout (dlgCard): the easy and initials cards are still see-through boxes on the legend';
     var e=dlgCard('easy'), i=dlgCard('ini'), s;
     if(!/^#[0-9a-f]{6}$/i.test(e.fill)||!/^#[0-9a-f]{6}$/i.test(i.fill)) return 'a card fill is not opaque: '+e.fill+' '+i.fill;
     if(i.y+i.h>H*0.62) return 'the initials card reaches the controls legend (bottom '+(i.y+i.h)+' of '+H+')';
     s=String(easyHud)+String(arcadeIniHud);
     if(s.indexOf('dlgCard')<0||s.indexOf('rgba(6,9,13')>=0) return 'the cards still draw their own see-through box';
     if(typeof padLostWords!=='function') return 'the press a title does not name the pad (no padLostWords)';
     if(padLostWords(false,'p1')!=='p1 pad lost'||padLostWords(true,'p2')!=='p2 press a'||padLostWords(true,'')!=='press a') return 'the pad lost title words are wrong: '+padLostWords(false,'p1')+' / '+padLostWords(true,'p2')+' / '+padLostWords(true,'');
     if(String(padLostPoll).indexOf('padLostTitle')<0||String(padLostStart).indexOf('padLostTitle')<0) return 'the lost pad screens do not use the named title';
     return null;
   }},
  {v:'34.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
