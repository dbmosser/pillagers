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

# READABLE SILHOUETTES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var BUILD_Q=[]; (function(){ for(var i=0;i<16;i++) BUILD_Q.push([0,0]); })();
'@ @'
var BUILD_Q=[]; (function(){ for(var i=0;i<16;i++) BUILD_Q.push([0,0]); })();
// v23.xx (gfxsil), HIS #24 (2026-10-12): "b", redesign the character silhouettes for readability first. The team colour a body
// wears on its shoulders: your side in the HUD ally blue, a pillager (or the other player in PvP) in the HUD danger red.
var TEAMCOL={ally:'#5fb0ff',foe:'#e5482f'}, TEAMHI={ally:'#b4dcff',foe:'#ff9a84'};
'@

SubRx @'
  // HEALING, ABOVE HER HEAD, v5.44, his note. A shrinking arc and the seconds
'@ @'
  // v23.xx (gfxsil), HIS #24 (2026-10-12): REDESIGN THE SILHOUETTES FOR READABILITY. At raid size a body was a big head over a
  // box: the torso was narrower than the head, so nothing said where the shoulders were, which way the body was squared or
  // whose side it was on. Every body now carries two inked shoulder caps that stand out past the torso, giving the head and
  // shoulders T that reads at a glance. The caps follow the BUILD: wide and square on Broad, middling on Lean, small and
  // narrow on Curved, so she keeps her narrow shoulders over her waist and hips (her chest, hips and jiggle are untouched).
  // In a raid the caps wear the TEAM COLOUR (TEAMCOL): you and your team in ally blue, pillagers and a PvP rival in danger
  // red, the same in every window. Down in the Undercroft nobody has a side, so the caps are the coat in shadow. Where steel
  // pauldrons (armour 2 and up) or the Trooper plates already make the shoulder, the steel stays and only a team stripe
  // rides on top of it, so the armour tier still reads by its shape. Cosmetic only: no random numbers, nothing a fight reads.
  (function(){
    var _tm=(st.team==='ally'||st.team==='foe')?st.team:null, _bk=st.bulk||0, _tp=!!(OUTF&&OUTF.mark==='trooper'),
        _sx=(_BLD==='broad')?9.6:(_BLD==='curved'?6.7:8.4), _sw=(_BLD==='broad')?5.2:(_BLD==='curved'?3.6:4.6),
        _sh=(_BLD==='curved')?4.0:5.0, _cx=x+leanX, _t=ty-23.6, _s, _px, _hw=(13+_bk*3.2)/2;
    for(_s=-1;_s<=1;_s+=2){
      if(_bk>=2||_tp){
        if(!_tm) continue;
        _px=_tp?(_cx+_s*6.6):(_cx+_s*(_hw+0.6));
        wc.fillStyle=TEAMCOL[_tm]; wc.fillRect(_px-2.2,ty-22.2,4.4,1.6);
        continue;
      }
      _px=_cx+_s*_sx;
      wc.fillStyle=INK; rrF(_px-_sw/2-0.7,_t-0.7,_sw+1.4,_sh+1.4,2.2);
      wc.fillStyle=_tm?TEAMCOL[_tm]:cLo; rrF(_px-_sw/2,_t,_sw,_sh,1.8);   // no side: the coat in shadow, one flat tone
      if(_tm){ wc.fillStyle=TEAMHI[_tm]; wc.fillRect(_px-_sw/2+0.6,_t+0.3,_sw-1.2,1.0); }
    }
  })();
  // HEALING, ABOVE HER HEAD, v5.44, his note. A shrinking arc and the seconds
'@

SubRx @'
  wc.fillStyle='#2c333c'; wc.fillRect(2+ext,-1.6,_L,3.2);
  wc.fillStyle='#5c6773'; wc.fillRect(_L-1+ext,-1,_B,2);
'@ @'
  // v23.xx (gfxsil), HIS #24: the gun was a dark grey bar on a dark coat over dark ground, so what a body held did not read.
  // It is inked now, body and barrel, with a lit top edge, so the weapon is its own shape at a glance.
  wc.fillStyle=INK; wc.fillRect(1.2+ext,-2.4,_L+1.6,4.8); wc.fillRect(_L-1.8+ext,-1.8,_B+1.6,3.6);
  wc.fillStyle='#2c333c'; wc.fillRect(2+ext,-1.6,_L,3.2);
  wc.fillStyle='#5c6773'; wc.fillRect(_L-1+ext,-1,_B,2);
  wc.fillStyle='#8d99a6'; wc.fillRect(2+ext,-1.6,_L,0.8);
'@

SubRx @'
{hero:1,own:p,moving:!!p.moving,sprint:!!G.sprinting,ads:!!p.ads,hurt:p.hitFlash,
'@ @'
{hero:1,own:p,team:'ally',moving:!!p.moving,sprint:!!G.sprinting,ads:!!p.ads,hurt:p.hitFlash,
'@

SubRx @'
{hero:1,own:p,moving:!!p.moving,sprint:!!G.sprinting,ads:!!p.ads,hurt:0,bulk:armorById
'@ @'
{hero:1,own:p,team:'ally',moving:!!p.moving,sprint:!!G.sprinting,ads:!!p.ads,hurt:0,bulk:armorById
'@

SubRx @'
{own:e2,moving:!!e2.moving,sprint:e2.state==='extract',ads:e2.state==='chase',hurt:e2.hitT,bulk:e2.bulk||0,
'@ @'
{own:e2,team:'foe',moving:!!e2.moving,sprint:e2.state==='extract',ads:e2.state==='chase',hurt:e2.hitT,bulk:e2.bulk||0,
'@

SubRx @'
{hero:0,own:g,moving:!!g.mv,sprint:!!g.sp,ads:false,hurt:0,rl:0,bulk:0,
'@ @'
{hero:0,own:g,team:(NET.mode==='pvp')?'foe':'ally',moving:!!g.mv,sprint:!!g.sp,ads:false,hurt:0,rl:0,bulk:0,
'@

SubRx @'
var VER='24.36';
'@ @'
var VER='24.37';
'@

$pat = "(?m)^  now:'v24\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.37: Bodies read at a glance: shoulders in the team colour, blue for your side and red for pillagers, and an inked gun. Check 24.37 fails on v24.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
