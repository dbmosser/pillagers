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

if ($s.Contains("  {v:'18.19',what:")) { throw "check 18.19 is in the fixture already" }

SubRx @'
  {v:'18.18',what:
'@ @'
  {v:'18.19',what:'a controller takes an Undercroft trade offer with a window open: with the Stash screen up and an offer waiting, one Y press through pollPad marks the offer taken, and a held Y does not take a second one',
   run:function(){
     if(typeof pollPad!=='function'||typeof padMenu!=='function'||typeof netHubGiftKey!=='function') return 'SKIP: no pad menu or hub trade here';
     var NG=navigator.getGamepads, bad=[], hub=document.getElementById('hub'), was=hub&&hub.classList.contains('on'), hg0=NET.hg, pad, i, b, r;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     if(!hub) return 'SKIP: no Stash screen';
     function mk(y){ b=[]; for(i=0;i<17;i++) b.push({pressed:(i===3&&y),value:(i===3&&y)?1:0,touched:(i===3&&y)}); return {connected:true,id:'trade pad',index:0,mapping:'standard',timestamp:1,buttons:b,axes:[0,0,0,0]}; }
     try{
       hub.classList.add('on');
       NET.hg={in:{id:'q9',k:'bandage',from:1,t:Date.now()},out:null};
       pad=mk(false); navigator.getGamepads=function(){ return [pad]; };
       PAD.yMenuWas=false; pollPad();
       pad=mk(true); pollPad();
       if(NET.hg.in.yes!==1) bad.push('Y with the Stash screen open did not take the offer');
       NET.hg.in={id:'q10',k:'bandage',from:1,t:Date.now()};
       pollPad();
       if(NET.hg.in.yes===1) bad.push('a held Y took a second offer');
       pad=mk(false); pollPad(); pad=mk(true); pollPad();
       if(NET.hg.in.yes!==1) bad.push('a fresh Y press did not take the next offer');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ navigator.getGamepads=NG; NET.hg=hg0; PAD.yMenuWas=false; try{ padRelease(); }catch(_p){} if(!was) hub.classList.remove('on'); try{ padSetFocus(null); }catch(_f){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
