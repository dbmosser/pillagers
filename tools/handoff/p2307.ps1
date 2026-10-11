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

# PEOPLE LINES IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    else { say('He needs ammunition. You cannot spare '+need+' rounds.'); return; }
'@ @'
    else { say('HE NEEDS AMMUNITION','info',{sub:'You cannot spare '+need+' rounds.'}); return; }   // v22.xx (R54): a caps callout
'@

SubRx @'
  if(!n){ if(!G.sim) say('Nothing in your backpack he wants.'); return; }
'@ @'
  if(!n){ if(!G.sim) say('HE WANTS NOTHING YOU CARRY'); return; }   // v22.xx (R54): a caps callout
'@

SubRx @'
    if(!pedOpen()) say('He has heard what you did to the last one. No deal.');
'@ @'
    if(!pedOpen()) say('NO DEAL','info',{sub:'He heard what you did to the last one.'});   // v22.xx (R54): a caps callout
'@

SubRx @'
        if(!e.fleeT&&!G.sim) say('The Peddler bolts. No trade while he is bleeding.');
'@ @'
        if(!e.fleeT&&!G.sim) say('THE PEDDLER BOLTS','info',{sub:'No trade while he bleeds.'});   // v22.xx (R54): a caps callout
'@

SubRx @'
        else say(pedOpen()?'The Peddler waves you over.':'The Peddler turns his back on you.');
'@ @'
        else say(pedOpen()?'THE PEDDLER WAVES YOU OVER':'THE PEDDLER TURNS HIS BACK','ally');   // v22.xx (R54): a caps callout
'@

SubRx @'
      say('Order: '+(G.mercOrder==='loot'?(_mrc.name+', loot on your own.')
        :(G.mercOrder==='follow'?(_mrc.name+', on me.'):(_mrc.name+', hold here.'))));
'@ @'
      // v22.xx, the raid text rewrite (R54): the order is the headline, his name first (GRIT LOOTS ON HIS OWN, FOLLOWS YOU, HOLDS HERE)
      say(String(_mrc.name).toUpperCase()+(G.mercOrder==='loot'?' LOOTS ON HIS OWN':(G.mercOrder==='follow'?' FOLLOWS YOU':' HOLDS HERE')),'ally');
'@

SubRx @'
        say(downRdr.name+' is back on his feet. He will remember that.');
      } else say('Back on his feet.');
'@ @'
        say(String(downRdr.name).toUpperCase()+' IS BACK UP','ally',{sub:'He will remember that.'});   // v22.xx (R54): a caps callout
      } else say('HE IS BACK UP','ally');
'@

SubRx @'
          say('That is everything '+near.mercSrc.name+' is carrying.');
'@ @'
          say(String(near.mercSrc.name).toUpperCase()+' CARRIES NOTHING ELSE');   // v22.xx (R54): a caps callout
'@

SubRx @'
          sayWhenFree(e.name+' will remember that.');   // v13.38: waits its turn. contractKill above may have just said the contract is done in this same step, and a plain say wrote over it before any frame drew it.
'@ @'
          sayWhenFree(String(e.name).toUpperCase()+' WILL REMEMBER THAT','ally');   // v13.38: waits its turn. contractKill above may have just said the contract is done in this same step, and a plain say wrote over it before any frame drew it.   // v22.xx (R54): a caps callout
'@

SubRx @'
    sayWhenFree((e.name||'He')+' will remember that.');
'@ @'
    sayWhenFree(String(e.name||'He').toUpperCase()+' WILL REMEMBER THAT','ally');   // v22.xx (R54): a caps callout
'@

SubRx @'
            say(e.name+' trusted you.');
'@ @'
            say(String(e.name).toUpperCase()+' TRUSTED YOU','ally');   // v22.xx (R54): a caps callout
'@

SubRx @'
  sayWhenFree((e.name||'He')+' trusted you.');
'@ @'
  sayWhenFree(String(e.name||'He').toUpperCase()+' TRUSTED YOU','ally');   // v22.xx (R54): a caps callout
'@

SubRx @'
      if(!e.revSaid){ e.revSaid=1; say(e.name+' is coming for you.'); }
'@ @'
      if(!e.revSaid){ e.revSaid=1; say(String(e.name).toUpperCase()+' IS COMING FOR YOU','ally'); }   // v22.xx (R54): a caps callout
'@

SubRx @'
          blip('pick'); say(e.name+' pulls you up. That is what you paid for.');
'@ @'
          blip('pick'); say(String(e.name).toUpperCase()+' REVIVED YOU','ally',{sub:'That is what you paid for.'});   // v22.xx (R54): a caps callout
'@

SubRx @'
                  if(!en._shTold){ en._shTold=1; say('The slab eats it. Get behind him.'); }
'@ @'
                  if(!en._shTold){ en._shTold=1; say('THE BULWARK BLOCKED IT','info',{sub:'Get behind it.'}); }   // v22.xx (R54): the Bulwark by its name, never the slab
'@

SubRx @'
  try{ say((netSeatName(peer.seat)||'Your teammate')+' is joining the raid.'); }catch(_ls){}   // v17.62: the host hears who is coming
'@ @'
  try{ say(String(netSeatName(peer.seat)||'Your teammate').toUpperCase()+' IS JOINING THE RAID','ally'); }catch(_ls){}   // v17.62: the host hears who is coming   // v22.xx (R54): a caps callout
'@

SubRx @'
  say('You joined the raid in progress.');
'@ @'
  say('YOU JOINED THE RAID IN PROGRESS','ally');   // v22.xx (R54): a caps callout
'@

SubRx @'
  if(st==='out'&&s!==0&&typeof G!=='undefined'&&G&&!G.over&&!G.sim){ hw=netClean(m.how,12); hw=(hw==='dead')?'killed':(hw==='extract')?'extracted':(hw==='abandon')?'abandoned':''; try{ sayWhenFree(nm+' is out of this raid'+(hw?' ('+hw+')':'')+'.'); }catch(_so){} }  if(st==='no'){ NET.status=nm+' could not go up with you: '+netUpWhyText(m.why)+'.'; netRefresh(); try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree(NET.status); }catch(_sn){} }
'@ @'
  if(st==='out'&&s!==0&&typeof G!=='undefined'&&G&&!G.over&&!G.sim){ hw=netClean(m.how,12); hw=(hw==='dead')?'killed':(hw==='extract')?'extracted':(hw==='abandon')?'abandoned':''; try{ sayWhenFree(String(nm).toUpperCase()+((hw==='killed')?' DIED':(hw==='extracted')?' EXTRACTED':(hw==='abandoned')?' ABANDONED THE RAID':' IS OUT'),'ally'); }catch(_so){} }  if(st==='no'){ NET.status=nm+' could not go up with you: '+netUpWhyText(m.why)+'.'; netRefresh(); try{ if(typeof G!=='undefined'&&G&&!G.over) sayWhenFree(NET.status); }catch(_sn){} }   /* v22.xx (R54): NAME EXTRACTED, a caps callout */
'@

SubRx @'
    say(m.why==='down'?(nm+' is down and cannot take it.'):(m.why==='gone'?(nm+' is not up top any more.'):(nm+' could not hand it over.')));   // v18.23: the reason, when there is one
'@ @'
    say((m.why==='down'||m.why==='gone')?(String(nm).toUpperCase()+(m.why==='down'?' IS DOWN':' LEFT THE RAID')):'HAND-OVER FAILED','ally',{sub:(m.why==='down'||m.why==='gone')?'Cannot take it.':('With '+nm+'.')});   // v18.23: the reason, when there is one   // v22.xx (R54): a caps callout
'@

SubRx @'
  blip('pick'); say('Revived by '+(netSeatName(by)||'a teammate')+'.');
'@ @'
  blip('pick'); say(String(netSeatName(by)||'Your teammate').toUpperCase()+' REVIVED YOU','ally');   // v22.xx (R54): a caps callout
'@

SubRx @'
    if(near.netSaidT===undefined||G.t-near.netSaidT>2.5){ near.netSaidT=G.t; nm=netSeatName(near.netBy); if(!G.sim) say((nm||'One of your party')+' is searching this one.','info',{key:'netsrch'}); }
'@ @'
    if(near.netSaidT===undefined||G.t-near.netSaidT>2.5){ near.netSaidT=G.t; nm=netSeatName(near.netBy); if(!G.sim) say(String(nm||'Your teammate').toUpperCase()+' IS SEARCHING','info',{key:'netsrch'}); }   // v22.xx (R54): a caps callout
'@

SubRx @'
  if(ct&&why==='held'){ ct.netBy=(typeof m.by==='number')?(m.by|0):-1; ct.netSaidT=G.t; nm=netSeatName(ct.netBy); if(!G.sim) say((nm||'One of your party')+' is searching this one.','info',{key:'netsrch'}); }
'@ @'
  if(ct&&why==='held'){ ct.netBy=(typeof m.by==='number')?(m.by|0):-1; ct.netSaidT=G.t; nm=netSeatName(ct.netBy); if(!G.sim) say(String(nm||'Your teammate').toUpperCase()+' IS SEARCHING','info',{key:'netsrch'}); }   // v22.xx (R54): a caps callout
'@

SubRx @'
var VER='23.06';
'@ @'
var VER='23.07';
'@

$pat = "(?m)^  now:'v23\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.07: Hire orders, revives, teammates joining and leaving, and the Survivor, Peddler and pillager replies read as caps callouts. Check 23.07 fails on v23.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
