$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# pillager survival level fills from SP beside health and stays with the living pillager (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
[],lvl:1,lsp:0,picks:[],raids:0,ext:0,kills:0,best:0,born:Date.now()
'@ @'
[],lvl:0,lsp:0,picks:[],raids:0,ext:0,kills:0,best:0,born:Date.now()
'@

SubRx @'
  var k, n=['lvl','lsp','raids','ext','kills','best','born'];
'@ @'
  // v28.xx (cw-cx-survivallevel): missing survival SP means a new level zero pillager.
  var k, missingSP=typeof q.lsp!=='number'||!isFinite(q.lsp)||q.lsp<0, n=['lvl','lsp','raids','ext','kills','best','born'];
'@

SubRx @'
  q.lvl=Math.max(1,Math.min(20,Math.round(q.lvl)));
'@ @'
  // v28.xx (cw-cx-survivallevel): keep recorded hall levels; normalize pre-m4 living records once in pilSurvivalMig.
  q.lvl=missingSP?0:Math.max(0,Math.min(20,Math.round(q.lvl)));
'@

SubRx @'
mig1x:1,mig2n:1,mkt:{s:{}},outfits:[],
'@ @'
mig1x:1,mig2n:1,mig4a:1,mkt:{s:{}},outfits:[],
'@

SubRx @'
  r.gen=g; r.born=Date.now();
'@ @'
  // v28.xx (cw-cx-survivallevel): cached heirs from an older save also begin their own life at level zero.
  r.gen=g; r.born=Date.now(); r.lsp=0; r.lvl=0;
'@

SubRx @'
function pilNow(){ return acctEnsure(P); }
'@ @'
// v28.xx (cw-cx-survivallevel), his 11-01 answers 16, 17, 19, 20 and 29: "tie level to sp", "keep filling the next bar too", cap 20, next to health.
// v28.xx (cw-cx-survivallevel): total SP at levels 0..20. The 15 real extractions in the Nov 7 recorder set the pace; see the ship notes for the estimates.
var PIL_SURVIVAL_SP=[0,865,2060,3585,5440,7625,10140,12985,16160,19665,23500,27665,32160,36985,42140,47625,53440,59585,66060,72865,80000];
function pilSurvivalLevel(sp){
  var i=0; sp=(typeof sp==='number'&&isFinite(sp))?Math.max(0,sp):0;
  while(i<20&&sp>=PIL_SURVIVAL_SP[i+1]) i++;
  return i;
}
function pilSurvivalMig(p){
  var q;
  if(!p||p.mig4a===1) return;
  q=acctEnsure(p);
  if(q){ q.lsp=Math.min(PIL_SURVIVAL_SP[20],Math.max(0,Math.floor(q.lsp)||0)); q.lvl=pilSurvivalLevel(q.lsp); }
  p.mig4a=1;
}
function pilSurvivalOwn(){
  return !!(G&&G.career&&!G.sim&&!G.arcade&&P&&P.pil&&!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)&&!(typeof NETP2!=='undefined'&&NETP2));
}
function pilSurvivalOn(){ return pilSurvivalOwn()&&!G.over; }
function pilSurvivalLift(){ return pilSurvivalOn()?42:0; }
function pilSurvivalState(q){
  var sp=(q&&typeof q.lsp==='number'&&isFinite(q.lsp))?Math.max(0,Math.min(PIL_SURVIVAL_SP[20],q.lsp)):0, lv=pilSurvivalLevel(sp);
  return {sp:sp,lvl:lv,f:lv===20?1:(sp-PIL_SURVIVAL_SP[lv])/(PIL_SURVIVAL_SP[lv+1]-PIL_SURVIVAL_SP[lv])};
}
function pilSurvivalAdd(n,settling){
  var q, s, add, before;
  if(!pilSurvivalOwn()||(G.over&&!(settling===true&&G.over==='extract'))||typeof n!=='number'||!isFinite(n)||n<=0) return 0;
  q=P.pil; s=pilSurvivalState(q); before=s.lvl;
  add=Math.min(Math.floor(n),PIL_SURVIVAL_SP[20]-s.sp);
  if(add<=0) return 0;
  q.lsp=s.sp+add; q.lvl=pilSurvivalLevel(q.lsp);
  // v28.xx (cw-cx-survivallevel): one short callout for the final crossed level; no picks, music, stat boost or raid interruption.
  if(q.lvl>before&&!G.over) say('level '+q.lvl,'info',{key:'pil-level'});
  saveProfile();
  return add;
}
function pilSurvivalDraw(x,y,w){
  var s, f;
  if(!pilSurvivalOn()) return false;
  s=pilSurvivalState(P.pil);
  ctx.save();
  hudPanel(x-6,y-3,w+12,35,0.9,1);
  f=FS(TYPE.label); if(msgPx(f)>16) f=f.replace(/[\d.]+px/,'16px');
  ctx.font=f; ctx.textBaseline='alphabetic'; ctx.textAlign='left'; ctx.fillStyle='#efe9dc';
  hudText('pillager survival level',x+6,y+12);
  ctx.textAlign='right'; ctx.fillStyle='#e6ff3d'; hudText(String(s.lvl),x+w-6,y+12);
  bar(x+6,y+22,w-12,6,s.f,'#e6ff3d','#2e3337');
  ctx.restore();
  return true;
}
function netPilLevelPut(msg){ if(pilSurvivalOn()) msg.pl=pilSurvivalLevel(P.pil.lsp); }
function pilSurvivalTag(g,name){
  return (G&&G.career&&!G.arcade&&!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)&&g&&typeof g.pl==='number'&&isFinite(g.pl))?String(name).toLowerCase()+'  level '+Math.max(0,Math.min(20,Math.floor(g.pl))):name;
}
function pilNow(){ return acctEnsure(P); }
'@

SubRx @'
          try{ seasonZeroMig(P); }catch(_szm){}
'@ @'
          try{ seasonZeroMig(P); }catch(_szm){}
          // v28.xx (cw-cx-survivallevel): a pre-m4 save starts from the SP on its living pillager, never account XP or historical raids.
          try{ pilSurvivalMig(P); }catch(_psm){}
'@

SubRx @'
  b=c.b||(c.b={}); b[cat]=(b[cat]|0)+(n|0);
  return n;
'@ @'
  b=c.b||(c.b={}); b[cat]=(b[cat]|0)+(n|0);
  // v28.xx (cw-cx-survivallevel): every actual career SP award reaches this tally, including shared machine score, styles, vaults and bounties.
  pilSurvivalAdd(n);
  return n;
'@

SubRx @'
  if(how==='extract'){
    fin=Math.round(s*2*cm);
  }
'@ @'
  if(how==='extract'){
    fin=Math.round(s*2*cm);
    // v28.xx (cw-cx-survivallevel): live SP was counted already; only the extraction and condition SP difference is new. careerPaid makes this once.
    pilSurvivalAdd(Math.max(0,fin-s),true);
  }
'@

SubRx @'
var by=H-34;
'@ @'
// v28.xx (cw-cx-survivallevel): the bar belongs to the health stack and shares its move, scale and fade controls.
var by=H-34-pilSurvivalLift();
'@

SubRx @'
hudZoomRect('body',0,H,{x:10,y:H-142,w:380,h:138})
'@ @'
hudZoomRect('body',0,H,{x:10,y:H-142-pilSurvivalLift(),w:380,h:138+pilSurvivalLift()})
'@

SubRx @'
{x:16+_bsx,y:by-50,w:HBW,h:50+HBH}
'@ @'
{x:16+_bsx,y:by-50,w:HBW,h:50+HBH+pilSurvivalLift()}
'@

SubRx @'
  drawLowHpRing(16,by,HBW,HBH,p.hp,p.maxhp);   // v28.xx (cw-lowhp)
'@ @'
  drawLowHpRing(16,by,HBW,HBH,p.hp,p.maxhp);   // v28.xx (cw-lowhp)
  // v28.xx (cw-cx-survivallevel): directly below health, inside its existing HUD transform; never drawn in the demo.
  pilSurvivalDraw(16,by+HBH+10,HBW);
'@

SubRx @'
_topB=H-(34+50+LH(5)+LH(18))
'@ @'
_topB=H-(34+pilSurvivalLift()+50+LH(5)+LH(18))
'@

SubRx @'
Math.round(H-LH(142)*rs*1.4)
'@ @'
Math.round(H-LH(142+pilSurvivalLift())*rs*1.4)
'@

SubRx @'
  netPnPut(msg,NET.upN);   // v37.xx (cw-m2retire)
'@ @'
  netPnPut(msg,NET.upN);   // v37.xx (cw-m2retire)
  // v28.xx (cw-cx-survivallevel): display level travels separately so the name, team feed and lobby stay names only.
  netPilLevelPut(msg);
'@

SubRx @'
  if(up) g.shold=(m.shold===1)?1:0;   // v28.xx (cw-cx-bothsearch): search input, not a granted box or the busy-hands pose
'@ @'
  if(up) g.shold=(m.shold===1)?1:0;   // v28.xx (cw-cx-bothsearch): search input, not a granted box or the busy-hands pose
  // v28.xx (cw-cx-survivallevel): finite numeric level only; missing or invalid fields clear any previous level and use the name-only fallback.
  if(up){ if(typeof m.pl==='number'&&isFinite(m.pl)) g.pl=Math.max(0,Math.min(20,Math.floor(m.pl))); else delete g.pl; }
'@

SubRx @'
    if(up) out.shold=g.shold;   // v28.xx (cw-cx-bothsearch): forward both press and release
'@ @'
    if(up) out.shold=g.shold;   // v28.xx (cw-cx-bothsearch): forward both press and release
    // v28.xx (cw-cx-survivallevel): relay the cleaned level; neither host nor peer can award the other save SP.
    if(up&&typeof g.pl==='number') out.pl=g.pl;
'@

SubRx @'
      g=NET.up[i]; if(!netUpShown(g)||netUpHid(g)) continue;   // v35.xx (cw-xsink): no name plate over a teammate an extraction took
      nm=netSeatName(g.seat)||'PILLAGER';
      tw=wc.measureText(nm).width;
'@ @'
      g=NET.up[i]; if(!netUpShown(g)||netUpHid(g)) continue;   // v35.xx (cw-xsink): no name plate over a teammate an extraction took
      // v28.xx (cw-cx-survivallevel): raid heads show the pillager name and survival level, never the account rank.
      nm=pilSurvivalTag(g,netSeatName(g.seat)||'PILLAGER');
      tw=wc.measureText(nm).width;
'@

SubRx @'
var VER='37.67';
'@ @'
var VER='37.68';
'@

$pat = "(?m)^  now:'v37\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.68: Career raids: pillager survival level beside health, short level n callout, cap 20. SP and levels persist on the living pillager. No picks in this build. Check 37.68 fails on v37.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
