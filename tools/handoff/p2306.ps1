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

# OBJECTIVE LINES IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(!G.sim) say('CONTRACT DONE: '+contractDesc(c)+'. Complete contract at mainframe.');
'@ @'
    // v22.xx, the raid text rewrite (R53): his words, split at his colon for display only. CONTRACT DONE is the headline and the rest,
    // word for word with his lowercase mainframe, is the detail.
    if(!G.sim) say('CONTRACT DONE','obj',{sub:contractDesc(c)+'. Complete contract at mainframe.'});
'@

SubRx @'
        if(e.boss){ var cb=setLoot(mkContainer(e.x+40,e.y+10,'cache'),['reactor','codex','bloom','titan','coil']); cb.cache=1; cb.time=3.0; cb.tag='OVERSEER HOARD'; G.containers.push(cb); say(e.name+' is down. Its hoard is open.'); }   // v17.45: his pick 21
'@ @'
        if(e.boss){ var cb=setLoot(mkContainer(e.x+40,e.y+10,'cache'),['reactor','codex','bloom','titan','coil']); cb.cache=1; cb.time=3.0; cb.tag='OVERSEER HOARD'; G.containers.push(cb); say(String(e.name).toUpperCase()+' DESTROYED','obj',{sub:'Its hoard is open.'}); }   // v17.45: his pick 21   // v22.xx (R53): an objective row in caps
'@

SubRx @'
        say(e.name+' is down. Its core is exposed.');
'@ @'
        if(!e.boss) say(String(e.name).toUpperCase()+' DESTROYED','obj',{sub:'It dropped a cache.'});   // v22.xx (R53): not said again for the boss
'@

SubRx @'
        say(e.name+' has stopped singing.');
'@ @'
        say(String(e.name).toUpperCase()+' DESTROYED','obj',{sub:'Search the wreck.'});   // v22.xx (R53): an objective row in caps
'@

SubRx @'
        if(!G.sim) say(e.name+' destroyed. It dropped a cache.');   // v11.94, HIS NOTE: he could not tell this was a death
'@ @'
        if(!G.sim) say(String(e.name).toUpperCase()+' DESTROYED','obj',{sub:'It dropped a cache.'});   // v11.94, HIS NOTE: he could not tell this was a death   // v22.xx (R53): an objective row in caps
'@

SubRx @'
  if(e&&e.name===BOSS_NAME){ try{ say(BOSS_NAME+' is down. Its hoard is open.'); }catch(_bs){} }   // v17.56: the teammate hears the boss go down, as the host does
'@ @'
  if(e&&e.name===BOSS_NAME){ try{ say(BOSS_NAME+' DESTROYED','obj',{sub:'Its hoard is open.'}); }catch(_bs){} }   // v17.56: the teammate hears the boss go down, as the host does   // v22.xx (R53): an objective row in caps
'@

SubRx @'
        say(e.name+' is down. His family will be told, and billed to you.');
'@ @'
        say(String(e.name).toUpperCase()+' IS DEAD','obj',{sub:'You owe his family.'});   // v22.xx (R53): an objective row in caps
'@

SubRx @'
      say(doorNear.name+' is open.'); blip('pick'); ping(p.x,p.y,340,false,false,'player','move');
'@ @'
      say((doorNear.name+' open').toUpperCase(),'obj'); blip('pick'); ping(p.x,p.y,340,false,false,'player','move');   // v22.xx (R53): an objective row in caps
'@

SubRx @'
    if(lockedOpen(Lk[i])){ say(Lk[i].name+' is open.'); if(NET.role==='host') netBroadcast({t:'door',sd:G.seed>>>0,id:m.id}); }
'@ @'
    if(lockedOpen(Lk[i])){ say((Lk[i].name+' open').toUpperCase(),'obj'); if(NET.role==='host') netBroadcast({t:'door',sd:G.seed>>>0,id:m.id}); }   // v22.xx (R53): an objective row in caps
'@

SubRx @'
          say('The seal is cut. Whatever Meridian put behind it is yours if you live.');
'@ @'
          say('SEAL BROKEN','obj',{sub:'What Meridian sealed is yours if you live.'});   // v22.xx (R53): an objective row in caps
'@

SubRx @'
          if(!G.sim) say('Something fused in the ground where that landed.');
'@ @'
          if(!G.sim) say('LIGHTNING FUSED A CACHE','obj');   // v22.xx (R53): an objective row in caps
'@

SubRx @'
  if(_hotLine) sayWhenFree(_hotLine);
'@ @'
  if(_hotLine) sayWhenFree('HOT GROUND','obj',{sub:'Extra loot in here.'});   // v22.xx (R53): an objective row in caps
'@

SubRx @'
    if(m.hot===1){ if(T) T.hotOpened=(T.hotOpened||0)+1; if(!G.sim) sayWhenFree('Hot ground. Extra loot in here.'); }   // v20.39 (H59): the bonus the host rolled for this search
'@ @'
    if(m.hot===1){ if(T) T.hotOpened=(T.hotOpened||0)+1; if(!G.sim) sayWhenFree('HOT GROUND','obj',{sub:'Extra loot in here.'}); }   // v20.39 (H59): the bonus the host rolled for this search   // v22.xx (R53): an objective row in caps
'@

SubRx @'
    say('The hot ground has moved. Check your map.');
'@ @'
    say('HOT GROUND MOVED','obj',{sub:'Check your map.'});   // v22.xx (R53): an objective row in caps
'@

SubRx @'
    if(k>(a.moves|0)){ a.moves=k; a.at=0; if(!G.sim) say('The hot ground has moved. Check your map.'); }
'@ @'
    if(k>(a.moves|0)){ a.moves=k; a.at=0; if(!G.sim) say('HOT GROUND MOVED','obj',{sub:'Check your map.'}); }   // v22.xx (R53): an objective row in caps
'@

SubRx @'
      if(!G.sim&&dist(_rc,G.player)<700) say('Something restocked nearby.');
'@ @'
      if(!G.sim&&dist(_rc,G.player)<700) say('SOMETHING RESTOCKED NEARBY','chat');   // v22.xx (R53): a chat row in caps
'@

SubRx @'
    if(!G.sim&&G.player&&dist(ct,G.player)<700) say('Something restocked nearby.');
'@ @'
    if(!G.sim&&G.player&&dist(ct,G.player)<700) say('SOMETHING RESTOCKED NEARBY','chat');   // v22.xx (R53): a chat row in caps
'@

SubRx @'
var VER='23.05';
'@ @'
var VER='23.06';
'@

$pat = "(?m)^  now:'v23\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.06: Contract, kill, door, seal and hot ground lines read as caps callouts, with his contract words kept whole as the detail. Check 23.06 fails on v23.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
