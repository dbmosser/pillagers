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

if ($s.Contains("  {v:'18.97',what:")) { throw "check 18.97 is in the fixture already" }

SubRx @'
  {v:'18.96',what:
'@ @'
  {v:'18.97',what:'the run card note box never squashes: on a card taller than the screen the note box keeps its height, the card stays inside the screen and scrolls',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], oc, win, note, man, keep, r, rn;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       __endRaid('extract');
       oc=document.getElementById('outcome'); win=oc&&oc.querySelector('.ocwin'); note=document.getElementById('oc_note'); man=document.getElementById('oc_manifest');
       if(!oc||!oc.classList.contains('on')||!win||!note||!man) return 'SKIP: the run card did not open';
       keep=man.innerHTML;
       man.innerHTML=keep+new Array(41).join('<div>ACHIEVEMENT: a long line that makes the card taller than the screen</div>');
       r=win.getBoundingClientRect(); rn=note.getBoundingClientRect();
       if(rn.height<36) bad.push('the note box is squashed to '+Math.round(rn.height)+'px');
       if(r.bottom>innerHeight+1||r.top<-1) bad.push('the card runs off the screen ('+Math.round(r.top)+' to '+Math.round(r.bottom)+' of '+innerHeight+')');
       man.innerHTML=keep;
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(man&&keep!==undefined) man.innerHTML=keep; }catch(_m){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
