$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'19.70',what:")) { throw "check 19.70 is in the fixture already" }

SubRx @'
  {v:'19.69',what:
'@ @'
  {v:'19.70',what:'the stash speaks controller on a controller: with a pad connected the stash shows the pad row (A, Y, B) instead of DRAG and RIGHT CLICK, and without one the mouse row',
   run:function(){
     if(typeof pollPad!=='function') return 'SKIP: no controller poll here';
     var kb=document.getElementById('invkeybar'), bad=[], had=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), og=navigator.getGamepads, pb, pad, on0=PAD.on;
     if(!kb) return 'SKIP: no stash key row here';
     pad={id:'Xbox Wireless Controller (STANDARD GAMEPAD)',index:0,connected:true,mapping:'standard',timestamp:1,axes:[0,0,0,0],buttons:Array.apply(null,Array(17)).map(function(){ return {pressed:false,touched:false,value:0}; })};
     try{
       navigator.getGamepads=function(){ pad.timestamp++; return [pad,null,null,null]; };
       pollPad();
       pb=document.getElementById('invkeybarpad');
       if(getComputedStyle(kb).display!=='none') bad.push('with a pad on the stash still shows the mouse row');
       if(!pb||getComputedStyle(pb).display==='none') bad.push('with a pad on the stash shows no pad row');
       navigator.getGamepads=function(){ return [null,null,null,null]; };
       pollPad();
       if(getComputedStyle(kb).display==='none') bad.push('control: without a pad the mouse row is hidden');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(had) navigator.getGamepads=og; else delete navigator.getGamepads; try{ pollPad(); }catch(_p){} if(!on0){ PAD.on=false; } try{ document.body.classList.toggle('padon',!!PAD.on); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'19.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
