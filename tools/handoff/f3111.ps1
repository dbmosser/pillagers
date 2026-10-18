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

if ($s.Contains("  {v:'31.11',what:")) { throw "check 31.11 is in the fixture already" }

SubRx @'
  {v:'31.10',what:
'@ @'
  {v:'31.11',what:'the player 2 window starts the arcade on a clear screen too (his order of 2026-10-18: p1 and p2 should look and behave the same): its title start (NET.start) opens the welcome pack of a fresh save on the floor before the arcade is on, and that pack stayed open under the player 2 party attract and showed through the blur; after arcadeEnter p2 no window is open, and the welcome pack is not marked as taken',
   run:function(){
     if(typeof arcadeEnter!=='function'||typeof arcadeLeave!=='function'||typeof ARCADE!=='object'||!ARCADE) return 'SKIP: no arcade here';
     var m=document.getElementById('welcomemodal'), t=document.getElementById('title'), res=null, o, nsv=null, k, was=null, hadStart=false, start0=null, ownNet=false, src0, tried0, ownAtt=false, BK='', bk=null, ownBk=false;
     if(!m||!t) return 'SKIP: no welcome window or title here';
     if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(__state()&&!__state().over) __endRaid('abandon');
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       if(NET.on) return 'SKIP: a party link is up in the fixture';
       nsv={}; for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)) nsv[k]=NET[k];
       ownNet=true; NET.bc={postMessage:function(mm){},close:function(){}}; NET.pair='tp';
       src0=ATT.src; tried0=ATT.tried; ATT.src=null; ATT.tried=true; ownAtt=true;
       BK=ARCADE_BOARD_KEY; bk=localStorage.getItem(BK); ownBk=true;
       was={welcomed:P.welcomed, runs:P.runs, stash:P.stash, weapons:P.weapons};
       P.welcomed=0; P.runs=0; P.stash=[]; P.weapons=[];
       if(!welcomeFresh()) return 'SKIP: the staged profile is not a fresh one';
       hadStart=Object.prototype.hasOwnProperty.call(NET,'start'); start0=NET.start;
       NET.start=function(){ t.classList.remove('on'); showScreen('hub'); };   // what the title start does for the window: it ends on the floor, and the floor opens the first run cards
       t.classList.add('on');
       if(!titleOn()) return 'SKIP: the title could not be staged';
       if(!arcadeEnter('p2')||!ARCADE.on) return 'SKIP: arcadeEnter did not turn the arcade on';
       if(ARCADE.role!=='p2') return 'SKIP: the arcade did not take the player 2 role';
       o=document.querySelector('.modal.on');
       if(o) res='a window is still open over the player 2 party attract: '+o.id;
       return res;
     } finally {
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(hadStart) NET.start=start0; else delete NET.start; }catch(_ns){}
       try{ t.classList.remove('on'); m.classList.remove('on'); }catch(_tt){}
       try{ if(was){ P.welcomed=was.welcomed; P.runs=was.runs; P.stash=was.stash; P.weapons=was.weapons; } }catch(_w){}
       try{ if(nsv){ for(k in NET) if(Object.prototype.hasOwnProperty.call(NET,k)&&!Object.prototype.hasOwnProperty.call(nsv,k)) delete NET[k]; for(k in nsv) NET[k]=nsv[k]; } }catch(_n){}
       try{ if(ownAtt){ ATT.src=src0; ATT.tried=tried0; } }catch(_a){}
       try{ if(ownBk){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_k){}
       try{ for(var kk in keys) keys[kk]=false; }catch(_kk){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
   }},
  {v:'31.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
