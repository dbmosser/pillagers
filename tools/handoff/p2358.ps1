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

# THE TITLE ALWAYS FITS THE SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _ti=document.getElementById('title');
  if(_ti){
    var _want=menuScale(), _col=_ti.querySelector('.titlecol');
    if(_col){
      _ti.style.zoom=1;
      var _nat=_col.scrollHeight, _room=(window.innerHeight||1080)*0.985;
      if(_nat>0&&_nat*_want>_room) _want=Math.max(0.7,_room/_nat);
    }
    // v10.77, his note that it has to be playable at 1080p, 1440p and 4K. The
    // css cap cannot know the zoom, and the zoom is what decides how much of the
    // monitor a css width paints, so the cap is computed from the zoom this
    // function has just settled on: 80 percent of the screen, whatever the
    // screen is. The 820 floor is the same one the stylesheet carries.
    if(_col) _col.style.maxWidth=Math.max(820,Math.round((window.innerWidth||1920)*0.80/_want))+'px';
    _ti.style.zoom=_want;
  }
}
'@ @'
  titleFit();   // v23.xx: the measuring moved into titleFit, which also runs when the title shows and when its content grows
}
// v9.53, his report: "when I enter the title screen, I don't want to have to scroll down to see the bottom. I am testing in 4k."
// The zoom is asked for, measured against the room there is, and reduced until it fits.
// v23.xx (2026-10-12): IT FITS EVERY TIME, NOT ONLY WHEN THE ZOOM CHANGES. It was measured only inside applyMenuZoom: if the title was
// hidden then, its column measured 0 and kept the full zoom, and nothing measured again when the title came up or when its content grew
// (the arcade rows, a longer saves list), so at a large menu zoom the bottom rows ran off the screen (98 px at 1080p in the corpus).
// It is now measured while hidden too (shown for the one synchronous measure, invisible, so nothing paints), again whenever the title
// comes on and whenever its column changes size, and the floor is 0.45 instead of 0.7 so even a very large menu zoom fits.
function titleFit(){
  var ti=document.getElementById('title'), col=ti&&ti.querySelector('.titlecol'), want, hid, vis0, nat, room;
  if(!ti||!col||titleFit.busy) return;
  titleFit.busy=1;
  try{
    want=menuScale(); hid=!ti.classList.contains('on');
    if(hid){ vis0=ti.style.visibility; ti.style.visibility='hidden'; ti.classList.add('on'); }
    ti.style.zoom=1;
    nat=col.scrollHeight; room=(window.innerHeight||1080)*0.985;
    if(nat>0&&nat*want>room) want=Math.max(0.45,room/nat);
    // v10.77: the width cap is computed from the zoom just settled on, 80 percent of the screen; the 820 floor is the stylesheet one.
    col.style.maxWidth=Math.max(820,Math.round((window.innerWidth||1920)*0.80/want))+'px';
    ti.style.zoom=want;
    if(hid){ ti.classList.remove('on'); ti.style.visibility=vis0||''; }
  }catch(_tf){}
  titleFit.busy=0;
}
(function(){
  var ti=document.getElementById('title'), col=ti&&ti.querySelector('.titlecol');
  if(!ti) return;
  try{ new MutationObserver(function(){ if(ti.classList.contains('on')) titleFit(); }).observe(ti,{attributes:true,attributeFilter:['class']}); }catch(_mo){}
  try{ if(col&&typeof ResizeObserver==='function') new ResizeObserver(function(){ if(ti.classList.contains('on')) titleFit(); }).observe(col); }catch(_ro){}
})();
'@

SubRx @'
var VER='23.57';
'@ @'
var VER='23.58';
'@

$pat = "(?m)^  now:'v23\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.58: The title screen now always fits the screen, whatever the menu zoom. Check 23.58 fails on v23.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
