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

if ($s.Contains("  {v:'16.82',what:")) { throw "check 16.82 is in the fixture already" }

SubRx @'
  {v:'16.81',what:
'@ @'
  {v:'16.82',what:'the player 2 window lists no saves on the title: no player 1 save rows, no DELETE, no ERASE row and no CREATE A NEW SAVE, one line saying player 2 plays its own save; the player 1 window keeps the full list',
   run:function(){
     if(typeof NETP2==='undefined'||typeof titleRefresh!=='function'||!document.getElementById('slotlist')||!document.getElementById('newgame')) return 'SKIP: this build has no player 2 window or no title save list';
     if(NETP2) return 'SKIP: this page was itself opened with ?p2=1, so the player 1 control cannot be drawn here';
     var bad=[], o2=NETP2, host=document.getElementById('slotlist'), ng=document.getElementById('newgame'), K7='salvagerun:profile:7', had7=null, need='Player 2 plays its own '+'save on this machine', txt, rows, dels, i, seven;
     try{
       try{ had7=localStorage.getItem(K7); }catch(_h){}
       // a second player 1 save, so the list would draw a DELETE row if it drew at all
       try{ if(had7===null) localStorage.setItem(K7,JSON.stringify({pname:'SEVENTH',runs:3,credits:1234,xp:56})); }catch(_s){}
       NETP2=true; titleRefresh();
       rows=host.querySelectorAll('[data-slot]').length; dels=host.querySelectorAll('[data-del]').length;
       txt=String(host.textContent||'');
       if(rows) bad.push('the player 2 window lists '+rows+' player 1 save rows');
       if(dels) bad.push('the player 2 window draws '+dels+' DELETE buttons over player 1 saves');
       if(document.getElementById('delgo')) bad.push('the player 2 window still draws the ERASE row');
       if(ng.style.display!=='none') bad.push('CREATE A NEW SAVE still shows in the player 2 window');
       if(txt.indexOf(need)<0) bad.push('the player 2 window does not say that player 2 plays its own save (it says: '+txt.slice(0,80)+')');
       NETP2=o2; titleRefresh();
       // control: the player 1 window keeps the list
       rows=host.querySelectorAll('[data-slot]'); seven=false;
       for(i=0;i<rows.length;i++) if(rows[i].getAttribute('data-slot')==='7') seven=true;
       if(!seven) bad.push('control: the player 1 window no longer lists save 7');
       if(ng.style.display==='none') bad.push('control: CREATE A NEW SAVE is hidden in the player 1 window');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ NETP2=o2; try{ if(had7===null) localStorage.removeItem(K7); }catch(_r){} try{ titleRefresh(); }catch(_t){} }
     return bad.length?bad.join('; '):null; }},
  {v:'16.81',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
