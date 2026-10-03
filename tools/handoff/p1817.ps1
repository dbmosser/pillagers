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

# TRADING IS ON THE LEGENDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
['WORLD',[['E','search / call for extraction'],['X','search, even on the way out'],['M','map'],['H','cycle this list'],['P','pause'],['TAB','pause, or back out of a menu'],['O','order your hire']]],
'@ @'
['WORLD',[['E','search / call for extraction'],['X','search, even on the way out'],['M','map'],['H','cycle this list'],['P','pause'],['TAB','pause, or back out of a menu'],['O','order your hire']]],
  ['TEAM',[['T','offer or take a traded item'],['N','ping, twice for danger']]],   // v18.17: his note, trading was on no legend
'@

SubRx @'
  ['WORLD',[['X','search / open / call for extraction'],['Y','search in a ring'],['DPAD UP','ping (twice: danger); hold: map'],['MENU','pause']]]
'@ @'
  ['WORLD',[['X','search / open / call for extraction'],['Y','search in a ring'],['DPAD UP','ping (twice: danger); hold: map'],['MENU','pause']]],
  ['TEAM',[['Y','offer or take a traded item'],['LB + RB','ping, twice for danger']]]   // v18.17: his note, trading was on no legend
'@

SubRx @'
    var MN=(PAD&&PAD.on)?LEGEND_MINI_PAD:LEGEND_MINI,mi;
'@ @'
    var MN=((PAD&&PAD.on)?LEGEND_MINI_PAD:LEGEND_MINI).slice(),mi;
    if(typeof NET==='object'&&NET&&NET.on) MN.push([(PAD&&PAD.on)?'Y':'T','trade'],[(PAD&&PAD.on)?'LB + RB':'N','ping']);   // v18.17: his note, in a party the trade key is on the short list too
    var _mr=Math.ceil(MN.length/2);
'@

SubRx @'
    var COLW=LH(112),MROW=LH(10),MW=COLW*2+LH(24),MH=MROW*6+LH(16);   // v17.76: wide enough for TACTICAL BELT beside its key
'@ @'
    var COLW=LH(112),MROW=LH(10),MW=COLW*2+LH(24),MH=MROW*_mr+LH(16);   // v17.76: wide enough for TACTICAL BELT beside its key; v18.17: as many rows as the list has
'@

SubRx @'
    ctx.fillText('H  full list',mx,my+LH(7)+MROW*6+LH(3));
'@ @'
    ctx.fillText('H  full list',mx,my+LH(7)+MROW*_mr+LH(3));
'@

SubRx @'
        <div><kbd>RIGHT CLICK</kbd> all actions</div>
'@ @'
        <div><kbd>RIGHT CLICK</kbd> all actions</div>
        <div id="kb_trade" style="display:none"><kbd>RIGHT CLICK</kbd> offer to your teammate</div>
'@

SubRx @'
function refreshInv(){
'@ @'
function refreshInv(){
  try{ var _kt=document.getElementById('kb_trade'); if(_kt) _kt.style.display=(typeof netHubSeat==='function'&&netHubSeat()>=0)?'':'none'; }catch(_kte){}   // v18.17: the offer line shows while the windows are linked
'@

SubRx @'
  <div class="plist" id="partyroster" style="border:1px solid var(--steel-hi);display:none"></div>
'@ @'
  <div class="plist" id="partyroster" style="border:1px solid var(--steel-hi);display:none"></div>
  <div class="hint" id="partytrade" style="margin-top:8px">TRADING. Up top: open the backpack, pick the item and press T (Y on a controller); your teammate takes it with T or Y with their backpack closed. In the Undercroft: right-click a stash item and choose Offer; they take it with T, or Y on the floor.</div>
'@

SubRx @'
var VER='18.16';
'@ @'
var VER='18.17';
'@

$pat = "(?m)^  now:'v18\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.17: Trading is on every key legend now, the stash key bar says how to offer, and the Party window explains both ways to trade. Check 18.17 fails on v18.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
