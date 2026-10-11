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

if ($s.Contains("  {v:'23.29',what:")) { throw "check 23.29 is in the fixture already" }

SubRx @'
  {v:'23.28',what:
'@ @'
  {v:'23.29',what:'arcade8, his order 2026-10-11: in the arcade a credited kill scores into this window score (a crawler 50), the teammate score comes in on arcsc for this run only, the window tells its own score back, and the clock spot shows TEAM SCORE over the sum',
   run:function(){
     var bad=[], g, p, e, f, cx=null, ft=null, own=false, seen=[], r, sv=null, out=[], id, i, got=false, nT='TEAM SC'+'ORE';
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(typeof arcadeTeam!=='function'||typeof arcadeOnMsg!=='function') return 'no team score in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       sv={bc:NET.bc,pair:NET.pair};
       NET.bc={postMessage:function(m){ out.push(m); },close:function(){}}; NET.pair='tp';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player;
       if(!ARCADE.run||!ARCADE.run.id) return 'the host arcade raid has no run id';
       id=ARCADE.run.id;
       if(arcadeTeam()!==0) bad.push('a fresh arcade raid starts at '+arcadeTeam());
       e=mkCrawler(p.x+300,p.y); e.byPlayer=1; e.elite=0; e.hp=0; g.ents.push(e);
       __ents(0.016);
       if(g.ents.indexOf(e)>=0) bad.push('the crawler did not die');
       if(ARCADE.mine!==50) bad.push('a crawler kill gave ARCADE.mine '+ARCADE.mine+', not 50');
       r=arcadeOnMsg({t:'arcsc',run:id,s:400,k:3,x:0});
       if(r!=='arcsc') bad.push('arcsc for this run answered '+r);
       if(arcadeTeam()!==450) bad.push('the team score is '+arcadeTeam()+', not 50 plus 400');
       arcadeOnMsg({t:'arcsc',run:'zz'+'other',s:9000});
       if(arcadeTeam()!==450) bad.push('a word for another run counted ('+arcadeTeam()+')');
       out.length=0; ARCADE.scDirty=1; ARCADE.scAt=0; arcadeScFlush(Date.now());
       for(i=0;i<out.length;i++) if(out[i]&&out[i].t==='arcsc'&&out[i].run===id&&out[i].s===50&&out[i].k===1) got=true;
       if(!got) bad.push('the host did not tell its own score (arcsc s 50 k 1) for the run');
       if(!g.over&&__state()===g){
         ARCADE.banner=null;
         cx=hcv.getContext('2d'); ft=cx.fillText; own=true;
         cx.fillText=function(s){ seen.push(String(s)); return ft.apply(this,arguments); };
         for(f=0;f<3;f++) __loop(performance.now()+f*16.7);
         if(!seen.length){ try{ drawHUD(); }catch(_dh){} }
         delete cx.fillText; own=false;
         if(seen.indexOf(nT)<0) bad.push('the HUD shows no TEAM SCORE label');
         if(seen.indexOf('4'+'50')<0) bad.push('the HUD shows no team score of 450');
       } else bad.push('the arcade raid ended');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own&&cx){ try{ delete cx.fillText; }catch(_df){} }
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(sv){ NET.bc=sv.bc||null; NET.pair=sv.pair||''; } }catch(_ns){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
