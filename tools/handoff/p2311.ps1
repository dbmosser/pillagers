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

# PEOPLE LINES FIT AND GRUDGES READ HOSTILE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  try{ say(String(netSeatName(peer.seat)||'Your teammate').toUpperCase()+' IS JOINING THE RAID','ally'); }catch(_ls){}   // v17.62: the host hears who is coming   // v22.xx (R54): a caps callout
'@ @'
  try{ say(String(netSeatName(peer.seat)||'Your teammate').toUpperCase()+' IS JOINING','ally'); }catch(_ls){}   // v17.62: the host hears who is coming   // v22.xx (R54): a caps callout   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
  if(st==='out'&&s!==0&&typeof G!=='undefined'&&G&&!G.over&&!G.sim){ hw=netClean(m.how,12); hw=(hw==='dead')?'killed':(hw==='extract')?'extracted':(hw==='abandon')?'abandoned':''; try{ sayWhenFree(String(nm).toUpperCase()+((hw==='killed')?' DIED':(hw==='extracted')?' EXTRACTED':(hw==='abandoned')?' ABANDONED THE RAID':' IS OUT'),'ally'); }catch(_so){} }  if(st==='no'){ NET.status=nm+' could not go up with you: '+netUpWhyText(m.why)+'.'; netRefresh(); try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree(NET.status); }catch(_sn){} }   /* v22.xx (R54): NAME EXTRACTED, a caps callout */
'@ @'
  if(st==='out'&&s!==0&&typeof G!=='undefined'&&G&&!G.over&&!G.sim){ hw=netClean(m.how,12); hw=(hw==='dead')?'killed':(hw==='extract')?'extracted':(hw==='abandon')?'abandoned':''; try{ sayWhenFree(String(nm).toUpperCase()+((hw==='killed')?' DIED':(hw==='extracted')?' EXTRACTED':(hw==='abandoned')?' ABANDONED':' IS OUT'),'ally'); }catch(_so){} }  if(st==='no'){ NET.status=nm+' could not go up with you: '+netUpWhyText(m.why)+'.'; netRefresh(); try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree(NET.status); }catch(_sn){} }   /* v22.xx (R54): NAME EXTRACTED, a caps callout */   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
          say(String(near.mercSrc.name).toUpperCase()+' CARRIES NOTHING ELSE');   // v22.xx (R54): a caps callout
'@ @'
          say(String(near.mercSrc.name).toUpperCase()+' EMPTY','info');   // v22.xx (R54): a caps callout   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
          sayWhenFree(String(e.name).toUpperCase()+' WILL REMEMBER THAT','ally');   // v13.38: waits its turn. contractKill above may have just said the contract is done in this same step, and a plain say wrote over it before any frame drew it.   // v22.xx (R54): a caps callout
'@ @'
          sayWhenFree(String(e.name).toUpperCase()+' WANTS REVENGE','info');   // v13.38: waits its turn. contractKill above may have just said the contract is done in this same step, and a plain say wrote over it before any frame drew it.   // v22.xx (R54): a caps callout   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
    sayWhenFree(String(e.name||'He').toUpperCase()+' WILL REMEMBER THAT','ally');   // v22.xx (R54): a caps callout
'@ @'
    sayWhenFree(String(e.name||'He').toUpperCase()+' WANTS REVENGE','info');   // v22.xx (R54): a caps callout   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
            say(String(e.name).toUpperCase()+' TRUSTED YOU','ally');   // v22.xx (R54): a caps callout
'@ @'
            say(String(e.name).toUpperCase()+' TRUSTED YOU','info');   // v22.xx (R54): a caps callout   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
  sayWhenFree(String(e.name||'He').toUpperCase()+' TRUSTED YOU','ally');   // v22.xx (R54): a caps callout
'@ @'
  sayWhenFree(String(e.name||'He').toUpperCase()+' TRUSTED YOU','info');   // v22.xx (R54): a caps callout   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
        else say(pedOpen()?'THE PEDDLER WAVES YOU OVER':'THE PEDDLER TURNS HIS BACK','ally');   // v22.xx (R54): a caps callout
'@ @'
        else say(pedOpen()?'THE PEDDLER WAVES YOU OVER':'THE PEDDLER TURNS HIS BACK',pedOpen()?'ally':'info');   // v22.xx (R54): a caps callout   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
  if(k==='ped'){ if(mine&&!G.sim) say(pedOpen()?'THE PEDDLER WAVES YOU OVER':'THE PEDDLER TURNS HIS BACK','ally'); return 'mark:ped'; }
'@ @'
  if(k==='ped'){ if(mine&&!G.sim) say(pedOpen()?'THE PEDDLER WAVES YOU OVER':'THE PEDDLER TURNS HIS BACK',pedOpen()?'ally':'info'); return 'mark:ped'; }   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
    say((m.why==='down'||m.why==='gone')?(String(nm).toUpperCase()+(m.why==='down'?' IS DOWN':' LEFT THE RAID')):'HAND-OVER FAILED','ally',{sub:(m.why==='down'||m.why==='gone')?'Cannot take it.':('With '+nm+'.')});   // v18.23: the reason, when there is one   // v22.xx (R54): a caps callout
'@ @'
    say((m.why==='down'||m.why==='gone')?(String(nm).toUpperCase()+(m.why==='down'?' IS DOWN':' LEFT THE RAID')):'HAND-OVER FAILED','ally',{sub:(m.why==='down'||m.why==='gone')?'Cannot take it.':String(nm)});   // v18.23: the reason, when there is one   // v22.xx (R54): a caps callout   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
          blip('pick'); say(String(e.name).toUpperCase()+' REVIVED YOU','ally',{sub:'That is what you paid for.'});   // v22.xx (R54): a caps callout
'@ @'
          blip('pick'); say(String(e.name).toUpperCase()+' REVIVED YOU','ally');   // v22.xx (R54): a caps callout   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
    if(!pedOpen()) say('NO DEAL','info',{sub:'He heard what you did to the last one.'});   // v22.xx (R54): a caps callout
'@ @'
    if(!pedOpen()) say('NO DEAL','info');   // v22.xx (R54): a caps callout   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
        if(!e.fleeT&&!G.sim) say('THE PEDDLER BOLTS','info',{sub:'No trade while he bleeds.'});   // v22.xx (R54): a caps callout
'@ @'
        if(!e.fleeT&&!G.sim) say('THE PEDDLER BOLTS','info',{sub:'No trade.'});   // v22.xx (R54): a caps callout   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
                  if(!en._shTold){ en._shTold=1; say('THE BULWARK BLOCKED IT','info',{sub:'Get behind it.'}); }   // v22.xx (R54): the Bulwark by its name, never the slab
'@ @'
                  if(!en._shTold){ en._shTold=1; say('BULWARK SHIELD','info',{sub:'Flank it.'}); }   // v22.xx (R54): the Bulwark by its name, never the slab   // v23.xx (tr9fixl): people lines fit 34 and a grudge never reads as friendly
'@

SubRx @'
var VER='23.10';
'@ @'
var VER='23.11';
'@

$pat = "(?m)^  now:'v23\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.11: People lines fit the headline length and grudges no longer show in the teammate colour. Check 23.11 fails on v23.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
