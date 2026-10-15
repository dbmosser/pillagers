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

# THE APPEARANCE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
grid-template-columns:260px 1fr;grid-template-rows:minmax(0,1fr);margin-top:6px
'@ @'
grid-template-columns:400px 1fr;grid-template-rows:minmax(0,1fr);margin-top:6px
'@

SubRx @'
      <h2>The racks</h2>
      <div id="appavatarpicker"
'@ @'
      <h2>The racks</h2>
      <div id="apptabs" class="invtabs ui-tabs" style="flex:none;margin:0 12px"></div>
      <div id="appavatarpicker"
'@

SubRx @'
<canvas class="avcv" id="avcv" width="200" height="320"></canvas>
'@ @'
<canvas class="avcv" id="avcv" width="380" height="470"></canvas>
'@

SubRx @'
.cosreq{margin-top:2px;font-size:13px;color:var(--tx-2);letter-spacing:.08em;text-transform:uppercase}
'@ @'
.cosreq{margin-top:2px;font-size:13px;color:var(--tx-2);letter-spacing:.08em;text-transform:uppercase}
/* v28.29 (cosm7), HIS ORDER (2026-10-15): the appearance screen in the game UI style. A tile wears a bar in its rarity colour (from what it takes to earn it),
   a scheme tile shows its three colours, the colour rack has a one line legend. */
#appavatarpicker .costile[data-rar]{ border-top:3px solid var(--rar,#9da3a8); }
#appavatarpicker .costile[data-rar="common"]{ --rar:#9da3a8; }
#appavatarpicker .costile[data-rar="uncommon"]{ --rar:#5fbf6a; }
#appavatarpicker .costile[data-rar="rare"]{ --rar:#3f9de9; }
#appavatarpicker .costile[data-rar="elite"]{ --rar:#a866e0; }
#appavatarpicker .costile[data-rar="gold"]{ --rar:#ffc72e; }
#appavatarpicker .costile[data-rar="elite"]:not(.lock){ box-shadow:0 0 10px rgba(168,102,224,.16); }
#appavatarpicker .costile[data-rar="gold"]:not(.lock){ box-shadow:0 0 12px rgba(255,199,46,.18); }
.cosdots{ display:flex; gap:3px; margin-top:4px; justify-content:center; }
.cosdots i{ display:block; width:18px; height:7px; border:1px solid #0b0d10; box-sizing:border-box; }
.cosnote{ font-size:13px; letter-spacing:.08em; color:var(--tx-2); margin:0 0 8px; text-transform:uppercase; }
'@

SubRx @'
function drawAvatarCanvas(){
'@ @'
// v28.29 (cosm7): THE TABS. Every rack is on exactly one tab; a slot on the left jumps to its tab.
var COSTABS=[['head','HEAD',['hat','cut','hair','beard','skin','eyes','face','tattoo']],['body','BODY',['build','vest','pads','boots','patch','fit']],
             ['pack','PACK',['pack','gloves']],['colours','COLOURS',['scheme']],['sets','SETS',['set','outfit']]];
var AVTAB='head', COSRAR=['common','uncommon','rare','elite','gold'];
function cosOrd(kind){ for(var i=0;i<COSTABS.length;i++){ var j=COSTABS[i][2].indexOf(kind); if(j>=0) return j; } return 99; }
function cosTabOf(kind){ for(var i=0;i<COSTABS.length;i++) if(COSTABS[i][2].indexOf(kind)>=0) return COSTABS[i][0]; return ''; }
function renderAvTabs(){
  var box=document.getElementById('apptabs'); if(!box) return;
  box.innerHTML='';
  COSTABS.forEach(function(t){
    var d=document.createElement('div'); d.className='invtab'+(AVTAB===t[0]?' on':''); d.textContent=t[1]; d.setAttribute('data-tab',t[0]);
    d.onclick=function(){ AVTAB=t[0]; P._avSlot=null; renderAvatar('appavatar','appavatarpicker'); try{ sfx('pick'); }catch(_s){} };
    box.appendChild(d);
  });
}
// The rarity of a piece, from what it takes to earn it: owned from the start is common; a few raids or an extraction or two uncommon; a long
// grind, a high level or a rank of extractions rare and epic; a Warden kill or the reward board gold. A set is as rare as its rarest piece.
function cosRarity(c){
  var r=0, bits, k, v, kk, i, p;
  if(!c) return 'common';
  if(c.how==='set'){ for(kk in c.parts){ p=cosFind(c.parts[kk]); i=COSRAR.indexOf(cosRarity(p)); if(i>r) r=i; } return COSRAR[r]; }
  bits=String(c.how).split(':'); k=bits[0]; v=+bits[1]||0;
  if(k==='always') r=0;
  else if(k==='runs') r=(v<=6)?1:(v<=14?2:3);
  else if(k==='extracts') r=(v<=5)?1:(v<=10?2:(v<=14?3:4));
  else if(k==='level') r=(v<=2)?1:(v<=4?2:3);
  else if(k==='warden') r=(v<=1)?3:4;
  else if(k==='board') r=4;
  else r=2;
  return COSRAR[r];
}
function cosDots(c){
  var S, a;
  if(!c||c.kind!=='scheme') return '';
  S=SCHEMES[c.id]; a=S?[S.p,S.s,S.a]:[(FITCOL.slate||[])[1]||'#59626f',(FITCOL.slate||[])[0]||'#3d4450','#8a96a1'];
  return '<div class="cosdots">'+a.map(function(h){ return '<i style="background:'+h+'"></i>'; }).join('')+'</div>';
}
// THE TURNTABLE. The big picture of your operator turns slowly while FASHION is open (the facing sweeps the whole way round, so the pack, the pads
// and the eyes all show), breathing as it stands. Drawn by the raid painter, only while the window is up; a step is also callable by itself.
var AVANG=0.45, AVPH=0, AVTMR=0;
function avTurnStep(dt){ AVANG+=0.9*dt; if(AVANG>6.2832) AVANG-=6.2832; AVPH+=dt*5.5; drawAvatarCanvas(); }
function avTurnStart(){
  if(AVTMR||typeof setInterval!=='function') return;
  AVTMR=setInterval(function(){
    var m=document.getElementById('appearmodal');
    if(!m||!m.classList.contains('on')||!document.getElementById('avcv')){ clearInterval(AVTMR); AVTMR=0; return; }
    try{ avTurnStep(0.08); }catch(_t){}
  },80);
}
function drawAvatarCanvas(){
'@

SubRx @'
  var S=5.2;
'@ @'
  var S=Math.max(5.2,c.height/62);   // v28.29 (cosm7): the figure fills the taller canvas
'@

SubRx @'
try{ drawOp(0,0,0,0,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}}); }
'@ @'
try{ drawOp(0,0,AVANG,AVPH,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}}); }   // v28.29 (cosm7): turning
'@

SubRx @'
  if(hid==='appavatar') renderLooks(hid,pid);     // v10.16: only at the Depot
'@ @'
  if(hid==='appavatar'){ renderLooks(hid,pid); renderAvTabs(); avTurnStart(); }     // v10.16: only at the Depot; v28.29 (cosm7): the tabs and the turntable
'@

SubRx @'
    .filter(function(g){ return !kindOnly||g[0]===kindOnly; });
'@ @'
    .filter(function(g){ return kindOnly?(g[0]===kindOnly):(hid!=='appavatar'||cosTabOf(g[0])===AVTAB); })   // v28.29 (cosm7): in FASHION the open tab only, in the order of its list
    .sort(function(a,b){ return (hid==='appavatar'&&!kindOnly)?(cosOrd(a[0])-cosOrd(b[0])):0; });
  if(kindOnly&&hid==='appavatar'&&cosTabOf(kindOnly)) AVTAB=cosTabOf(kindOnly);   // a slot on the left opens its own tab
'@

SubRx @'
H+='<div style="margin:10px 0 4px 0;letter-spacing:.12em;font-size:13px;color:var(--tx-2)">'+g[1]+'</div>';
'@ @'
H+='<div style="margin:10px 0 4px 0;letter-spacing:.12em;font-size:13px;color:var(--tx-2)">'+g[1]+'</div>';
    if(g[0]==='scheme') H+='<div class="cosnote">PRIMARY: COAT AND SLEEVES. SECONDARY: PLATE, PACK, BOOTS. ACCENT: TRIM.</div>';   // v28.29 (cosm7)
'@

SubRx @'
data-id="'+c.id+'">'+
'@ @'
data-id="'+c.id+'" data-rar="'+cosRarity(c)+'">'+
'@

SubRx @'
         cosSwatch(c)+'<div class="cosname">'+c.name+'</div>'+
'@ @'
         cosSwatch(c)+'<div class="cosname">'+c.name+'</div>'+cosDots(c)+
'@

SubRx @'
var VER='28.28';
'@ @'
var VER='28.29';
'@

$pat = "(?m)^  now:'v28\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.29: FASHION has tabs for head, body, pack, colours and sets, a bigger turning picture, and rarity bars. Check 28.29 fails on v28.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
