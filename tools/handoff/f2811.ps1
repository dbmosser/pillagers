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

if ($s.Contains("  {v:'28.11',what:")) { throw "check 28.11 is in the fixture already" }

SubRx @'
  {v:'28.10',what:
'@ @'
  {v:'28.11',what:'career9, his answer that the needed-item glow must say why: the first time a box with a contract item is near, one caps callout says what the gold glow is (once for the save); the item row in the pickup stack carries NEEDED . CONTRACT from the moment it is made and a second pick-up still counts into that row; and the backpack name line carries it in gold',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__runPrep&&window.__endRaid&&window.__P&&window.__applyLoaded&&window.__drawBagWith)) return 'SKIP: this fixture cannot deploy';
     if(typeof needHint!=='function') return 'there is no needed-item hint in this build';
     if(typeof mkContainer!=='function'||typeof setLoot!=='function'||typeof pickSay!=='function') return 'SKIP: no raid pieces here';
     var bad=[], snap=null, g=null, p=null, q, ct, said=[], oSay=say, rec=[], oFT=null, row, i, st, c0=(typeof CAREER_ON==='number')?CAREER_ON:0, ix, cells;
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player; p.iv=99; p.hp=100; p.downed=false; g.ents.length=0;
       q=__P(); q.contracts=[{type:'exItem',item:'board',n:2,prog:0,reward:100,desc:'Extract carrying 2x Circuit Board'}]; delete q.needTold;
       say=function(m,k,o){ said.push(String(m)+'|'+((o&&o.sub)||'')); };
       // ONE: the hint, once
       g.bag=[]; g.carriedKit=[];
       for(i=0;i<g.containers.length;i++) g.containers[i].opened=1;   // OWN THE INPUT: the map has its own boxes near the spawn, and one holding the item would raise the hint in every step below
       ct=mkContainer(p.x+200,p.y,'crate'); setLoot(ct,['scrap','board']); g.containers.push(ct);
       g.cxT=0; careerTick(0.016);
       if(said.join('~').indexOf('CONTRACT ITEM NEARBY|GOLD GLOW MARKS THE BOX')<0) bad.push('ONE: no hint with a contract box 20 metres off ('+said.join('~')+')');
       if(q.needTold!==1) bad.push('ONE: the hint was not kept in the save');
       said.length=0; g.cxT=0; careerTick(0.016);
       if(said.length) bad.push('ONE: the hint was said twice');
       // TWO: no hint for a box that is far, shut without the item, or when nothing is needed
       delete q.needTold; ct.x=p.x+2000; g.cxT=0; careerTick(0.016);
       if(said.length||q.needTold) bad.push('TWO: a far box raised the hint ('+said.join('~')+')');
       ct.x=p.x+200; ct.loot=['scrap']; g.cxT=0; careerTick(0.016);
       if(said.length||q.needTold) bad.push('TWO: a box without the item raised the hint');
       // THREE: the pickup row says why, counts, and a plain item does not
       g.pick=[]; g.need={board:2}; g.needN=1;
       pickSay('Circuit Board',{item:'board'}); pickSay('Circuit Board',{item:'board'}); pickSay('Scrap',{item:'scrap'});
       row=g.pick.filter(function(r){ return r.item==='board'; });
       if(row.length!==1) bad.push('THREE: '+row.length+' rows for two boards');
       else { if(row[0].tag!=='NEEDED \u00b7 CONTRACT') bad.push('THREE: the board row reads tag "'+row[0].tag+'"'); if(row[0].n!==2) bad.push('THREE: the board row counts '+row[0].n); }
       row=g.pick.filter(function(r){ return r.item==='scrap'; });
       if(row.length!==1||row[0].tag) bad.push('THREE: the scrap row carries a tag ('+(row[0]&&row[0].tag)+')');
       g.need={}; g.needN=0; g.pick=[]; pickSay('Circuit Board',{item:'board'});
       if(g.pick[0].tag) bad.push('THREE: a board nobody needs carries a tag');
       // FOUR: the backpack name line
       g.bag=['board','scrap','wire']; g.need={board:2}; g.needN=1; g.bagOpen=true;
       __drawBagWith(g); cells=g.bagCells||[];
       for(i=0;i<cells.length;i++) if(cells[i].key==='board') ix=cells[i].stackIx;
       if(ix===undefined) bad.push('FOUR: the board is not in the backpack grid');
       else {
         g.bagSel=ix;
         oFT=ctx.fillText; ctx.fillText=function(t){ rec.push(String(t)); return oFT.apply(this,arguments); };
         try{ __drawBagWith(g); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
         if(rec.indexOf('NEEDED \u00b7 CONTRACT')<0) bad.push('FOUR: the backpack name line does not say NEEDED . CONTRACT');
         rec.length=0; g.need={}; g.needN=0;
         oFT=ctx.fillText; ctx.fillText=function(t){ rec.push(String(t)); return oFT.apply(this,arguments); };
         try{ __drawBagWith(g); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
         if(rec.indexOf('NEEDED \u00b7 CONTRACT')>=0) bad.push('FOUR: the backpack says NEEDED with nothing needed');
       }
       g.bagOpen=false;
     }catch(x2){ bad.push('threw: '+(x2&&x2.message||x2)); }
     finally{
       try{ say=oSay; }catch(_s){}
       try{ if(oFT){ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; } }catch(_f){}
       try{ CAREER_ON=c0; }catch(_c0){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.bagOpen=false; __endRaid('abandon'); } }catch(_e){}
       try{ keys={}; }catch(_k){}
       try{ if(snap) __applyLoaded(snap); }catch(_r){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'28.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
