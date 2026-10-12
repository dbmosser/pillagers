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

# CREDITS AND POINTS ARE ONE THING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function arcadeN(n){ return String(Math.round(+n||0)).replace(/\B(?=(\d{3})+(?!\d))/g,','); }
'@ @'
function arcadeN(n){ return String(Math.round(+n||0)).replace(/\B(?=(\d{3})+(?!\d))/g,','); }
// v23.56, HIS ORDER (2026-10-11 evening), arcade31: CREDITS AND POINTS ARE ONE THING. His words: "in arcade mode, credits and points
// should be synonymous". The arcade score was a points number beside a world priced in credits, and a valuable scored a tenth of
// its price. Now a valuable scores its full credit value (ARCADE_LOOT_DIV 1), and every arcade score number reads as credits with
// a $ through this one helper, so the format cannot drift: the HUD score with YOU and P2, the kill popups, the pickup tags, the
// EXTRACTED banner, the teammate callout, the attract board, the team strip, the RUN OVER card and NEW HIGH SCORE. Kill points
// keep their values, read as credits. The profile credits are still never touched, and a normal raid never reaches any of it.
function arcadeCr(n){ return '$'+arcadeN(n); }
'@

SubRx @'
var ARCADE_SRCH=1, ARCADE_LOOT_DIV=10;   // v23.xx: his order, hold E to loot at the usual speed (was 6, walk-over loot)
'@ @'
var ARCADE_SRCH=1, ARCADE_LOOT_DIV=1;   // v23.xx: his order, hold E to loot at the usual speed (was 6, walk-over loot); v23.56 (arcade31): a valuable scores its full credit value (was 10)
'@

SubRx @'
    else if(G.arcade&&!G.sim&&itm&&!itm.use) _ptags[l]='+'+arcadeLoot(key).toLocaleString();   // v23.33 (arcade11): a valuable is points and pot, never the backpack
'@ @'
    else if(G.arcade&&!G.sim&&itm&&!itm.use) _ptags[l]='+'+arcadeCr(arcadeLoot(key));   // v23.33 (arcade11): a valuable is points and pot, never the backpack; v23.56 (arcade31): in credits
'@

SubRx @'
  return {tag:'SCRAPPED +'+n.toLocaleString(),line:''};
'@ @'
  return {tag:'SCRAPPED +'+arcadeCr(n),line:''};   // v23.56 (arcade31): in credits
'@

SubRx @'
  if(isFinite(x)&&isFinite(y)){ try{ label(x,y-20,'+'+arcadeN(n),'#ffc04a',0,true); }catch(_alb){} }
'@ @'
  if(isFinite(x)&&isFinite(y)){ try{ label(x,y-20,'+'+arcadeCr(n),'#ffc04a',0,true); }catch(_alb){} }   // v23.56 (arcade31): +$50
'@

SubRx @'
  if(m.ev==='x'&&(m.n|0)>0&&G&&G.arcade&&!G.over){ try{ say((ARCADE.role==='p2'?'PLAYER 1':'PLAYER 2')+' EXTRACTED +'+arcadeN(m.n|0),'ally'); }catch(_sx){} }
'@ @'
  if(m.ev==='x'&&(m.n|0)>0&&G&&G.arcade&&!G.over){ try{ say((ARCADE.role==='p2'?'PLAYER 1':'PLAYER 2')+' EXTRACTED +'+arcadeCr(m.n|0),'ally'); }catch(_sx){} }   // v23.56 (arcade31): in credits
'@

SubRx @'
  var cx=Math.round(W/2), mine=Math.max(0,ARCADE.mine|0), mate=Math.max(0,ARCADE.mate|0), nm=arcadeN(mine+mate);
'@ @'
  var cx=Math.round(W/2), mine=Math.max(0,ARCADE.mine|0), mate=Math.max(0,ARCADE.mate|0), nm=arcadeCr(mine+mate);   // v23.56 (arcade31): in credits
'@

SubRx @'
    hudText('YOU '+arcadeN(mine),gx,Math.round(y-h*0.40));
    hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeN(mate),gx,Math.round(y+h*0.15));
'@ @'
    hudText('YOU '+arcadeCr(mine),gx,Math.round(y-h*0.40));
    hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate),gx,Math.round(y+h*0.15));
'@

SubRx @'
  ctx.fillText('EXTRACTION BONUS +'+arcadeN(b.bonus),cx,y+LH(30));
  if(b.haul>0) ctx.fillText('HAUL x2 +'+arcadeN(b.haul),cx,y+LH(52));
'@ @'
  ctx.fillText('EXTRACTION BONUS +'+arcadeCr(b.bonus),cx,y+LH(30));   // v23.56 (arcade31): in credits
  if(b.haul>0) ctx.fillText('HAUL x2 +'+arcadeCr(b.haul),cx,y+LH(52));
'@

SubRx @'
  ctx.fillText((ARCADE.solo?'SCORE ':'TEAM SCORE ')+arcadeN(b.team),cx,y+LH(86));   // v23.54 (arcade30)
'@ @'
  ctx.fillText((ARCADE.solo?'SCORE ':'TEAM SCORE ')+arcadeCr(b.team),cx,y+LH(86));   // v23.54 (arcade30); v23.56 (arcade31): in credits
'@

SubRx @'
  for(i=0;i<rows.length&&i<10;i++){ r=rows[i]||{}; arcadeAttLine(pg,'apr'+((id&&r.run===id)?' hl':''),(i+1)+'.  '+String(r.i||'???').slice(0,3).toUpperCase(),arcadeN(r.s)); }
  if(o&&(+o.team||0)>0) arcadeAttLine(pg,'apb','LAST RUN '+arcadeN(o.team));
  if(best>0) arcadeAttLine(pg,'apb','BEST EVER '+arcadeN(best));
'@ @'
  for(i=0;i<rows.length&&i<10;i++){ r=rows[i]||{}; arcadeAttLine(pg,'apr'+((id&&r.run===id)?' hl':''),(i+1)+'.  '+String(r.i||'???').slice(0,3).toUpperCase(),arcadeCr(r.s)); }   // v23.56 (arcade31): in credits
  if(o&&(+o.team||0)>0) arcadeAttLine(pg,'apb','LAST RUN '+arcadeCr(o.team));
  if(best>0) arcadeAttLine(pg,'apb','BEST EVER '+arcadeCr(best));
'@

SubRx @'
  if(live) s+='  \u00b7  TEAM SCORE '+arcadeN(arcadeTeam());
'@ @'
  if(live) s+='  \u00b7  TEAM SCORE '+arcadeCr(arcadeTeam());   // v23.56 (arcade31): in credits
'@

SubRx @'
  var t=nm+'  '+arcadeN(r.s)+'  \u00b7  '+(r.k|0)+' KILLS  \u00b7  '+(r.x|0)+' EXT';
'@ @'
  var t=nm+'  '+arcadeCr(r.s)+'  \u00b7  '+(r.k|0)+' KILLS  \u00b7  '+(r.x|0)+' EXT';   // v23.56 (arcade31): in credits
'@

SubRx @'
    ln=oc?(ARCADE.solo?[['aoh','RUN OVER'],['aos','SCORE '+arcadeN(o.team)],['aor',arcadeOverRow('YOU',o.p1)]]   // v23.54 (arcade30): the 1 player arcade, one row
      :[['aoh','RUN OVER'],['aos','TEAM SCORE '+arcadeN(o.team)],['aor',arcadeOverRow('P1',o.p1)],['aor',arcadeOverRow('P2',o.p2)]]):[];
'@ @'
    ln=oc?(ARCADE.solo?[['aoh','RUN OVER'],['aos','SCORE '+arcadeCr(o.team)],['aor',arcadeOverRow('YOU',o.p1)]]   // v23.54 (arcade30): the 1 player arcade, one row; v23.56 (arcade31): in credits
      :[['aoh','RUN OVER'],['aos','TEAM SCORE '+arcadeCr(o.team)],['aor',arcadeOverRow('P1',o.p1)],['aor',arcadeOverRow('P2',o.p2)]]):[];
'@

SubRx @'
function arcadeHiSay(t){ try{ say('NEW HIGH SCORE','ext',{sub:(ARCADE.solo?'SCORE ':'TEAM SCORE ')+arcadeN(t)}); }catch(_hs){} }   // v23.54 (arcade30)
'@ @'
function arcadeHiSay(t){ try{ say('NEW HIGH SCORE','ext',{sub:(ARCADE.solo?'SCORE ':'TEAM SCORE ')+arcadeCr(t)}); }catch(_hs){} }   // v23.54 (arcade30); v23.56 (arcade31): in credits
'@

SubRx @'
var VER='23.55';
'@ @'
var VER='23.56';
'@

$pat = "(?m)^  now:'v23\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.56: In the arcade the score is credits: loot scores its full value and every score reads in dollars. Check 23.56 fails on v23.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
