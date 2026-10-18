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

if ($s.Contains("  {v:'31.15',what:")) { throw "check 31.15 is in the fixture already" }

SubRx @'
  {v:'31.14',what:
'@ @'
  {v:'31.15',what:'the team strip (JOIN YOUR TEAM, TEAM SCORE) of a waiting party window is not drawn behind the how to play card (his order of 2026-10-18: p1 and p2 should look and behave the same): while a run is live and the player 2 window waits on the how to play page, the strip sits clear of the card, under it, and still reads join your team',
   run:function(){
     if(typeof arcadeEnter!=='function'||typeof arcadeLeave!=='function'||typeof arcadeAttShow!=='function'||typeof ARCADE!=='object'||!ARCADE) return 'SKIP: no arcade here';
     if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
     var res=null, nsv=null, k, src0, tried0, ownAtt=false, BK='', bk=null, ownBk=false, d, pg, sp, rp, rs, tx, sc0=0;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(__state()&&!__state().over) __endRaid('abandon');
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       nsv={}; for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) nsv[k]=NET[k];
       NET.bc={postMessage:function(mm){},close:function(){}}; NET.pair='tp';
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true; ownAtt=true;
       BK=ARCADE_BOARD_KEY; bk=localStorage.getItem(BK); ownBk=true;
       if(!arcadeEnter('p2')||!ARCADE.on||ARCADE.role!=='p2') return 'SKIP: the arcade did not take the player 2 role';
       sc0=ARCADE.scSeen; ARCADE.scSeen=Date.now();   // the host score word was heard just now: a run is live and this window waits
       arcadeAttShow();
       d=document.getElementById('attract'); pg=d&&d.querySelector('.arcpage'); sp=d&&d.querySelector('.arcstrip');
       if(!pg||!sp) return 'SKIP: the attract has no page or strip here';
       if(pg.style.display!=='block') return 'SKIP: the how to play page is not up ('+(ARCADE.att&&ARCADE.att.ph)+')';
       if(sp.style.display==='none'||!String(sp.textContent||'').trim()) return 'the waiting window draws no team strip while a run is live';
       tx=String(sp.textContent).toLowerCase();
       if(tx.indexOf('join your team')<0) res='the strip does not say join your team ('+tx.slice(0,40)+')';
       rp=pg.getBoundingClientRect(); rs=sp.getBoundingClientRect();
       if(!(rp.height>40&&rs.height>4)) return 'SKIP: the page or the strip has no size here';
       if(rs.top<rp.bottom-1&&rs.bottom>rp.top+1) res=(res?res+'; ':'')+'the team strip ('+Math.round(rs.top)+' to '+Math.round(rs.bottom)+') is drawn behind the how to play card ('+Math.round(rp.top)+' to '+Math.round(rp.bottom)+')';
       return res;
     } finally {
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(typeof ARCADE==='object') ARCADE.scSeen=0; }catch(_s){}
       try{ if(nsv){ for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(nsv,k)) delete NET[k]; for(k in nsv) NET[k]=nsv[k]; } }catch(_n){}
       try{ if(ownAtt){ ATT.src=src0; ATT.tried=tried0; } }catch(_a){}
       try{ if(ownBk){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_k){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_kk){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
   }},
  {v:'31.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
