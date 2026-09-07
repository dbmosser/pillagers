$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# FROM THE 2026-09-06 READ-ONLY IN-RAID AUDIT (P2 WRONG STATE, verified by
# reading at v12.20): cycleThrow, which Q calls and which the trigger falls
# back to when the selected throwable has run out, turned only G.tsel, the
# selector startCook and doThrow read. Every belt cell reads the highlight,
# G.hot. So after a Q the belt lit one throwable and the trigger cooked
# another. The belt keys already point both at the same cell (v11.60); Q
# and the fallback now do the same: the highlight moves to the belt cell
# holding the throwable that was just made ready. The belt always carries
# the three throw cells (hotbarSlots derives one per THROWKEYS entry), so
# the cell is always there to move to.
SubRx @'
function cycleThrow(){
  for(var i=1;i<=3;i++){
    var n=(G.tsel+i)%3;
    if(G.pouch[THROWKEYS[n]]>0){ G.tsel=n; say(ITEMS[THROWKEYS[n]].name+' ready'); return; }
  }
  say('No throwables');
}
'@ @'
function cycleThrow(){
  for(var i=1;i<=3;i++){
    var n=(G.tsel+i)%3;
    if(G.pouch[THROWKEYS[n]]>0){
      G.tsel=n;
      // v12.26: THE BELT SHOWS WHAT THE TRIGGER WILL THROW. This turned only the
      // selector the trigger reads, while every belt cell reads the highlight, so
      // after a Q the belt lit one throwable and the trigger cooked another. The
      // highlight moves to the cell holding the one now ready (2026-09-06 in-raid
      // audit). Set directly: setHot on a throw cell throws it.
      var _sl=hotbarSlots();
      for(var _hi=0;_hi<_sl.length;_hi++){ if(_sl[_hi]&&_sl[_hi].k==='throw:'+THROWKEYS[n]){ G.hot=_hi; break; } }
      say(ITEMS[THROWKEYS[n]].name+' ready'); return;
    }
  }
  say('No throwables');
}
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'Q MOVES THE BELT HIGHLIGHT TO THE GRENADE IT MAKES READY, so the belt always shows what the trigger will throw.',
'@

# STAMPS.
SubRx @'
var VER='12.25';
'@ @'
var VER='12.26';
'@
SubRx @'
var WHATSNEW_VER='12.25';
'@ @'
var WHATSNEW_VER='12.26';
'@
$cnt=([regex]::Matches($s,"now:'v12\.25:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.25 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.25:[^']*'",{ param($m) "now:'v12.26: in-raid audit: Q turned only the hidden selector the trigger reads while the belt cells read the highlight, so after a Q the belt lit one throwable and the trigger cooked another. The highlight now follows the selector to the cell holding the throwable made ready. Check 12.26 selects the smoke on the belt, presses Q, and requires the selector on the frag, the highlight on the frag cell and a cook that produces a frag; with an empty pouch Q says No throwables and moves nothing; fails on v12.25.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
