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

if ($s.Contains("  {v:'20.35',what:")) { throw "check 20.35 is in the fixture already" }

SubRx @'
  {v:'20.34',what:
'@ @'
  {v:'20.35',what:'player 1 never opens a fresh player 2 window over a raid still running there: with the raid mark fresh and no link, the 2 player pick opens nothing and says why; with no mark it opens the window as before',
   run:function(){
     if(typeof netSamePick!=='function'||typeof NET!=='object'||!NET) return 'SKIP: no same machine play here';
     var NK={}, k, bad=[], oOpen=window.open, opened=0, started=0, rk='salvagerun:p2raid', lk='salvagerun:p2live', r0=null, l0=null, r, g0;
     for(k in NET) NK[k]=NET[k];
     try{ r0=localStorage.getItem(rk); l0=localStorage.getItem(lk); }catch(_r){}
     try{
       NET.same=null; NET.role=null; NET.peers=[]; NET.p2win=null;
       window.open=function(){ opened++; return null; };
       localStorage.setItem(rk,String(Date.now()));
       r=netSamePick('coop',function(){ started++; });
       if(opened) bad.push('the 2 player pick opened a window over the player 2 raid ('+r+')');
       if(started) bad.push('the host side started over the player 2 raid');
       localStorage.removeItem(rk); opened=0;
       r=netSamePick('coop',function(){ started++; });
       if(r!=='unsupported'&&opened!==1) bad.push('with no raid in the player 2 window the pick opened '+opened+' windows ('+r+')');
       if(typeof p2LiveBeat==='function'&&window.__deploy&&window.__endRaid){
         __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         g0=__state();
         if(g0&&!g0.over){ p2LiveBeat(); if(!localStorage.getItem(rk)) bad.push('a window in a raid leaves no raid mark'); g0.player.downed=false; __endRaid('abandon'); p2LiveBeat(); if(localStorage.getItem(rk)) bad.push('the raid mark stays after the raid'); }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       window.open=oOpen;
       try{ if(r0===null) localStorage.removeItem(rk); else localStorage.setItem(rk,r0); if(l0===null) localStorage.removeItem(lk); else localStorage.setItem(lk,l0); }catch(_w){}
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ netModeMsg(''); }catch(_m){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.34',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
