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

if ($s.Contains("  {v:'21.91',what:")) { throw "check 21.91 is in the fixture already" }

SubRx @'
  {v:'21.90',what:
'@ @'
  {v:'21.91',what:'the waiting queue: no copies, at most four, the highest rank first, a line that outranks the rows said at once, a keyed line refreshed in place, and a line waiting behind two rows shows within 4 s while a full backpack is said every frame on one row',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__loop)) return 'SKIP: this fixture cannot deploy or step the loop';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     if(typeof feedRows!=='function'||typeof bagWeight!=='function') return 'SKIP: no message rows or no backpack weight here';
     var bad=[], g, p, realSay=say, keepBW=bagWeight, keepAuto=P.autoloot, BF=['Backpack','full'].join(' '), t0, f=0, i, n, rows, box=null, firstQ=-1, maxBF=0;
     function clr(){ g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[]; g.msgAt=undefined; g.msgKey=''; }
     function cnt(s){ var q=g.msgQ||[], c=0; for(var j=0;j<q.length;j++) if(q[j]===s) c++; return c; }
     function step(){ __loop(t0+(++f)*16.7); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.ents.length=0; g.waveT=-1e9;
       // only the probe lines and the backpack line may speak, the queue included (it says through say)
       say=function(m){ var s=String(m); if(s.indexOf('zq')===0||s.indexOf('ZQ')===0||s.indexOf(BF)===0) return realSay.apply(this,arguments); };
       t0=performance.now();
       // ONE: no copies, and at most four waiting (two warnings on the rows, so ordinary lines wait)
       clr(); say('ZQ W1','warn'); say('ZQ W2','warn');
       sayWhenFree('zq dup'); sayWhenFree('zq dup');
       if(cnt('zq dup')!==1) bad.push('the same line waits '+cnt('zq dup')+' times over');
       for(i=1;i<=5;i++) sayWhenFree('zq c'+i);
       if((g.msgQ||[]).length>4) bad.push('the queue holds '+g.msgQ.length+' lines, more than four');
       // TWO: the highest rank comes out first
       clr(); say('ZQ W1','warn'); say('ZQ W2','warn');
       sayWhenFree('zq i1'); sayWhenFree('zq o1','obj');
       g.msgAt=-1e3; if(g.feed&&g.feed[1]) g.feed[1].at=-1e3;   // both rows past their protection, still showing
       step();
       if(g.msg!=='zq o1') bad.push('with an ordinary line and an objective waiting, '+JSON.stringify(g.msg)+' came out first, not the objective');
       // THREE: a line that outranks every row showing is said at once
       clr(); say('zq p1'); say('zq p2'); sayWhenFree('ZQ BIG','warn');
       if(g.msg!=='ZQ BIG') bad.push('a warning sent to wait behind two ordinary rows waited instead of showing at once');
       // FOUR: a keyed line said again with new words refreshes its row instead of taking a second one
       clr(); say('zq k 1','info',{key:'zqk'}); say('zq k 2','info',{key:'zqk'});
       rows=feedRows(); n=0; for(i=0;i<rows.length;i++) if(String(rows[i].m).indexOf('zq k ')===0) n++;
       if(g.msg!=='zq k 2'||n!==1) bad.push('a keyed line said twice fills '+n+' rows (top '+JSON.stringify(g.msg)+')');
       // FIVE, THE PLAY PATH: a line waits behind two rows while X is held on a box with the backpack full
       for(i=0;i<g.containers.length;i++){ var c=g.containers[i]; if(c&&!c.opened&&c.loot&&c.loot.length&&!c.cache&&!c.strong&&!c.auto){ box=c; break; } }
       if(!box) bad.push('SKIP: no box to stage the full backpack on');
       else {
         box.x=p.x+20; box.y=p.y; box.opened=false; box.prog=0; p.downed=false;
         P.autoloot=0; bagWeight=function(){ return 1e9; };
         clr(); say('zq s1'); say('zq s2'); sayWhenFree('zq q');
         if(cnt('zq q')!==1) bad.push('staging: the probe line did not wait behind two rows');
         keys['KeyX']=true;
         for(i=0;i<360;i++){
           step(); if(g.over) break;
           rows=feedRows(); n=0;
           for(var r=0;r<rows.length;r++){ if(String(rows[r].m).indexOf(BF)===0) n++; if(rows[r].m==='zq q'&&firstQ<0) firstQ=i; }
           if(n>maxBF) maxBF=n;
         }
         keys={};
         if(maxBF<1) bad.push('SKIP: the full backpack line was never said, so the play path was not staged');
         if(maxBF>1) bad.push('the backpack full line said every frame filled '+maxBF+' rows');
         if(firstQ<0) bad.push('the waiting line never showed in 6 s of X held on a full backpack');
         else if(firstQ>240) bad.push('the waiting line took '+(firstQ/60).toFixed(1)+' s to show, more than 4 s');
       }
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       say=realSay; keys={}; bagWeight=keepBW; P.autoloot=keepAuto;
       try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; g2.msgKey=''; } if(g2&&!g2.over){ g2.player.downed=false; g2.searching=null; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     for(i=0;i<bad.length;i++) if(bad[i].indexOf('SKIP: ')===0&&bad.length===1) return bad[0];
     return bad.length?bad.join('; '):null; }},
  {v:'21.90',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
