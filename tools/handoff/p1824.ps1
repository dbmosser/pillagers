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

# A CONTROLLER OPENS THE ITEM MENU (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(md&&_yNow&&!PAD.yMenuWas&&typeof netHubGiftKey==='function'&&typeof NET==='object'&&NET&&NET.hg&&NET.hg.in&&!NET.hg.in.yes){ try{ netHubGiftKey(); }catch(_yg){} }
  PAD.yMenuWas=_yNow;
'@ @'
  if(md&&_yNow&&!PAD.yMenuWas&&typeof netHubGiftKey==='function'&&typeof NET==='object'&&NET&&NET.hg&&NET.hg.in&&!NET.hg.in.yes){ try{ netHubGiftKey(); }catch(_yg){} }
  // v18.24, FROM THE TRADE AUDIT (2026-10-03): A CONTROLLER OPENS THE ITEM MENU. Every cell's menu (Equip, Offer to, keys, junk)
  // opened on a right-click only, so a controller player could never offer from the stash. With nothing waiting, Y on the
  // highlighted cell opens that same menu at the cell, as a right-click there would; the menu is already a pad panel.
  else if(md&&_yNow&&!PAD.yMenuWas&&PAD.focus&&PAD.focus.classList&&PAD.focus.classList.contains('cell')&&!document.querySelector('.imenu')){
    try{ var _cr=PAD.focus.getBoundingClientRect(); PAD.focus.dispatchEvent(new MouseEvent('contextmenu',{bubbles:true,cancelable:true,clientX:_cr.left+_cr.width/2,clientY:_cr.top+_cr.height/2})); }catch(_cm){}
  }
  PAD.yMenuWas=_yNow;
'@

SubRx @'
        <div id="kb_trade" style="display:none"><kbd>RIGHT CLICK</kbd> offer to your teammate</div>
'@ @'
        <div id="kb_trade" style="display:none"><kbd>RIGHT CLICK</kbd> or <kbd>Y</kbd> offer to your teammate</div>
'@

SubRx @'
var VER='18.23';
'@ @'
var VER='18.24';
'@

$pat = "(?m)^  now:'v18\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.24: On a controller, Y on a highlighted item opens its menu, so player 2 can offer, equip, bind and junk from the stash too. Check 18.24 fails on v18.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
