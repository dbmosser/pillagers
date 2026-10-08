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

# CARD WINDOWS FIT WHAT THEY HOLD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #termsmodal::before{ inset:50% auto auto 50%; width:min(1180px,calc(100% - 28px)); height:min(600px,calc(100% - 28px));
'@ @'
  #termsmodal::before{ inset:50% auto auto 50%; width:min(1180px,calc(100% - 28px)); height:min(var(--cfh,600px),calc(100% - 28px));
'@

SubRx @'
  #gamblemodal::before{ inset:50% auto auto 50%; width:min(1180px,calc(100% - 28px)); height:min(620px,calc(100% - 28px));
'@ @'
  #gamblemodal::before{ inset:50% auto auto 50%; width:min(1180px,calc(100% - 28px)); height:min(var(--cfh,620px),calc(100% - 28px));
'@

SubRx @'
  #barmodal::before{ inset:50% auto auto 50%; width:min(1180px,calc(100% - 28px)); height:min(640px,calc(100% - 28px));
'@ @'
  #barmodal::before{ inset:50% auto auto 50%; width:min(1180px,calc(100% - 28px)); height:min(var(--cfh,640px),calc(100% - 28px));
'@

SubRx @'
  #partymodal::before{ inset:50% auto auto 50%; width:min(1180px,calc(100% - 28px)); height:min(760px,calc(100% - 150px));
'@ @'
  #partymodal::before{ inset:50% auto auto 50%; width:min(1180px,calc(100% - 28px)); height:min(var(--cfh,760px),calc(100% - 150px));
'@

SubRx @'
    m.classList.remove('on');
  }
  el.classList.add('on');
'@ @'
    m.classList.remove('on');
  }
  el.classList.add('on');
  try{ cardFrameFit(el); }catch(_cf){}   // v20.18: a card window's frame fits what it holds
'@

SubRx @'
function openModal(id){
'@ @'
// v20.18, seen on the 4K Last Pour screenshot (2026-10-08): the centred card windows (TERMS, the gambler, the bar, PARTY) drew a
// frame of a fixed height, so the bar's two drinks sat in a frame 640 tall with empty bands above and below. The frame now fits
// what the window holds (never taller than before), and follows it when the content changes while it is open (a gamble, a join).
var CARDFIT={termsmodal:600,gamblemodal:620,barmodal:640,partymodal:760};
function cardFrameFit(el){
  if(!el||!CARDFIT[el.id]) return false;
  var i, c, t=1e9, b=-1e9;
  if(!el._cfObs&&typeof MutationObserver==='function'){ el._cfObs=new MutationObserver(function(){ if(el.classList.contains('on')&&!el._cfRaf){ el._cfRaf=requestAnimationFrame(function(){ el._cfRaf=0; cardFrameFit(el); }); } }); el._cfObs.observe(el,{childList:true,subtree:true,characterData:true}); }
  if(!el.offsetHeight) return false;
  for(i=0;i<el.children.length;i++){ c=el.children[i]; if(c.offsetHeight>0){ t=Math.min(t,c.offsetTop); b=Math.max(b,c.offsetTop+c.offsetHeight); } }
  if(!(b>t)) return false;
  el.style.setProperty('--cfh',Math.min(CARDFIT[el.id],Math.max(320,Math.ceil(b-t)+112))+'px');
  return true;
}
function openModal(id){
'@

SubRx @'
var VER='20.17';
'@ @'
var VER='20.18';
'@

$pat = "(?m)^  now:'v20\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.18: The bar, gambler, TERMS and PARTY windows fit their contents instead of floating in a big empty frame. Check 20.18 fails on v20.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
