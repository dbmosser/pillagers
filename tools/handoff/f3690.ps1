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

if ($s.Contains("  {v:'36.90',what:")) { throw "check 36.90 is in the fixture already" }

SubRx @'
  {v:'36.89',what:
'@ @'
  {v:'36.90',what:'the 2 player demo brings a dead player 2 window back: reopened when closed, reloaded when stuck, never when it never linked or holds its own raid (his 2.1 and 3.9)',
   run:function(){
     if(typeof arcadeMateWatch!=='function') return 'a dead player 2 window is never brought back (no arcadeMateWatch)';
     var oOpen=window.open, rs=say, sv={on:ARCADE.on,role:ARCADE.role,solo:ARCADE.solo,p2Seen:ARCADE.p2Seen,p2LostAt:ARCADE.p2LostAt,p2TryAt:ARCADE.p2TryAt,p2Told:ARCADE.p2Told,same:NET.same,pair:NET.pair,url:NET.p2url,peers:NET.peers,win:NET.p2win}, bad=[], opens=[], said=[], reloads=0, fresh={closed:false,location:{reload:function(){ reloads++; }}}, t=1000000, r, wired=false, i;
     function reset(){ ARCADE.p2Seen=0; ARCADE.p2LostAt=0; ARCADE.p2TryAt=0; ARCADE.p2Told=0; }
     try{
       say=function(m){ said.push(String(m)); };
       ARCADE.on=1; ARCADE.role='host'; ARCADE.solo=0; NET.same='host'; NET.pair='zqxpair'; NET.p2url='http://localhost/dark_raiders.html?p2=1&mode=coop&pair=zqxpair&arc=1'; reset();
       window.open=function(u,n){ opens.push(String(u)+'|'+n); return fresh; };
       // never linked: nothing is opened (the no-link watch owns that)
       NET.peers=[]; NET.p2win=null;
       r=arcadeMateWatch(t); if(r!=='never'||opens.length) bad.push('a pair that never linked tried to open a window ('+r+')');
       // linked, then the window is closed mid-run
       NET.peers=[{state:'in'}]; NET.p2win={closed:false};
       if(arcadeMateWatch(t)!=='linked') bad.push('a linked player 2 was not seen as linked');
       NET.peers=[]; NET.p2win={closed:true};
       r=arcadeMateWatch(t+100); if(r!=='lost') bad.push('the lost link was not noted ('+r+')');
       r=arcadeMateWatch(t+1500); if(r!=='wait'||opens.length) bad.push('the window was reopened before the grace time ('+r+')');
       r=arcadeMateWatch(t+3500); if(r!=='reopen'||opens.length!==1) bad.push('the closed player 2 window was not opened again ('+r+', '+opens.length+' opens)');
       if(opens.length&&(opens[0].indexOf('pair=zqxpair')<0||opens[0].indexOf('arc=1')<0||opens[0].split('|')[1]!=='pillagers_p2')) bad.push('the reopened window has the wrong address or name: '+opens[0]);
       if(NET.p2win!==fresh) bad.push('the new window was not kept as the player 2 handle');
       if(said.indexOf('player 2 window reopening')<0) bad.push('the feed did not say the window is reopening');
       fresh.closed=false; r=arcadeMateWatch(t+3600); if(opens.length!==1) bad.push('the window was opened twice in a row ('+r+')');
       // the link comes back: the watch resets for the next loss
       NET.peers=[{state:'in'}]; if(arcadeMateWatch(t+9000)!=='linked'||ARCADE.p2LostAt) bad.push('a relinked player 2 did not reset the watch');
       // a blocked open is tried again later
       NET.peers=[]; NET.p2win={closed:true}; window.open=function(u,n){ opens.push('blocked'); return null; };
       arcadeMateWatch(t+10000); r=arcadeMateWatch(t+13500); if(r!=='blocked') bad.push('a blocked open was not reported ('+r+')');
       r=arcadeMateWatch(t+14000); if(r!=='wait') bad.push('a blocked open was tried again at once ('+r+')');
       window.open=function(u,n){ opens.push('again'); return fresh; };
       r=arcadeMateWatch(t+16200); if(r!=='reopen'||opens[opens.length-1]!=='again') bad.push('a blocked open was not tried again ('+r+')');
       // an open window that stopped answering is reloaded after 10 s, but not while it holds a raid
       NET.peers=[{state:'in'}]; arcadeMateWatch(t+20000); NET.peers=[]; NET.p2win=fresh; fresh.closed=false;
       arcadeMateWatch(t+20100); r=arcadeMateWatch(t+25000); if(r!=='wait'||reloads) bad.push('a live window was reloaded too soon ('+r+')');
       r=arcadeMateWatch(t+30500); if(r!=='reload'||reloads!==1) bad.push('a stuck player 2 window was not reloaded ('+r+', '+reloads+')');
       // the 1 player demo and a window outside the demo are untouched
       ARCADE.solo=1; NET.p2win={closed:true}; reset(); ARCADE.p2Seen=1; ARCADE.p2LostAt=1; i=opens.length; r=arcadeMateWatch(t+90000);
       if(r!=='off'||opens.length!==i) bad.push('the 1 player demo tried to open a player 2 window ('+r+')');
       ARCADE.solo=0; ARCADE.on=0; r=arcadeMateWatch(t+90000); if(r!=='off') bad.push('outside the demo the watch is not off ('+r+')');
       // and it is wired to a timer
       for(i=0;i<document.scripts.length;i++) if(/setInterval\(function\(\)\{ try\{ arcadeMateWatch\(Date\.now\(\)\)/.test(document.scripts[i].text)) wired=true;
       if(!wired) bad.push('the watch has no timer');
       return bad.length?bad.join('; '):null;
     } finally {
       window.open=oOpen; say=rs;
       ARCADE.on=sv.on; ARCADE.role=sv.role; ARCADE.solo=sv.solo; ARCADE.p2Seen=sv.p2Seen; ARCADE.p2LostAt=sv.p2LostAt; ARCADE.p2TryAt=sv.p2TryAt; ARCADE.p2Told=sv.p2Told;
       NET.same=sv.same; NET.pair=sv.pair; NET.p2url=sv.url; NET.peers=sv.peers; NET.p2win=sv.win;
     } }},
  {v:'36.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
