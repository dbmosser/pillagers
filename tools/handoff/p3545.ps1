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

# THE EXTRACTED CARD SPLITS SCORE AND MONEY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    DEATH_FEED_HTML=recapHtml(T);   // v23.xx (feat3a): DAMAGE TAKEN, when anything hit you
'@ @'
    DEATH_FEED_HTML=recapHtml(T);   // v23.xx (feat3a): DAMAGE TAKEN, when anything hit you
    if(DEATH_FEED_HTML) DEATH_FEED_HTML='<div class="ocrecap">'+DEATH_FEED_HTML+'</div>';   // v35.45 (cw-spmoney): on the EXTRACTED card the damage block is a footnote under the result, lined up with it (CSS ocrecap)
'@

SubRx @'
  document.getElementById('oc_manifest').innerHTML=
    (DEATH_FEED_HTML||'')+lines.join('<br>');
'@ @'
  // v35.45 (cw-spmoney), HIS ORDER (2026-10-28) on the extracted card: "this extracted screen is an absolute mess". The result leads: on an extraction DAMAGE TAKEN
  // comes after the ledger and the lines, where it was the first thing under the title; a KIA card still opens on what killed you.
  document.getElementById('oc_manifest').innerHTML=(how==='extract')?
    (lines.join('<br>')+(DEATH_FEED_HTML||'')):((DEATH_FEED_HTML||'')+lines.join('<br>'));
'@

SubRx @'
    if(/>(CAREER SCORE |SCORE LOST|CAREER BEST|CAREER BOARD #)/.test(ln)) continue;
    rest.push(ln);
'@ @'
    if(/>(CAREER SCORE |SCORE LOST|CAREER BEST|CAREER BOARD #)/.test(ln)) continue;
    // v35.45 (cw-spmoney): the xp line here reads "+2,782 xp" (or "+65 xp . 50% penalty"), as ocStatRow made it on every other card. The season total and the
    // "next: ..., reward n of 100, ... claim it at the mainframe" sentence stay as hidden text (ocsr), so nothing that reads the card moves. In his picture of
    // 2026-10-28 that sentence was the line cut in half behind the leaderboard button.
    if((m=/^(<span style="color:var\(--amber\)">\+[\d,]+ XP)(?: (\((\d+)% penalty [^)]*\)))?(  &middot;  [\d,]+(?: of [\d,]+| XP in all))(<\/span>)(.*)$/.exec(ln))){ rest.push(m[1]+(m[3]?'  &middot;  '+m[3]+'% penalty':'')+'<span class="ocsr">'+(m[2]?' '+m[2]:'')+m[4]+'</span>'+m[5]+(m[6]?'<span class="ocsr">'+m[6]+'</span>':'')); continue; }
    rest.push(ln);
'@

SubRx @'
  if(s-sum!==0) parts.push(['OTHER','BONUSES',s-sum]);
  for(i=0;i<parts.length;i++){
    p=parts[i]; v=p[2]; if(!v) continue;
    tg=(p[0]!==prev)?p[0]:''; prev=p[0];
    h+=row('','<span class="lgt">'+tg+'</span><span class="lgl">'+p[1]+'</span>'+((v<0)?('<b>-'+arcadeCr(-v)+'</b>'):cnt(v,'')));
  }
  if(ex) h+=row('','<span class="lgt">EXTRACTION</span><span class="lgl">x2</span>'+cnt(s,'+'));
  else if(s>0) h+=row('lost','<span class="lgt">KIA</span><span class="lgl">-50%</span><b>-'+arcadeCr(s-fin)+'</b>');   // v28.67 (lean1): HIS RULE, KIA is a 50% score penalty
  h+=row('sc','<span class="lgl">RAID SCORE'+((R&&R.best)?' <em class="lgpb">PERSONAL BEST</em>':'')+'</span>'+((fin>0)?cnt(fin,''):('<b>'+arcadeCr(0)+'</b>')));
  if(ex) h+=row('cr','<span class="lgt">CREDITS</span><span class="lgl">BANKED</span>'+((fin>0)?cnt(fin,'+',1):'<b>+'+arcadeMoney(0)+'</b>'));
  else h+=row('lost','<span class="lgt">CREDITS</span><span class="lgl">NOT BANKED</span><b><s>+'+arcadeMoney(fin)+'</s> LOST</b>');
  if(ex){
    h+=row('','<span class="lgt">HAUL</span><span class="lgl">ITEMS SECURED</span><b>'+ni+'</b>');
    if(strip){ h+='<div class="lgstrip" style="--i:'+idx+'">'+strip+'</div>'; idx++; }
    h+=row('hv','<span class="lgt"></span><span class="lgl">HAUL VALUE</span><b id="haultot" data-pre="">'+arcadeMoney(hv)+'</b>');
    tot=fin+hv;
  } else {
    h+=row('lost','<span class="lgt">HAUL</span><span class="lgl">VALUE</span><b><s>'+arcadeMoney(lostV||x.haul||0)+'</s> LOST</b>');
    tot=0;
  }
  h+=row('tot'+(ex?'':' lost'),'<span class="lgl">RAID TOTAL</span>'+((tot>0)?cnt(tot,'',1):('<b>'+arcadeMoney(0)+'</b>')));
'@ @'
  if(s-sum!==0) parts.push(['OTHER','BONUSES',s-sum]);
  // v35.45 (cw-spmoney), HIS ORDER (2026-10-28), on a picture of this card: "this extracted screen is an absolute mess -- money versus raid score/sp should never be
  // intermingled". It was one list: sp rows, then the credits in $, then the haul, then a RAID TOTAL in $ drawn in the score's own gold. Now two panels side by side.
  // RAID SCORE (gold, sp only): where each point came from, the x2 or the KIA half, and its total. MONEY (teal, $ only): items secured, haul value, the credits
  // banked, and its total. No row carries both units and no total sits in the other panel. The figures, the classes the tally and the checks read (sc, cr, hv,
  // tot, lost, haultot) and his rules (1 sp banks $1 on an extraction, KIA halves the score and banks nothing) are unchanged. The haul pictures sit under both.
  var sh='', mh='';
  for(i=0;i<parts.length;i++){
    p=parts[i]; v=p[2]; if(!v) continue;
    sh+=row('','<span class="lgl">'+p[1]+'</span>'+((v<0)?('<b>-'+arcadeCr(-v)+'</b>'):cnt(v,'')));
  }
  if(ex) sh+=row('','<span class="lgl">EXTRACTION x2</span>'+cnt(s,'+'));
  else if(s>0) sh+=row('lost','<span class="lgl">KIA -50%</span><b>-'+arcadeCr(s-fin)+'</b>');   // v28.67 (lean1): HIS RULE, KIA is a 50% score penalty
  sh+=row('sc','<span class="lgl">TOTAL</span>'+((fin>0)?cnt(fin,''):('<b>'+arcadeCr(0)+'</b>')));
  if(ex){
    mh+=row('ni','<span class="lgl">ITEMS SECURED</span><b>'+ni+'</b>');
    mh+=row('hv','<span class="lgl">HAUL VALUE</span><b id="haultot" data-pre="">'+arcadeMoney(hv)+'</b>');
    mh+=row('cr','<span class="lgl">CREDITS BANKED</span>'+((fin>0)?cnt(fin,'+',1):'<b>+'+arcadeMoney(0)+'</b>'));
    tot=fin+hv;
  } else {
    mh+=row('lost','<span class="lgl">HAUL VALUE</span><b><s>'+arcadeMoney(lostV||x.haul||0)+'</s> LOST</b>');
    mh+=row('lost','<span class="lgl">CREDITS NOT BANKED</span><b><s>+'+arcadeMoney(fin)+'</s> LOST</b>');
    tot=0;
  }
  mh+=row('tot'+(ex?'':' lost'),'<span class="lgl">TOTAL</span>'+((tot>0)?cnt(tot,'',1):('<b>'+arcadeMoney(0)+'</b>')));
  h+='<div class="lgcols"><div class="lgp lgps"><div class="lgh">RAID SCORE'+((R&&R.best)?' <em class="lgpb">PERSONAL BEST</em>':'')+'</div>'+sh+'</div>'+
     '<div class="lgp lgpm"><div class="lgh">MONEY</div>'+mh+'</div></div>';
  if(ex&&strip){ h+='<div class="lgstrip" style="--i:'+idx+'">'+strip+'</div>'; idx++; }
'@

SubRx @'
  '.lg.lgdone .lgr,.lg.lgdone .lgstrip,.lg.lgdone .lgst,.lg.lgdone .lgem{animation:none;opacity:1}');
'@ @'
  '.lg.lgdone .lgr,.lg.lgdone .lgstrip,.lg.lgdone .lgst,.lg.lgdone .lgem{animation:none;opacity:1}'+
  // v35.45 (cw-spmoney): the two panels. Each has one colour for its figures and its top bar (score gold #ffc04a, money teal #7fe3d4, the colours the
  // RAID SCORE and CREDITS rows already had), rows at 16px with no tag column, and its total pinned to its foot so the two totals line up. The ledger takes the
  // card's full 624px, so six medal emblems fit on one line.
  '.lg{width:100%;max-width:624px}'+
  '.lg .lgcols{display:grid;grid-template-columns:1fr 1fr;gap:16px;align-items:stretch}'+
  '.lg .lgp{display:flex;flex-direction:column;min-width:0;padding:12px 16px 14px;border:1px solid var(--ui-line,#2e3337);border-top:3px solid var(--lgc);border-radius:4px;background:rgba(0,0,0,.22)}'+
  '.lg .lgps{--lgc:#ffc04a}.lg .lgpm{--lgc:#7fe3d4}'+
  '.lg .lgh{display:flex;align-items:center;gap:8px;min-height:24px;margin:0 0 4px;font-size:16px;letter-spacing:.14em;color:var(--lgc)}'+
  '.lg .lgh .lgpb{margin-left:auto;font-size:12px}'+
  '.lg .lgp .lgr{grid-template-columns:1fr auto;gap:0 12px;padding:4px 0;font-size:16px;border-bottom:0}'+
  '.lg .lgp .lgr .lgl{grid-column:auto;min-width:0}'+
  '.lg .lgp .lgr b{color:var(--lgc)}.lg .lgp .lgr.ni b{color:var(--tx-1,#efe9dc)}.lg .lgp .lgr.lost b,.lg .lgp .lgr.lost .lgl{color:var(--rust)}'+
  '.lg .lgp .lgr.sc,.lg .lgp .lgr.tot{margin-top:auto;padding:10px 0 0;border:0;border-top:1px solid var(--lgc);border-radius:0;background:none;font-size:28px;letter-spacing:.06em;color:var(--lgc)}'+
  '.lg .lgp .lgr.sc .lgl,.lg .lgp .lgr.tot .lgl{align-self:center;font-size:16px;letter-spacing:.14em;color:var(--tx-2,#aaa498)}'+
  '.lg .lgp .lgr.tot.lost{border-top-color:var(--rust)}'+
  '#root #oc_manifest .ocrecap{width:100%;max-width:624px;margin:8px auto 0;text-align:left}'+
  '#root #oc_manifest .ocrecap>div>div{font-size:16px !important;letter-spacing:.04em}'+
  '#root #oc_manifest .ocrecap>div>div:first-child{letter-spacing:.14em;color:var(--tx-2,#aaa498) !important}');
'@

SubRx @'
  return ['<div class="lg">'+h+'</div>'].concat(rest);
'@ @'
  // v35.45 (cw-spmoney): the lines under the ledger go through ocStatRow like every other card, so each recovered gun is one name chip and a finished
  // contract one chip, not a sentence a line (eight recovered guns were eight sentences and ran the card past 1080p). Their words stay as hidden text (ocsr).
  try{ rest=ocStatRow(rest,{}); }catch(_osr){}
  return ['<div class="lg">'+h+'</div>'].concat(rest);
'@

SubRx @'
var VER='35.44';
'@ @'
var VER='35.45';
'@

$pat = "(?m)^  now:'v35\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.45: the extracted card keeps score and money apart: score on the left in sp, money on the right in dollars Check 35.45 fails on v35.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
