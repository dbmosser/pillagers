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

# SEASON ZERO M3: A DEATH TAKES WHAT YOU WORE, AN EXTRACT EARNS PIPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pilRaidEnd(how,sec,lost){
'@ @'
// v37.xx (cw-m3death), HIS RULINGS OF 11-01 (season zero m3, plan "worn gear"): "upon death player keeps cash in stash, lifetime earns, account. But player loses their pillager,
// and anything the pillager took with them into the raid, including worn gear"; "i like the idea of worn gear that you lose upon death -- makes dying more costly". No insurance.
// A death or a quit that ends the pillager empties P.worn once the hall has its copy (the stash pieces, P.gear, are not touched) and the card lists each piece lost at its price.
// An extract gives every worn piece one pip, up to 3 (answer 60; wornTraitV makes each a third stronger); nothing ever takes one away (answer 61: gear never wears out).
// Only his own career raid: never G.sim, the demo or the player 2 window.
function wornOwnRaid(){ if(!G||G.sim||G.arcade||!P) return false; if(typeof ARCADE==='object'&&ARCADE&&ARCADE.on) return false; if(typeof NETP2!=='undefined'&&NETP2) return false; return true; }
function wornOwnList(){ var L=[], i, pc, W=P&&P.worn; if(!wornOwnRaid()||!W||typeof W!=='object') return L; for(i=0;i<WORN_SLOTS.length;i++){ pc=W[WORN_SLOTS[i]]; if(pc&&WORN_KINDS[pc.k]&&WORN_RARS[pc.r]) L.push(pc); } return L; }
function wornLostV(pc){ return Math.round(wornPrice(pc)*CFG.lootMult); }
// The ledger's own row: the kind's icon in its rarity colour, the name, lost.
function wornLostLine(pc){ return iconImgHTML('wg_'+pc.k+'_'+pc.r+'_1_0',32,1)+' '+'<span style="color:'+WORN_RARS[pc.r].c+'">'+escHtml(wornName(pc))+'</span><span style="color:var(--rust)">  LOST</span>'; }
// One pip on each worn piece below 3, one short line per piece that gained, at most 4 and then +n.
function wornPipGain(lines){
  var L=wornOwnList(), up=[], i, pc;
  for(i=0;i<L.length;i++){ pc=L[i]; if((pc.pip|0)<3){ pc.pip=(pc.pip|0)+1; up.push(pc); } }
  for(i=0;i<up.length&&i<4;i++) lines.push('<span style="color:'+WORN_RARS[up[i].r].c+'">'+escHtml(wornName(up[i]))+' pip '+up[i].pip+'</span>');
  if(up.length>4) lines.push('<span style="color:var(--ash)">+'+(up.length-4)+'</span>');
  return up.length;
}
function pilRaidEnd(how,sec,lost){
'@

SubRx @'
    worn:JSON.parse(JSON.stringify(P.worn||{})), look:pilLookNow()});
  pilHeirs(P);
'@ @'
    worn:JSON.parse(JSON.stringify(P.worn||{})), look:pilLookNow()});
  if(r) P.worn={};   // v37.xx (cw-m3death): the pieces went with the pillager; the stash pieces stay
  pilHeirs(P);
'@

SubRx @'
    var nSafe=Math.min(Math.round(CFG.safeSlots),idx.length);   // v8.50: 'pockets' left at v5.57
'@ @'
    // v37.xx (cw-m3death): a worn piece in the raid bag never takes a safe pocket. The pockets go to the dearest other things; the rest keep value order.
    var _sfI=idx.filter(function(x){ return !wornKeyIs(G.bag[x]); }).slice(0,Math.max(0,Math.round(CFG.safeSlots)||0));
    idx=_sfI.concat(idx.filter(function(x){ return _sfI.indexOf(x)<0; }));
    var nSafe=_sfI.length;   // v8.50: 'pockets' left at v5.57
'@

SubRx @'
    if(lostIdx.length>shown.length) lines.push('<span style="color:var(--ash)">and '+(lostIdx.length-shown.length)+' more, all gone</span>');
'@ @'
    var _wnL=wornOwnList(), _wnV=0;   // v37.xx (cw-m3death): what the pillager wore is lost with it, each piece at its price
    for(j=0;j<_wnL.length;j++){ _wnV+=wornLostV(_wnL[j]); lines.push(wornLostLine(_wnL[j])); }
    if(lostIdx.length>shown.length) lines.push('<span style="color:var(--ash)">and '+(lostIdx.length-shown.length)+' more, all gone</span>');
'@

SubRx @'
    if(_gunN) _lostWhat+=' and '+_gunN+' gun'+(_gunN===1?'':'s');
    lines.push(_lostWhat+' lost, '+'$'+((haul-savedVal-_dIss*ival('bandage'))+_gunVal).toLocaleString()+' gone');
'@ @'
    if(_gunN) _lostWhat+=(_wnL.length?', ':' and ')+_gunN+' gun'+(_gunN===1?'':'s');
    if(_wnL.length) _lostWhat+=' and '+_wnL.length+' worn piece'+(_wnL.length===1?'':'s');   // v37.xx (cw-m3death)
    lines.push(_lostWhat+' lost, '+'$'+((haul-savedVal-_dIss*ival('bandage'))+_gunVal+_wnV).toLocaleString()+' gone');
'@

SubRx @'
    // v37.xx (cw-m1xpoff): walking out costs no XP, so the card has no fee line
'@ @'
    // v37.xx (cw-m1xpoff): walking out costs no XP, so the card has no fee line
    var _wnQ=0, _wnQL=wornOwnList(), _wq;   // v37.xx (cw-m3death): a quit ends the pillager, so what it wore is lost as on the KIA card
    for(_wq=0;_wq<_wnQL.length;_wq++){ _wnQ+=wornLostV(_wnQL[_wq]); lines.push(wornLostLine(_wnQL[_wq])); }
'@

SubRx @'
_plV=(haul-savedVal-_dIss*ival('bandage'))+_gunVal; }
    else if(how==='abandon'){ _plK=G.bag.slice(); _plV=haul; }
'@ @'
_plV=(haul-savedVal-_dIss*ival('bandage'))+_gunVal+(_wnV||0); }
    else if(how==='abandon'){ _plK=G.bag.slice(); _plV=haul+(_wnQ||0); }   // v37.xx (cw-m3death): and the worn pieces
'@

SubRx @'
    if(G.tel) G.tel.extBonus=_xb;
'@ @'
    if(G.tel) G.tel.extBonus=_xb;
    wornPipGain(lines);   // v37.xx (cw-m3death), his answer 60: extracting wearing a piece earns it a pip, up to 3
'@

SubRx @'
var VER='37.59';
'@ @'
var VER='37.60';
'@

$pat = "(?m)^  now:'v37\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.60: a death or a quit that ends the pillager empties the worn slots after the hall copies them; the stash pieces are not touched. The KIA card lists each worn piece in its rarity colour marked lost, the count says n worn pieces and the money gone includes them at their price (the hall value lost too). A piece carried in the raid bag never takes a safe pocket. An extract gives each worn piece one pip, up to 3, with one line per piece that gained (name pip n, at most 4 then +n). The free walk back, a sim raid, the demo and the player 2 window take nothing and add no pip Check 37.60 fails on v37.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
