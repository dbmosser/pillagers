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

# RUN GOALS PAY REWARDS NOT SP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function goalsTick(dt){
'@ @'
// v28.xx (cw-cx-goalrewards), HIS WORDS (2026-10-28): "sp is like a high score counter". Changing goals pay only on extraction; the demo gets power-ups.
function goalRewardText(gl){
  if(G.arcade) return 'power-up';
  return /^(vault|pill3|elite|ward)$/.test(gl.id)?'item':('$'+((gl.chip|0)*5).toLocaleString());
}
function goalReward(gl,quiet){
  var R, item=null, kd=null, total=0, pick=0, i, p=G.player;
  if(!gl||gl.rewarded||G.sim||!(G.arcade||G.career)||!p) return 0;
  gl.rewarded=1;
  if(G.arcade){
    // v28.xx (cw-cx-goalrewards): same weighted pool as kill drops, on a separate stream; one local drop per seat, as all power-ups are local.
    for(i=0;i<PWR_KINDS.length;i++) total+=PWR_KINDS[i].w;
    sideStream((G.seed>>>0)||1,GOAL_TAG+200+GOAL_IDS.indexOf(gl.id),function(){ pick=rr()*total; });
    for(i=0;i<PWR_KINDS.length;i++){ pick-=PWR_KINDS[i].w; if(pick<0||i===PWR_KINDS.length-1){ kd=PWR_KINDS[i].k; break; } }
    pwrDrop(kd,p.x,p.y);
  } else {
    R=G.goalRewards||(G.goalRewards={cash:0,items:[]});
    if(goalRewardText(gl)==='item'){
      sideStream((G.seed>>>0)||1,GOAL_TAG+200+GOAL_IDS.indexOf(gl.id),function(){ item=rollLoot(LOOT.cache); });
      if(item&&ITEMS[item]) R.items.push(item);
      else R.cash+=(gl.chip|0)*5;
    } else R.cash+=(gl.chip|0)*5;
  }
  if(!quiet) say('GOAL DONE','ext',{sub:goalRewardText(gl)+(G.arcade?'':' at undercroft')});
  return 1;
}
function goalsSettle(how,lines){
  var R=G.goalRewards, i, k;
  if(!R||R.settled||G.sim||G.arcade||!G.career) return 0;
  R.settled=1;
  if(how!=='extract'){ R.cash=0; R.items=[]; return 0; }
  G.goalPaid={cash:R.cash|0,items:R.items.slice(),value:0};
  P.credits=(P.credits||0)+(R.cash|0);
  if(R.cash) lines.push('<span class="goalreward">run goals $'+R.cash.toLocaleString()+'</span>');
  for(i=0;i<R.items.length;i++){
    k=R.items[i]; bankItem(k); G.goalPaid.value+=ival(k);
    lines.push('<span class="goalreward">run goals '+escHtml(ITEMS[k].name.toLowerCase())+'</span>');
  }
  return R.cash|0;
}
function goalsTick(dt){
'@

SubRx @'
function flowChip(n,head,sub){
  var p=G.player;
'@ @'
function flowChip(n,head,sub){
  var p=G.player;
  if(/^GOAL/.test(head)) return 0;   // v28.xx (cw-cx-goalrewards): guard the old score door too; changing goals never pay SP.
'@

SubRx @'
csTally(/^GOAL/.test(head)?'goal':(/^BOUNTY/.test(head)?'bounty':'strong'),n);
'@ @'
csTally(/^BOUNTY/.test(head)?'bounty':'strong',n);
'@

SubRx @'
    if(v>=gl.n){ gl.done=1; flowChip(gl.chip,'GOAL DONE',gl.t); }
'@ @'
    if(v>=gl.n){ gl.done=1; goalReward(gl,false); }   // v28.xx (cw-cx-goalrewards): no goal ever feeds SP.
'@

SubRx @'
    if(gl.done&&!was&&!first){ try{ say('GOAL DONE','ext',{sub:gl.t}); }catch(_gd){} }
'@ @'
    // v28.xx (cw-cx-goalrewards): each career seat carries its own reward. Repeated packets and host takeover cannot pay twice.
    if(gl.done&&!was){
      if(!first||G.career) goalReward(gl,!!first);
      else gl.rewarded=1;
    }
'@

SubRx @'
  try{ careerSettle(how,lines); }catch(_cst){}   // v24.xx (feat0i): the CAREER score, paid only on an extraction
'@ @'
  try{ careerSettle(how,lines); }catch(_cst){}   // v24.xx (feat0i): the CAREER score, paid only on an extraction
  goalsSettle(how,lines);   // v28.xx (cw-cx-goalrewards): wallet and stash settle here, with the other extraction rewards, before saveProfile.
'@

SubRx @'
(_gl.done?'DONE':('+'+arcadeCr(_gl.chip)))
'@ @'
((_gl.done?'done ':'')+goalRewardText(_gl))
'@

SubRx @'
gl.done?'DONE':('+'+arcadeCr(gl.chip))
'@ @'
(gl.done?'done ':'')+goalRewardText(gl)
'@

SubRx @'
s:gl.done?'':('+'+arcadeCr(gl.chip))
'@ @'
s:goalRewardText(gl)
'@

SubRx @'
['OBJECTIVES','GOALS',b.goal|0],
'@ @'

'@

SubRx @'
    rest.push(ln);
'@ @'
    if(ex&&ln.indexOf('<span class="goalreward">')===0) continue;   // v28.xx (cw-cx-goalrewards): reward rows belong to the money panel below.
    rest.push(ln);
'@

SubRx @'
    tot=cash+hv;
'@ @'
    // v28.xx (cw-cx-goalrewards): named rewards in their own money rows, included once in the total; SP rows never include goals.
    var gr=G.goalPaid;
    if(gr&&gr.cash) mh+=row('gr','<span class="lgl">run goals</span>'+cnt(gr.cash,'+',1));
    if(gr) for(i=0;i<gr.items.length;i++) mh+=row('gr','<span class="lgl">run goals: '+escHtml(ITEMS[gr.items[i]].name.toLowerCase())+'</span>'+cnt(ival(gr.items[i]),'',1));
    tot=cash+hv+(gr?(gr.cash+gr.value):0);
'@

SubRx @'
Three run goals a raid, each paying a chip.
'@ @'
Three run goals a raid: cash or items at the undercroft; power-ups in the demo.
'@

SubRx @'
RUN GOALS. Both players count toward the three goals, in both windows and in the hold-Alt raid status.
'@ @'
RUN GOALS. Cash or items at the undercroft on extraction; power-ups in the demo. No sp. Both players share progress.
'@

SubRx @'
  if(flowPeer()) return;   // v27.27 (coop8): a linked player 2 window counts nothing and pays no chip, the goals are the host (goalsNetTake)
'@ @'
  if(flowPeer()) return;   // v28.xx (cw-cx-goalrewards): peers take shared progress and receive their own reward through goalsNetTake.
'@

SubRx @'
// v27.27 (coop8), HIS ORDER (2026-10-14), the two player first: THE RUN GOALS ARE THE PARTY'S. Each window drew its own three goals and counted its own kills, crates and strikes, so the
// two lists drifted apart and a goal one player finished paid its chip twice (once from each window). The host now owns the goals: it says the three (key r: which, how far, done) in the world
// word, the linked window draws exactly those and says GOAL DONE when one is met, and counts and pays nothing (goalsTick). What counts is the PARTY'S: a kill of player 2 reaches the run goals
// (the host reports it where it credits the kill to his seat), his strike counts for AIR STRIKE, his kill of the bounty pillager claims the bounty, and the crates and vault doors he opens
// are the host's boxes and doors already. The goals are in the hold Alt raid status too, a tile each, with the figure or DONE.

'@ @'
// v28.xx (cw-cx-goalrewards): the host owns the shared three goals and party progress. Each career seat carries its own reward home.
// The demo gives each seat one local power-up on completion. Repeated goal packets and host takeover never repeat a reward or award SP.

'@

SubRx @'
style medals (scoreBonus), goals, bounty and strongholds (flowChip) and vaults.
'@ @'
style medals (scoreBonus), bounty and strongholds (flowChip) and vaults. Goals never earn SP.
'@

SubRx @'
// v26.xx (flow3), HIS YES (2026-10-14) to suggestion 6, RUN GOALS: "three tiny goals per raid, each paying a score chip, the same in DEMO and CAREER". Three
// goals are drawn for the raid from a pool of eight small ones (10 kills, search 6 crates, survive 3 waves, call an air strike, open a vault,
// down 3 pillagers, kill an elite, down a warden), on the side stream GOAL_TAG of the raid seed, so the same seed always gets the same three (the party
// seed shares them) and the seeded stream of the build is not touched. The vault goal is left out of a map with no vault. Progress is counted
// from what the raid already knows (the two kill doors, the opened crates, the wave count of the Director, the strikes called, the vault
// doors). A goal that is met pays its CHIP into the run score at once, in DEMO (the team score) and in CAREER (the raid score) alike, with
// GOAL DONE and the chip in the alert lane and the amount over you. The list is a panel under the CONDITIONS panel (under the minimap in the
// arcade, which has no CONDITIONS) and shows each goal with its count, DONE in green when met.

'@ @'
// v28.xx (cw-cx-goalrewards), HIS ORDER (2026-10-28): changing run goals must never pay SP. Three goals still use only GOAL_TAG of the raid seed.
// Simple goals carry chip * $5 home on extraction ($1,000 / $1,250 / $1,500); vault, 3 pillagers, elite and warden carry one cache roll.
// Death and abandon lose them. The arcade demo gives each seat one local power-up at its feet, using the existing weighted kill pool.

'@

SubRx @'
var VER='36.32';
'@ @'
var VER='36.33';
'@

$pat = "(?m)^  now:'v36\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.33: Simple goals carry $1,000 to $1,500; hard goals carry a cache item. Extract to bank them, die or abandon to lose them. Demo goals give each seat a power-up. Goals never feed SP. Check 36.33 fails on v36.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
