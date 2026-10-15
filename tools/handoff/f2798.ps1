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

if ($s.Contains("  {v:'27.98',what:")) { throw "check 27.98 is in the fixture already" }

SubRx @'
  {v:'27.97',what:
'@ @'
  {v:'27.98',what:'his order 2026-10-15 (career leaderboard): every CAREER extraction and death goes on the board by raid score with its run count, a run outside the top 20 knows its rank, the board view draws the DEMO board look, and the DEMO line builder is unchanged',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof careerBoardAdd!=='function'||typeof careerBoardView!=='function') return 'the CAREER board keeps no run count, no death rows and has no board view (cboard1)';
     var bad=[], g, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, b0=P.careerBoard, hb=('careerBoard' in P), r0=P.careerRuns, hr=('careerRuns' in P), a0=P.careerAll, ha=('careerAll' in P), bb0=P.careerBest, cr0=P.credits, R, R2, h, pg, rows, i, hl, tx, d;
     try{
       __topClear(); __runPrep();
       P.careerBoard=[{s:500,k:2,m:0,t:1000,n:'OLD'}]; delete P.careerRuns; delete P.careerAll;
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       if(!g.career||!g.cs) return 'SKIP: no CAREER raid in this build';
       g.cs.s=300; g.cs.k=2;
       __endRaid('dead');
       R=g.careerLb;
       if(!R) bad.push('a CAREER death left no board result');
       else if(R.rank!==2||R.total!==2) bad.push('a 300 death after an old 500 row ranked #'+R.rank+' of '+R.total+', not #2 of 2');
       if(!Array.isArray(P.careerBoard)||P.careerBoard.length!==2||P.careerBoard[1].o!=='k'||P.careerBoard[1].s!==300) bad.push('the death is not the second row on the board ('+JSON.stringify(P.careerBoard)+')');
       if(P.careerRuns!==2) bad.push('the run count is '+P.careerRuns+', not 2 (the old row seeded one)');
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return bad.concat(['SKIP: no second raid']).join('; ');
       g.cs.s=0; g.cs.b=null;
       scoreBonus(50,0,0,'TEST'); flowChip(100,'GOAL DONE','TEST');
       if(!g.cs.b||g.cs.b.style!==50||g.cs.b.goal!==100) bad.push('the score tally is '+JSON.stringify(g.cs.b)+', not style 50 and goal 100');
       if(g.cs.s!==150) bad.push('the score is '+g.cs.s+', not 150');
       g.cs.s=400; g.cs.k=3;
       __endRaid('extract');
       R=g.careerLb;
       if(!R||R.score!==800||R.rank!==1||R.total!==3||!R.best) bad.push('a 400 extraction (800 banked) came back '+JSON.stringify(R&&{score:R.score,rank:R.rank,total:R.total,best:R.best}));
       for(i=0;i<22;i++) careerBoardAdd('extract',1000+i*10);
       if(P.careerBoard.length!==20) bad.push('the board holds '+P.careerBoard.length+' rows, not 20');
       R2=careerBoardAdd('dead',5);
       if(R2.inTop||R2.rank!==P.careerRuns||P.careerBoard.length!==20) bad.push('a 5 run outside the top 20 came back '+JSON.stringify({inTop:R2.inTop,rank:R2.rank,total:P.careerRuns,rows:P.careerBoard.length}));
       h=document.createElement('div');
       pg=careerBoardView(h,{row:R2.row,rank:R2.rank,inTop:R2.inTop,best:false,anim:0});
       rows=pg?pg.querySelectorAll('.apr'):[];
       if(rows.length!==22) bad.push('the board draws '+rows.length+' lines, not 1 header + 20 + 1 pinned');
       hl=pg?pg.querySelectorAll('.hl'):[];
       if(hl.length!==1||hl[0]!==rows[rows.length-1]) bad.push('the run outside the top 20 is not the one pinned row at the bottom');
       tx=pg?pg.textContent:'';
       if(tx.indexOf('RANK #'+R2.rank+' OF '+P.careerRuns)<0) bad.push('no RANK #N OF M readout');
       if(tx.indexOf('OUTCOME')<0||tx.indexOf('SECTOR')<0||tx.indexOf('DATE')<0||tx.indexOf('KIA')<0) bad.push('the columns or the KIA word are missing');
       h=document.createElement('div');
       pg=careerBoardView(h,{row:P.careerBoard[0],rank:1,inTop:true,best:true,anim:1});
       if(!pg||!pg.querySelector('.lbpb')||pg.querySelector('.lbpb').textContent!=='NEW PERSONAL BEST') bad.push('no NEW PERSONAL BEST plate on a number one');
       if(!pg||pg.querySelectorAll('.hl').length!==1||!pg.querySelector('.lbmove')) bad.push('the number one row is not the one climbing row');
       lbCountEnd(h);
       d=pg?pg.querySelector('.lbmove'):null;
       if(!d||d.children[1].textContent!==arcadeCr(P.careerBoard[0].s)) bad.push('the climbing row score did not land on its figure');
       h=document.createElement('div'); careerBoardView(h,{}); lbCountEnd(h);
       if(h.querySelectorAll('.hl').length!==0) bad.push('the board in the Undercroft highlights a row');
       d=document.createElement('div'); arcadeAttLine(d,'apr','1.  ABC','$100');
       if(d.children.length!==1||d.children[0].className!=='apr'||d.children[0].children.length!==2||d.children[0].children[1].textContent!=='$100') bad.push('the DEMO board line is no longer two spans');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ CAREER_ON=c0; }catch(_r){}
       try{ if(hb) P.careerBoard=b0; else delete P.careerBoard; if(hr) P.careerRuns=r0; else delete P.careerRuns; if(ha) P.careerAll=a0; else delete P.careerAll; if(bb0===undefined) delete P.careerBest; else P.careerBest=bb0; P.credits=cr0; }catch(_b){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'27.97',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
