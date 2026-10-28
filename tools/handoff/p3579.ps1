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

# CONDITIONS PAY SP ONLY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
nightXp:1.2,wxXp:1.1
'@ @'
nightXp:1.05,wxXp:1.05
'@

SubRx @'
function wxXpMul(){ return (CFG.wxXp===undefined)?1.1:CFG.wxXp; }
'@ @'
function wxXpMul(){ return 1.05; }   // v28.xx (cw-cx-condition-sp): badge only; weather no longer multiplies XP
'@

SubRx @'
// v10.06, his answer 22: a night run pays more. Dial nightXp, 1.2 by default.
function nightXpMul(){ return (CFG.nightXp===undefined)?1.2:CFG.nightXp; }
'@ @'
// v28.xx (cw-cx-condition-sp), his 10-28 decision: "All these modifiers like night rain etc stuff should contribute to sp not $ at 1.05".
// v28.xx (cw-cx-condition-sp): XP is the separate Mainframe reward track; neither it nor cash receives these multipliers.
function nightXpMul(){ return 1.05; }   // v28.xx (cw-cx-condition-sp): badge only; the old nightXp dial no longer changes XP
function raidConditionRows(){
  var out=[], ts=termsOf(), i, w=wx(), hard=0;
  if(!isDay()) out.push(['night',1.05]);
  if(w){
    hard=(w.view!==undefined&&w.view<1)?1:0;
    if(!hard&&w.lights!==undefined&&w.lights<1&&ts.indexOf('blackout')<0){
      var base=lampBase(); hard=((base-base*w.lights)>=0.15)?1:0;
    }
    if(hard) out.push([String(w.name||w.id).toLowerCase(),1.05]);
  }
  for(i=0;i<TERMS.length;i++) if(ts.indexOf(TERMS[i].id)>=0) out.push([TERMS[i].name.toLowerCase(),1.05]);
  return out;
}
function raidConditionMul(){
  if(!DMUL_ON) return 1;
  var rows=raidConditionRows(), m=1;
  for(var i=0;i<rows.length;i++) m*=rows[i][1];
  return m;
}
'@

SubRx @'
  var tmul=1+(rec.termPay||0);
'@ @'
  var tmul=1;   // v28.xx (cw-cx-condition-sp): signed conditions multiply raid SP, never Mainframe XP
'@

SubRx @'
  return Math.round((spForRun(rec)+xpForRun(rec))*(rec.night?nightXpMul():1)*(rec.wxHard?wxXpMul():1));
'@ @'
  return spForRun(rec)+xpForRun(rec);   // v28.xx (cw-cx-condition-sp): condition bonuses belong only to SP
'@

SubRx @'
  // v10.06: and a night run pays its multiplier on top.
  // v11.00, his note 16: hard weather pays too, and both apply, so a hard night
  // is 1.2 times 1.1.
'@ @'
  // v28.xx (cw-cx-condition-sp): night, weather and signed Terms now multiply SP only.
'@

SubRx @'
  <div class="msub">Sign for worse conditions. Walk out to get paid more.</div>
'@ @'
  <div class="msub">worse odds. +5% sp each.</div>
'@

SubRx @'
  ['DONE','THE TERMS: sign for worse odds and Meridian pays better'],
'@ @'
  ['DONE','the terms: +5% sp per condition'],
'@

SubRx @'
  {id:'blackout',name:'BLACKOUT PROTOCOL',pay:0.25,
'@ @'
  {id:'blackout',name:'BLACKOUT PROTOCOL',pay:0.05,
'@

SubRx @'
  {id:'window',  name:'SHORT WINDOW',pay:0.25,
'@ @'
  {id:'window',  name:'SHORT WINDOW',pay:0.05,
'@

SubRx @'
  {id:'patrols', name:'HEAVY PATROLS',pay:0.30,
'@ @'
  {id:'patrols', name:'HEAVY PATROLS',pay:0.05,
'@

SubRx @'
  {id:'known',   name:'THEY KNOW YOU',pay:0.30,
'@ @'
  {id:'known',   name:'THEY KNOW YOU',pay:0.05,
'@

SubRx @'
  {id:'silence', name:'SILENT RUNNING',pay:0.30,
'@ @'
  {id:'silence', name:'SILENT RUNNING',pay:0.05,
'@

SubRx @'
      var _mdIn=P.credits+((how==='extract')?((G.pedCarry||0)+Math.round(Math.max(0,haul-(G.carriedIn||0))*termsPay(1))):0);
'@ @'
      var _mdIn=P.credits+((how==='extract')?(G.pedCarry||0):0);   // v28.xx (cw-cx-condition-sp): no hazard cash is coming
'@

SubRx @'
  // HAZARD PAY. Only on an extraction: signing for worse conditions and then
  // dying under them is simply a worse day, which is what makes it a bet rather
  // than a difficulty slider.

  if(how==='extract'&&tPay>0){
    // v13.53, end-of-raid audit: only what the run brought home earns hazard pay. The
    // lift's own cargo goes straight back to the stash, as v12.65 and v12.69 already count.
    var bonus=Math.round(Math.max(0,haul-(G.carriedIn||0))*tPay);
    P.credits+=bonus;
    var tn=[];
    for(var tq=0;tq<TERMS.length;tq++) if(termsOf().indexOf(TERMS[tq].id)>=0) tn.push(TERMS[tq].name);
    lines.push('<span style="color:var(--amber)">Hazard pay +'+Math.round(tPay*100)+
      '%: '+'$'+bonus.toLocaleString()+' for '+tn.join(', ')+'.</span>');
  } else if(how==='dead'&&tPay>0){
    lines.push('<span style="color:var(--rust)">You signed for '+Math.round(tPay*100)+
      '% and did not come back for it.</span>');
  }
  try{ careerSettle
'@ @'
  // v28.xx (cw-cx-condition-sp): signed conditions pay 1.05x SP each, with no hazard cash.
  try{ careerSettle
'@

SubRx @'
    vl.textContent='+'+Math.round(T.pay*100)+'%';
'@ @'
    vl.textContent='+5% sp';   // v28.xx (cw-cx-condition-sp): every signed condition is 1.05x SP
'@

SubRx @'
    ? '<span style="color:#ffc04a">Hazard pay +'+Math.round(tp*100)+'% on anything you carry out.</span>'
    : '<span style="color:var(--ash)">Nothing signed. Standard terms, standard pay.</span>';
'@ @'
    ? '<span style="color:#ffc04a">sp x'+Math.pow(1.05,termsOn().length).toFixed(2)+'</span>'
    : '<span style="color:var(--ash)">no terms signed</span>';
'@

SubRx @'
      rows.push({k:TERMS[_tq].name,v:'+'+Math.round(TERMS[_tq].pay*100)+'% pay',c:'#ffc04a'});
'@ @'
      rows.push({k:TERMS[_tq].name,v:'+5% sp',c:'#ffc04a'});   // v28.xx (cw-cx-condition-sp): score only
'@

SubRx @'
  if(nx) nx.textContent='+'+Math.round((nightXpMul()-1)*100)+'%';
'@ @'
  if(nx) nx.textContent='+5% sp';   // v28.xx (cw-cx-condition-sp): explicit unit
'@

SubRx @'
return isDay()?'':('+'+Math.round((wxXpMul()-1)*100)+'%');
'@ @'
return isDay()?'':'+5% sp';
'@

SubRx @'
  return hard?('+'+Math.round((wxXpMul()-1)*100)+'%'):'';
'@ @'
  return hard?'+5% sp':'';   // v28.xx (cw-cx-condition-sp): weather is score only
'@

SubRx @'
  var s=Math.max(0,G.cs.s|0), fin=0, best=false, rk=0, R=null;
'@ @'
  // v28.xx (cw-cx-condition-sp): conditions multiply the final SP once; cash uses the score before conditions.
  var s=Math.max(0,G.cs.s|0), fin=0, best=false, rk=0, R=null, cm=raidConditionMul();
  G.careerConditionMul=cm;
  G.careerCash=(how==='extract')?s*2:0;
'@

SubRx @'
    fin=s*2;
    P.credits=(+P.credits||0)+fin;
'@ @'
    fin=Math.round(s*2*cm);
    P.credits=(+P.credits||0)+G.careerCash;
'@

SubRx @'
R=careerBoardAdd(how,(how==='extract')?fin:Math.floor(s/2));
'@ @'
R=careerBoardAdd(how,(how==='extract')?fin:Math.round(Math.floor(s/2)*cm));
'@

SubRx @'
      lines.push('<span style="color:#ffc04a;font-weight:700">CAREER SCORE '+arcadeCr(s)+' x2  \u00b7  +'+arcadeN(fin)+' CR</span>');
'@ @'
      lines.push('<span style="color:#ffc04a;font-weight:700">CAREER SCORE '+arcadeCr(fin)+'</span>');
'@

SubRx @'
fin=ex?s*2:Math.floor(s/2), b=c.b||{}
'@ @'
fin=Math.round((ex?s*2:Math.floor(s/2))*((G.careerConditionMul===undefined)?1:G.careerConditionMul)), cash=(G.careerCash===undefined)?(ex?s*2:0):G.careerCash, b=c.b||{}
'@

SubRx @'
  if(ex) sh+=row('','<span class="lgl">EXTRACTION x2</span>'+cnt(s,'+'));
'@ @'
  // v28.xx (cw-cx-condition-sp): conditions stay in the SP panel; cash stays in the money panel.
  var crs=raidConditionRows();
  if(DMUL_ON) for(i=0;i<crs.length;i++) sh+=row('dm','<span class="lgl">'+escHtml(crs[i][0])+'</span><b>x1.05</b>');
  if(ex) sh+=row('','<span class="lgl">EXTRACTION x2</span>'+cnt(Math.round(s*((G.careerConditionMul===undefined)?1:G.careerConditionMul)),'+'));
'@

SubRx @'
    mh+=row('cr','<span class="lgl">CREDITS BANKED</span>'+((fin>0)?cnt(fin,'+',1):'<b>+'+arcadeMoney(0)+'</b>'));
    tot=fin+hv;
'@ @'
    mh+=row('cr','<span class="lgl">CREDITS BANKED</span>'+((cash>0)?cnt(cash,'+',1):'<b>+'+arcadeMoney(0)+'</b>'));
    tot=cash+hv;
'@

SubRx @'
arcadeCr(s-fin)+'</b>');
'@ @'
arcadeCr(Math.round(s*((G.careerConditionMul===undefined)?1:G.careerConditionMul))-fin)+'</b>');
'@

SubRx @'
arcadeMoney(fin)+'</s> LOST</b>');
'@ @'
arcadeMoney(Math.floor(s/2))+'</s> LOST</b>');
'@

SubRx @'
function spMul(n){ var m=diffMul(); return (n>0&&m>1)?Math.round(n*m):n; }
'@ @'
// v28.xx (cw-cx-condition-sp): demo conditions multiply earned SP; career applies them at settlement to keep cash unchanged.
function spMul(n){ var m=diffMul()*((G&&G.arcade)?raidConditionMul():1); return (n>0&&m>1)?Math.round(n*m):n; }
'@

SubRx @'
var VER='35.78';
'@ @'
var VER='35.79';
'@

$pat = "(?m)^  now:'v35\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.79: Night and hard weather were 1.20x and 1.10x XP. Terms were additive +25% for blackout and short window, +30% for heavy patrols, they know you and silent running, on haul cash and the spForRun part of Mainframe XP. SP is the live raid score and leaderboard; XP is the separate reward track. Each active condition now multiplies SP by 1.05, stacking multiplicatively, with no extra cash or XP. Career cash conversion uses the score before these conditions; the demo applies them to earned SP. Existing difficulty settings and dose XP are unchanged. Watch: compare matching day and night extractions, rain/fog, and several signed Terms in both windows; SP should rise while money and XP stay level. Seven conditions give 1.4071x SP. No seeded random calls or world generation changed. Check 35.79 fails on v35.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
