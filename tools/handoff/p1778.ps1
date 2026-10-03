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

# A PLAYSTATION PAD IS NAMED IN ITS OWN WORDS, AND THE PAD LEGEND MATCHES HIS LAYOUT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function keyLabel(code,fallback){
'@ @'
// v17.78, AAA CHECK (2026-10-02): A PLAYSTATION PAD IS NAMED IN ITS OWN WORDS. Every prompt named Xbox buttons (A, B, X, Y, LB,
// RB, LT, RT, VIEW, MENU) whatever pad was plugged in. The pad's id names its make (Sony's vendor code, PlayStation, DualShock,
// DualSense); on one of those every prompt says CROSS, CIRCLE, SQUARE, TRIANGLE, L1, R1, L2, R2, SHARE and OPTIONS instead.
// padB turns one string; keyLabel and the legends go through it, and the few prompts written out by hand do too. The window
// that hands a pad over carries its make with it (netPadSend b), so player 2 is named right as well.
var PAD_PS={A:'CROSS',B:'CIRCLE',X:'SQUARE',Y:'TRIANGLE',LB:'L1',RB:'R1',LT:'L2',RT:'R2',LS:'L3',RS:'R3',VIEW:'SHARE',MENU:'OPTIONS',BACK:'SHARE'};
function padBrandOf(gp){ var id=(gp&&gp.id)?String(gp.id):''; return /054c|playstation|dualshock|dualsense/i.test(id)?'ps':'xbox'; }
function padB(s){ if(typeof s!=='string'||typeof PAD==='undefined'||!PAD||PAD.brand!=='ps') return s; return s.replace(/\b(LB|RB|LT|RT|LS|RS|VIEW|MENU|BACK|A|B|X|Y)\b/g,function(m){ return PAD_PS[m]||m; }); }
function keyLabel(code,fallback){
'@

SubRx @'
    if(state==='hub'&&PADLABEL_HUB[code]) return PADLABEL_HUB[code];
'@ @'
    if(state==='hub'&&PADLABEL_HUB[code]) return padB(PADLABEL_HUB[code]);
'@

SubRx @'
    if(PADLABEL[code]) return PADLABEL[code];
'@ @'
    if(PADLABEL[code]) return padB(PADLABEL[code]);
'@

SubRx @'
  RUMBLE.gp=(gp&&gp.vibrationActuator&&typeof gp.vibrationActuator.playEffect==='function')?gp:null;   // v17.37: the pad this window plays, for padRumble
'@ @'
  RUMBLE.gp=(gp&&gp.vibrationActuator&&typeof gp.vibrationActuator.playEffect==='function')?gp:null;   // v17.37: the pad this window plays, for padRumble
  PAD.brand=padBrandOf(gp);   // v17.78: the pad make, for the prompts
'@

SubRx @'
      ctx.fillText(MN[mi][0],cx0,cy0);
'@ @'
      ctx.fillText(padB(MN[mi][0]),cx0,cy0);
'@

SubRx @'
var LEGEND_MINI_PAD=[
  ['L STICK','move'],['LS','sprint'],
  ['RS','crouch'],['B','roll'],
  ['A','fire'],['LT / RT','reach'],
  ['X','search'],['Y','reload'],
  ['LB / RB','tactical belt'],['D-RIGHT','use it'],
  ['VIEW','backpack'],['D-DOWN','revive'],
  ['D-UP','ping, hold: map'],['MENU','pause']
];
'@ @'
var LEGEND_MINI_PAD=[
  ['L STICK','move'],['LS','sprint'],
  ['B','crouch'],['A','roll'],
  ['RT','fire / use'],['LT / RS','focus aim'],
  ['X','reload'],['D-L / D-R','aim distance'],
  ['LB / RB','tactical belt'],['VIEW','backpack'],
  ['D-UP','ping, hold: map'],['MENU','pause']
];   // v17.78: his layout of v16.72 (A roll, B crouch, RT fire, X reload); it had said B roll, A fire, Y reload
'@

SubRx @'
if(padOn()) return 'LB or RB to your gun.';
'@ @'
if(padOn()) return padB('LB or RB to your gun.');
'@

SubRx @'
padOn()?'VIEW  BACKPACK':'B / I  BACKPACK'
'@ @'
padOn()?padB('VIEW  BACKPACK'):'B / I  BACKPACK'
'@

SubRx @'
(padOn()?'[D-PAD] choose  [A] take  ':'')
'@ @'
(padOn()?padB('[D-PAD] choose  [A] take  '):'')
'@

SubRx @'
(state==='hub')?'VIEW to close':'A pick up or place   B close'
'@ @'
(state==='hub')?padB('VIEW to close'):padB('A pick up or place   B close')
'@

SubRx @'
  if(state!=='hub'&&typeof NET==='object'&&NET&&NET.on){ _bo=((PAD&&PAD.on)?'Y':'T')+' offer to teammate   '; _bh=_bo+_bh; if(ctx.measureText(_bh).width>PW-LH(130)) _bh=((PAD&&PAD.on)?'Y':'T')+' offer   '+_bh.slice(_bo.length); }
'@ @'
  if(state!=='hub'&&typeof NET==='object'&&NET&&NET.on){ _bo=((PAD&&PAD.on)?padB('Y'):'T')+' offer to teammate   '; _bh=_bo+_bh; if(ctx.measureText(_bh).width>PW-LH(130)) _bh=((PAD&&PAD.on)?padB('Y'):'T')+' offer   '+_bh.slice(_bo.length); }
'@

SubRx @'
T or Y to take it.  '+Math.ceil(t)+'s'
'@ @'
T or '+padB('Y')+' to take it.  '+Math.ceil(t)+'s'
'@

SubRx @'
'. Press T or Y to take it.'
'@ @'
'. Press T or '+padB('Y')+' to take it.'
'@

SubRx @'
at:netPadIxOk(at),p:p,v:v,a:a})) return false;
'@ @'
at:netPadIxOk(at),p:p,v:v,a:a,b:padBrandOf(g)})) return false;
'@

SubRx @'
id:'controller handed over by the other window',mapping:'standard'
'@ @'
id:((m.b==='ps')?'playstation ':'')+'controller handed over by the other window',mapping:'standard'
'@

SubRx @'
var VER='17.77';
'@ @'
var VER='17.78';
'@

$pat = "(?m)^  now:'v17\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.78: A PlayStation controller is now named in its own words (CROSS, CIRCLE, SQUARE, TRIANGLE, L1, R1...), and the short pad legend matches the real layout. Check 17.78 fails on v17.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
