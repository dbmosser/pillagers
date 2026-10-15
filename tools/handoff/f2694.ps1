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

if ($s.Contains("  {v:'26.94',what:")) { throw "check 26.94 is in the fixture already" }

SubRx @'
  {v:'26.93',what:
'@ @'
  {v:'26.94',what:'flow13, his yes to the golden-enemy clue hunt: three clue props (a scanner, gold dust, a beacon) are laid on the seed, a search circle that always holds the golden enemy shows on the maps and shrinks to 900, 520 and 220 as each clue is walked over, the props chirp on the HUD and show on the minimap only near, and when the golden enemy dies the hunt is gone',
   run:function(){
     if(!(window.__state&&window.__endRaid&&window.__runPrep&&window.__frame)) return 'SKIP: no raid or frame here';
     if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade here';
     var bad=[], g=null, p, rs=say, own=false, lines=[], S, C, e, i, j, k, M, mk, t1, t2, cap=[], proto, oArc, s, hit, R3=[900,520,220], c, d, saw, kinds={}, ng, want;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       if(typeof clueLayout!=='function'||typeof flowTick!=='function'||typeof goldTick!=='function') return 'there is no clue hunt in this build';
       p=g.player; keys={};
       say=function(m,kd,o){ lines.push(String(m)+'|'+((o&&o.sub)||'')); }; own=true;
       ARCADE.mine=0; ARCADE.holdT=0; g.t=5; flowTick(0.1); flowTick(0.1); S=g.flow.gold; C=g.flow.clue;
       if(!S||!S.ref) return 'SKIP: staging: no golden enemy in this raid';
       if(!C||!C.props||C.props.length!==3) return 'ONE: the raid laid '+(C&&C.props?C.props.length:'no')+' clue props';
       // ONE: one of each kind, off the drop, apart from each other and from the rings
       for(i=0;i<3;i++){ kinds[C.props[i].kind]=1; if(Math.hypot(C.props[i].x-p.x,C.props[i].y-p.y)<449) bad.push('ONE: a clue is '+Math.round(Math.hypot(C.props[i].x-p.x,C.props[i].y-p.y))+' from the drop');
         for(j=0;j<g.zones.length;j++) if(Math.hypot(C.props[i].x-g.zones[j].x,C.props[i].y-g.zones[j].y)<299) bad.push('ONE: a clue is within 300 of ring '+j);
         for(j=i+1;j<3;j++) if(Math.hypot(C.props[i].x-C.props[j].x,C.props[i].y-C.props[j].y)<649) bad.push('ONE: two clues are close together'); }
       if(!(kinds.scanner&&kinds.dust&&kinds.beacon)) bad.push('ONE: the kinds are '+Object.keys(kinds).join(','));
       t1=clueLayout(); t2=clueLayout();
       if(JSON.stringify(t1)!==JSON.stringify(t2)||JSON.stringify(t1)!==JSON.stringify(C.props.map(function(q){ return {kind:q.kind,x:q.x,y:q.y,got:0}; }))) bad.push('ONE: the same seed laid the clues somewhere else');
       // TWO: the search circle: 1400, with the golden enemy inside, and on the maps
       e=S.ref; c=clueCircle(C);
       if(c.r!==1400||Math.hypot(c.x-e.x,c.y-e.y)>0.51*c.r) bad.push('TWO: the circle is '+c.r+' wide and '+Math.round(Math.hypot(c.x-e.x,c.y-e.y))+' from the golden enemy');
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='gold'&&M[i].r===1400&&!M[i].pin) mk++;
       if(mk!==1) bad.push('TWO: '+mk+' search circle marks of 1400');
       saw=0; for(i=0;i<lines.length;i++) if(lines[i].indexOf('SEARCH '+'CIRCLE')>=0) saw=1;
       if(!saw) bad.push('TWO: no callout for the search circle');
       // THREE: a prop far away is not taken; walking over each one shrinks the circle
       p.x=C.props[0].x+200; p.y=C.props[0].y; flowTick(0.1);
       if(C.n!==0) bad.push('THREE: a clue 200 away was taken');
       for(k=0;k<3;k++){
         lines.length=0; p.x=C.props[k].x+10; p.y=C.props[k].y; flowTick(0.1);
         c=clueCircle(C);
         if(C.n!==k+1) bad.push('THREE: after clue '+(k+1)+' the count is '+C.n);
         if(c.r!==R3[k]) bad.push('THREE: after clue '+(k+1)+' the circle is '+c.r+', not '+R3[k]);
         if(Math.hypot(c.x-e.x,c.y-e.y)>0.51*c.r) bad.push('THREE: after clue '+(k+1)+' the golden enemy is outside the circle');
         saw=0; for(i=0;i<lines.length;i++) if(lines[i].indexOf('CLUE '+(k+1)+'/3')===0) saw=1;
         if(!saw) bad.push('THREE: no CLUE '+(k+1)+'/3 callout');
       }
       flowTick(0.1); flowTick(0.1);
       if(C.n!==3) bad.push('THREE: a taken clue was taken again ('+C.n+')');
       // FOUR: with all three the mark is an arrow on the minimap edge; the circle follows the golden enemy
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='gold'&&M[i].r===220&&M[i].pin) mk++;
       if(mk!==1) bad.push('FOUR: the last circle is not a pinned mark of 220');
       e.x+=300; e.y-=120; c=clueCircle(C);
       if(Math.hypot(c.x-e.x,c.y-e.y)>0.51*220) bad.push('FOUR: the circle did not follow the golden enemy');
       // FIVE: the props chirp on the HUD where they stand, and show on the minimap only near
       ng=C.props.map(function(q){ return {kind:q.kind,x:q.x,y:q.y,got:0}; });
       C.props[1].got=0; p.x=C.props[1].x+80; p.y=C.props[1].y;
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='clue'&&Math.abs(M[i].x-C.props[1].x)<1) mk++;
       if(mk!==1) bad.push('FIVE: a clue 80 away is '+mk+' marks');
       p.x=C.props[1].x+900; M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='clue') mk++;
       if(mk) bad.push('FIVE: a clue 900 away is a mark');
       p.x=C.props[1].x+80; render2D(0); cap.length=0; proto=CanvasRenderingContext2D.prototype; oArc=proto.arc;
       proto.arc=function(){ cap.push([].slice.call(arguments)); return oArc.apply(this,arguments); };
       try{ flowDraw(ctx,p); } finally { proto.arc=oArc; }
       s=w2s(C.props[1].x,0,C.props[1].y); hit=0; for(i=0;i<cap.length;i++) if(cap[i].length>=5&&Math.abs(cap[i][0]-s.x)<2&&Math.abs(cap[i][1]-s.y)<2) hit++;
       if(!hit) bad.push('FIVE: no chirp ring was drawn on the clue ('+cap.length+' arcs)');
       // SIX: the golden enemy dies: the hunt is gone
       e.hp=0; flowTick(0.1); flowTick(0.1);
       M=flowMarks(); mk=0; for(i=0;i<M.length;i++) if(M[i].kind==='gold'||M[i].kind==='clue') mk++;
       if(mk) bad.push('SIX: '+mk+' hunt marks remain after the golden enemy died');
       if(!C.done) bad.push('SIX: the hunt is not over');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       keys={};
       try{ if(proto&&oArc) proto.arc=oArc; }catch(_p){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.mine=0; ARCADE.waveT=0; ARCADE.holdT=0; } }catch(_h){}
       __topClear();
     }
     return bad.length?bad.slice(0,8).join('; '):null; }},
  {v:'26.93',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
