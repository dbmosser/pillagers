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

if ($s.Contains("  {v:'21.88',what:")) { throw "check 21.88 is in the fixture already" }

SubRx @'
  {v:'21.87',what:
'@ @'
  {v:'21.88',what:'a lower line cannot push a higher one off: with a warning and a line on the two message rows, a third ordinary line takes the ordinary row and the one it took waits in the queue, the warning stays, and the waiting line shows once the rows are past their protection',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__loop)) return 'SKIP: this fixture cannot deploy or step the loop';
     if(window.__vpAlive&&!__vpAlive()) return 'SKIP: the pane has no layout, so the frame loop cannot draw';
     var bad=[], ev=[], g, realSay=say, HI=['ZQ','HIGH'].join(' '), L1=['zq','lo','1'].join(' '), L2=['zq','lo','2'].join(' '), oFT=ctx.fillText, dr={}, j, i, t0, f=0, seen=[];
     function unspy(){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       keys={}; g.mapOpen=false; g.bagOpen=false; g.ents.length=0; g.waveT=-1e9;
       g.msgT=0; g.msg=''; g.msgQ=[]; g.msgQM=[]; g.feed=[];
       // only the probe lines may speak, the queue included (it says through say)
       say=function(m){ var s=String(m); if(s.indexOf('zq')===0||s.indexOf('ZQ')===0) return realSay.apply(this,arguments); };
       say(HI,'warn'); say(L1); say(L2);
       ctx.fillText=function(t){ dr[String(t)]=1; return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { unspy(); }
       if(!dr[HI]) bad.push('the warning was pushed off the rows by two ordinary lines');
       if(!dr[L2]) bad.push('the newest line was not drawn');
       if(dr[L1]) bad.push('the line the newest took the place of is still drawn');
       if(!((g.msgQ||[]).indexOf(L1)>=0)) bad.push('the line given way is not waiting in the queue ['+(g.msgQ||[]).join(' | ')+']');
       t0=performance.now();
       for(i=0;i<126;i++){ __loop(t0+(++f)*16.7); if(g.over) break; if(g.msgT>0&&seen.indexOf(g.msg)<0) seen.push(String(g.msg)); }
       if(seen.indexOf(L1)<0) bad.push('the waiting line never came back on screen in 2.1 s [shown: '+seen.join(' | ')+']');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{ unspy(); say=realSay; keys={}; try{ var g2=__state(); if(g2){ g2.msgT=0; g2.msg=''; g2.feed=[]; g2.msgQ=[]; g2.msgQM=[]; } if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
