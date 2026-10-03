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

if ($s.Contains("  {v:'18.24',what:")) { throw "check 18.24 is in the fixture already" }

SubRx @'
  {v:'18.23',what:
'@ @'
  {v:'18.24',what:'a controller opens the item menu: with the Stash screen up and the pad highlight on a stash cell, one Y press through pollPad opens the item menu at that cell',
   run:function(){
     if(typeof pollPad!=='function'||typeof padMenu!=='function'||typeof refreshInv!=='function') return 'SKIP: no pad menu here';
     var NG=navigator.getGamepads, bad=[], hub=document.getElementById('hub'), was=hub&&hub.classList.contains('on'), st0=P.stash.slice(), hg0=NET.hg, pad, i, b, cell;
     if(typeof NG!=='function') return 'SKIP: this browser has no pad interface to fake';
     if(!hub) return 'SKIP: no Stash screen';
     function mk(y){ b=[]; for(i=0;i<17;i++) b.push({pressed:(i===3&&y),value:(i===3&&y)?1:0,touched:(i===3&&y)}); return {connected:true,id:'menu pad',index:0,mapping:'standard',timestamp:1,buttons:b,axes:[0,0,0,0]}; }
     try{
       NET.hg=null; P.stash=['bandage']; hub.classList.add('on'); try{ renderHub(); }catch(_rh){} refreshInv();
       cell=document.querySelector('#stashgrid .cell'); if(!cell) return 'SKIP: no stash cell to highlight';
       padSetFocus(cell);
       pad=mk(false); navigator.getGamepads=function(){ return [pad]; }; PAD.yMenuWas=false; pollPad();
       pad=mk(true); pollPad();
       if(!document.querySelector('.imenu')) bad.push('Y on a highlighted stash cell opened no item menu');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ navigator.getGamepads=NG; try{ closeItemMenu(); }catch(_c){} NET.hg=hg0; P.stash=st0; try{ saveProfile(); }catch(_s){} try{ refreshInv(); }catch(_r){} PAD.yMenuWas=false; try{ padRelease(); }catch(_p){} try{ padSetFocus(null); }catch(_f){} if(!was) hub.classList.remove('on'); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
