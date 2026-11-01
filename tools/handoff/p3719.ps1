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

# SEASON ZERO M1: NO MORE XP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
mig0p:1,lifeEarn:0,   // v37.xx (cw-p0acct)
'@ @'
mig0p:1,lifeEarn:0,mig1x:1,   // v37.xx (cw-m1xpoff): the second ladder payout stamp, born set (xpOffMig)   // v37.xx (cw-p0acct)
'@

SubRx @'
// Lifetime earnings only ever go up. The one writer m1 calls for every $ earned.
'@ @'
// v37.xx (cw-m1xpoff), HIS ORDER (11-01): "lets get rid of the concept of xp altogether -- everything you can get, you have to buy with cash".
// Plan m1: XP, levels and the XP ladder come off every screen. Once per save (P.mig1x, born set on a new profile), after seasonZeroMig: every
// ladder reward the save earned and never claimed (the XP it earned between m0 and this build) is paid as $ and marked claimed, the $ goes into
// lifetime earnings, and the one-time hub line adds to a line not yet shown rather than replacing it. P.xp stays in the save; nothing reads it.
function xpOffMig(p){
  var pay, n;
  if(!p||typeof p!=='object'||p.mig1x===1) return null;
  pay=ladderPayout(p);
  if(pay.c>0){
    if(p===P) lifeEarnAdd(pay.c); else { acctEnsure(p); p.lifeEarn=Math.round(p.lifeEarn+pay.c); }
    n=p.szNote;
    if(n&&typeof n==='object'&&!n.shown&&n.c>0){ n.c=Math.round(n.c+pay.c); n.n=(n.n|0)+pay.n; }
    else p.szNote={c:pay.c,n:pay.n,shown:0};
  }
  p.mig1x=1;
  return pay;
}
// Lifetime earnings only ever go up. The one writer m1 calls for every $ earned.
'@

SubRx @'
          try{ seasonZeroMig(P); }catch(_szm){}
'@ @'
          try{ seasonZeroMig(P); }catch(_szm){}
          try{ xpOffMig(P); }catch(_xom){}   // v37.xx (cw-m1xpoff): ladder rewards earned since m0 paid as $ (once, P.mig1x)
'@

SubRx @'
  var _xb=xpBaseFor(rec), _xg=addXp(_xb,(rec.doseMul>0)?rec.doseMul:undefined);   // v12.12: the multiplier the card printed
  rec.xpBase=_xb; rec.xpGot=_xg;
  syncXpLevel();   // v12.67: the same formula, in one named place
'@ @'
  // v37.xx (cw-m1xpoff), his 11-01 order ("lets get rid of the concept of xp altogether"): a run pays no XP and P.xp is left as it is.
  // SP is settled by careerSettle and is unchanged.
'@

SubRx @'
  n=Math.round(n||0); if(n<=0) return 0;
  var g=Math.round(n*((mul!==undefined)?mul:buzzXpMul()));   // v12.12: a run banks the bonus its card printed
  P.xp=(P.xp||0)+g;
  return g;
'@ @'
  return 0;   // v37.xx (cw-m1xpoff): nothing earns XP any more (his 11-01 order); the saved figure stays as it is
'@

SubRx @'
  var x=40 + Math.round((rec.containers||0)*4) + Math.round((rec.dist||0)/900);
  if(rec.outcome==='dead') x*=0.5;
  else if(rec.outcome==='abandon') x*=0.25;
  return Math.round(x);
'@ @'
  return 0;   // v37.xx (cw-m1xpoff): a run is worth no XP (his 11-01 order)
'@

SubRx @'
  (function(){
    var _grec={outcome:how,haul:haul,carriedIn:G.carriedIn||0,containers:T.containers,kills:T.kills,termPay:tPay,
      doorsOpened:T.doorsOpened||0,caches:T.cachesOpened||0,dist:Math.round(T.distance||0),   // v13.57: rounded as the banked record rounds it
      // v11.63: the same two flags the banked record carries, so the card prints
      // what addProgress and addXp will actually credit: night, weather and dose.
      night:(typeof isDay==='function'&&!isDay())?1:0,
      wxHard:(typeof wxHardId==='function')?wxHardId((G.wx&&G.wx.id)||'clear'):0};
    var gained=Math.round(xpBaseFor(_grec)*buzzXpMul());
    if(gained>0){
      var cap=SEASON_TIERS[SEASON_TIERS.length-1].sp;
      // HIS NOTE, v3.59: "it says Season 1 +84 progress -- but what the hell
      // does that mean? is it rep? not clear". It is not rep. Named and
      // explained at the one place he reads it.
      // v8.71, his note: "what happens at Y? Not clear." Nothing happened at Y,
      // and the old line said "XP progress unlocks the Mainframe rewards", which
      // promised something automatic. Nothing is automatic: every one of the 100
      // rewards waits at THE MAINFRAME under REWARDS until you press Claim. The
      // line now names the next one and what it costs.
      var _xa=(P.xp||0)+gained, _nx=null;
      for(var _ni=0;_ni<SEASON_TIERS.length;_ni++) if(SEASON_TIERS[_ni].sp>_xa){ _nx=_ni; break; }
      lines.push('<span style="color:var(--amber)">+'+gained.toLocaleString()+' XP'+
        (how==='dead'?' (50% penalty for failure to extract)':(how==='abandon'?' (75% penalty for backing out)':''))+
        (how==='dead'
          ? '  &middot;  '+_xa.toLocaleString()+' XP in all'
          : '  &middot;  '+Math.min(cap,_xa).toLocaleString()+' of '+cap.toLocaleString())+
        '</span><br><span style="color:var(--ash)">'+
        (_nx===null
          ? 'All '+SEASON_TIERS.length+' rewards earned. XP keeps counting, but there is nothing left that it pays for.'
          // v8.91, his note: not on a death screen. A man reading KILLED IN
          // ACTION does not need to be told what the next reward is.
          : (how==='dead' ? ''
            : 'Next: '+escHtml(tierLabel(SEASON_TIERS[_nx]))+', reward '+(_nx+1)+' of '+SEASON_TIERS.length+
              ', '+(SEASON_TIERS[_nx].sp-_xa).toLocaleString()+' XP away. Claim it at the Mainframe.'))+
        '</span>');
    }
  })();
'@ @'
  // v37.xx (cw-m1xpoff), his 11-01 order ("lets get rid of the concept of xp altogether"): the card has no XP line and no next reward line.
'@

SubRx @'
    if(G.abandonFee>0) lines.push('<span style="color:var(--rust)">Walked out on the job. XP -'+G.abandonFee+'.</span>');
'@ @'
    // v37.xx (cw-m1xpoff): walking out costs no XP, so the card has no fee line
'@

SubRx @'
    var _rc=Math.min(abandonRepCost(runElapsed()),(P.xp||0));   // v17.64: from when this player joined
    P.xp=Math.max(0,(P.xp||0)-_rc);
'@ @'
    var _rc=0;   // v37.xx (cw-m1xpoff): no XP fee (his 11-01 order); P.xp is left as it is
'@

SubRx @'
    var _ac=Math.min(abandonRepCost(_el),(P.xp||0));
    // v23.22 (arcade3): an arcade raid costs no XP, so its confirm quotes none
    /* v28.xx (cw-endflat), the critic on 59: "an explaining parenthetical on the danger button". Q8, reason logged in notes/ui/changes.md: the cost is its own quiet 16px line under the button words, not a bracket inside them. */
    cb.innerHTML=(G&&G.arcade)?'YES, ABANDON THIS RUN':'YES, ABANDON THIS RUN <small>'+((_el>60)?(_ac>0?('costs '+_ac+' XP'):'no XP to lose'):'free this early')+'</small>';
'@ @'
    cb.innerHTML='YES, ABANDON THIS RUN';   // v37.xx (cw-m1xpoff): walking out costs no XP, so the button quotes no cost
'@

SubRx @'
  if(k==='board')    return ((P.spClaimed||[]).length)>=SEASON_TIERS.length;
  if(k==='level')    return (P.xpLevel||1)>=v;
'@ @'
  if(k==='board'||k==='level') return true;   // v37.xx (cw-m1xpoff): no player level and no reward board any more, so nothing they gated stays locked
'@

SubRx @'
function seasonReady(){
  var cl=seasonClaimed(),n=0;
  for(var i=0;i<SEASON_TIERS.length;i++)
    if((P.xp||0)>=SEASON_TIERS[i].sp&&cl.indexOf(i)<0) n++;
  return n;
}
'@ @'
function seasonReady(){ return 0; }   // v37.xx (cw-m1xpoff): the XP ladder is gone; xpOffMig paid what was earned, so no reward is waiting anywhere
'@

SubRx @'
  var T=SEASON_TIERS[ix]; if(!T) return null;
'@ @'
  var T=SEASON_TIERS[ix]; if(!T||!seasonReady()) return null;   // v37.xx (cw-m1xpoff): nothing is claimed from the ladder any more
'@

SubRx @'
  var head=document.getElementById('seasonhead');
  head.textContent='XP';
  var cap=SEASON_TIERS[SEASON_TIERS.length-1].sp,sp=P.xp||0;
  document.getElementById('seasonfill').style.width=clamp(100*sp/cap,0,100)+'%';
  document.getElementById('seasontext').textContent=Math.min(sp,cap).toLocaleString()+' / '+cap.toLocaleString();
  var el=document.getElementById('seasonlist'); el.innerHTML='';
  try{ syncOpsTabs(); }catch(_st){}    // v8.19: the tab badge follows the board
  (function(){
    var _sb=document.getElementById('seasonclaimall'); if(!_sb) return;
    var _sr=seasonReady();
    _sb.textContent=_sr?('CLAIM ALL  ('+_sr+')'):'CLAIM ALL';   // v28.xx (cw-rackrew), critic task 99: the sentence "nothing ready to claim" is gone (Q8: the disabled button already says nothing is ready)
    _sb.disabled=!_sr;
    _sb.onclick=claimAllTiers;
  })();
  var cl=seasonClaimed();
  var _rwNx=-1; for(var _ri=0;_ri<SEASON_TIERS.length;_ri++){ if(cl.indexOf(_ri)<0&&sp<SEASON_TIERS[_ri].sp){ _rwNx=_ri; break; } }   // v28.xx (cw-rackrew): the next reward to earn reads first
  SEASON_TIERS.forEach(function(T,ix){
    var row=document.createElement('div'); row.className='row';
    var got=cl.indexOf(ix)>=0,ready=!got&&sp>=T.sp;
    row.className+=' rw-'+T.kind+(ready?' rw-ready':'')+(ix===_rwNx?' rw-next':'');   // v28.xx (cw-rackrew): type cue (credits, wep, kit), ready, next
    var nm=document.createElement('div'); nm.className='nm';
    nm.textContent=(ix+1)+'.  '+tierLabel(T);
    if(got) nm.style.color='var(--ash)';
    else if(!ready) nm.style.color='var(--ash)';
    var vl=document.createElement('div'); vl.className='vl';
    vl.textContent=got?'claimed':(ready?'ready':(T.sp-sp).toLocaleString()+' to go');
    if(ready) vl.style.color='#ffc04a';
    var b=document.createElement('button');
    if(got){ b.textContent='Claimed'; b.disabled=true; }
    else if(!ready){ b.textContent=T.sp.toLocaleString(); b.disabled=true; }
    else {
      b.textContent='Claim';
      b.onclick=function(){
        var m=claimTier(ix);
        // v8.10: "Reward", not "Tier" - the word is on his Never list, and the
        // v8.06 vocabulary sweep walked straight past this one.
        if(m) say2('Reward '+(ix+1)+': '+m);
        renderSeason(); renderHub();
      };
    }
    row.appendChild(nm); row.appendChild(vl); row.appendChild(b);
    el.appendChild(row);
  });
'@ @'
  // v37.xx (cw-m1xpoff), his 11-01 order ("lets get rid of the concept of xp altogether"): no XP bar and no reward ladder. The pane is never
  // opened (openOps has no REWARDS tab); it is emptied so nothing in it prints XP.
  var el=document.getElementById('seasonlist'); if(el) el.innerHTML='';
  var head=document.getElementById('seasonhead'); if(head) head.textContent='';
  var _stx=document.getElementById('seasontext'); if(_stx) _stx.textContent='';
  try{ syncOpsTabs(); }catch(_st){}
'@

SubRx @'
    <div class="msub">Kills, loot, doors, selling and extracting all pay XP. Dying pays half. A hundred rewards, claimed in order, and nothing here ever resets.</div>
'@ @'
    <div class="msub"></div><!-- v37.xx (cw-m1xpoff): the XP ladder is gone -->
'@

SubRx @'
  var T=[['con','CONTRACTS'],['rew','REWARDS'],['mf','RACKS'],['rec','YOUR STATS']];
'@ @'
  var T=[['con','CONTRACTS'],['mf','RACKS'],['rec','YOUR STATS']];   // v37.xx (cw-m1xpoff): no REWARDS tab (the XP ladder is gone); an old call for it opens contracts
  if(want==='rew') want='con';
  (function(){ var _rp=document.getElementById('opane_rew'); if(_rp) _rp.style.display='none'; })();
'@

SubRx @'
           KeyR:['rewards', function(){ openOps('rew'); }],
'@ @'
           // v37.xx (cw-m1xpoff): no rewards key (the XP ladder is gone)
'@

SubRx @'
  el.innerHTML='\x24'+c+'<span class="trgap"></span>'+x+' <small>XP</small> <small class="trl">STASH</small>
'@ @'
  // v37.xx (cw-m1xpoff), his 11-01 order: no xp in the corner readout
  el.innerHTML='\x24'+c+'<span class="trgap"></span><small class="trl">STASH</small>
'@

SubRx @'
  c.innerHTML=(P.credits||0).toLocaleString()+'<em>c</em>'+
    '<i>'+(P.xp||0).toLocaleString()+'<em>XP</em></i>';
'@ @'
  c.innerHTML=(P.credits||0).toLocaleString()+'<em>c</em>';   // v37.xx (cw-m1xpoff): no xp beside the balance
'@

SubRx @'
THE STASH &mdash; XP <span id="reptop" style="color:var(--amber)">0</span>
'@ @'
THE STASH<span id="reptop" style="display:none">0</span><!-- v37.xx (cw-m1xpoff): no xp in the stash header -->
'@

SubRx @'
  h+=card('Experience', 'Level '+(P.xpLevel||1),
          (P.xp||0).toLocaleString()+' XP earned');
'@ @'
  // v37.xx (cw-m1xpoff), his 11-01 order: no Experience card (no XP and no player level); m1e puts lifetime earnings and the rank here
'@

SubRx @'
           (inf?(inf.runs+' raid'+(inf.runs===1?'':'s')+' \u00b7 $'+inf.credits.toLocaleString()+' \u00b7 '+inf.xp.toLocaleString()+' XP'):'new')+
'@ @'
           (inf?(inf.runs+' raid'+(inf.runs===1?'':'s')+' \u00b7 $'+inf.credits.toLocaleString()):'new')+   // v37.xx (cw-m1xpoff): no xp on a save slot
'@

SubRx @'
    if(buzzTotal()) rows.push({k:'RAID XP',v:'+'+buzzXpPct()+'%',c:'#d98aff'});
'@ @'
    // v37.xx (cw-m1xpoff): no RAID XP row (a raid pays no XP)
'@

SubRx @'
    ? ('In your blood now: '+buzzTotal()+' dose'+(buzzTotal()===1?'':'s')+', RAID XP +'+buzzXpPct()+'%.')
'@ @'
    ? ('In your blood now: '+buzzTotal()+' dose'+(buzzTotal()===1?'':'s')+'.')   // v37.xx (cw-m1xpoff): no raid xp figure
'@

SubRx @'
    ctx.fillText('Carried home: '+'$'+fullv.toLocaleString()+' and '+fullv.toLocaleString()+' XP. He pays no XP.',x+14,cy);
'@ @'
    ctx.fillText('Carried home: '+'$'+fullv.toLocaleString()+'.',x+14,cy);   // v37.xx (cw-m1xpoff): no xp
'@

SubRx @'
         ', '+(o.x|0).toLocaleString()+' XP, '+st+' item'+(st===1?'':'s')+' in the stash'+
'@ @'
         ', '+st+' item'+(st===1?'':'s')+' in the stash'+   // v37.xx (cw-m1xpoff): the code still carries x and l; nothing shows them
'@

SubRx @'
    'XP comes from selling salvage in the Undercroft.';
'@ @'
    '';   // v37.xx (cw-m1xpoff): there is no XP
'@

SubRx @'
  return 'Salvage. Sell it at the terminal for credits and XP.';
'@ @'
  return 'Salvage. Sell it at the terminal for credits.';   // v37.xx (cw-m1xpoff): no xp
'@

SubRx @'
var VER='37.18';
'@ @'
var VER='37.19';
'@

$pat = "(?m)^  now:'v37\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.19: a run, a walk out and nothing else earns or costs XP; the Mainframe has no rewards tab, no claim buttons and no rewards waiting badge; no xp or level figure on the raid end card, the corner readout, the stash header, the stats tab, the save slots or the peddler panel; looks a level or the reward board gated are open; an old save is paid once in cash for ladder rewards earned since the last payout and never claimed, the money counts in lifetime earnings and the hub says it once; the saved XP figure stays in the save and the restore code still carries it; SP and the career board are unchanged Check 37.19 fails on v37.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
