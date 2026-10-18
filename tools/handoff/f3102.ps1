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

if ($s.Contains("  {v:'31.02',what:")) { throw "check 31.02 is in the fixture already" }

SubRx @'
  {v:'31.01',what:
'@ @'
  {v:'31.02',what:'the shop and the stash close with an X in the top right corner of the card, not a CLOSE button at the bottom, and the credits readout sits left of it',
   run:function(){
     if(!(window.__hubEnter&&window.__showScreen)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], b, r, tr, tw, th, hb;
     function corner(el,what){
       var q=el.getBoundingClientRect();
       if(!(q.width>8&&q.height>8)) { bad.push(what+' has no box'); return null; }
       if(!(q.top<th*0.12)) bad.push(what+' sits at y '+Math.round(q.top)+', not in the top corner');
       if(!(q.right>tw*0.9)) bad.push(what+' sits at x '+Math.round(q.right)+', not at the right edge');
       if(Math.abs(q.width-q.height)>2) bad.push(what+' is '+Math.round(q.width)+' x '+Math.round(q.height)+', not square');
       return q; }
     try{
       __topClear(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       tw=window.innerWidth; th=window.innerHeight;
       try{ __station('term','KeyE'); UIM.step(600); }catch(_s){}
       hb=document.getElementById('stashclose'); if(!hb) return 'no stash close';
       if(!document.getElementById('hub').classList.contains('on')) return 'SKIP: the stash did not open';
       corner(hb,'the stash close');
       hb.click(); if(document.getElementById('hub').classList.contains('on')) bad.push('the stash X did not close the stash');
       openTrader('buy');
       b=document.getElementById('closetrader'); if(!b) return 'no shop close';
       r=corner(b,'the shop close');
       tr=document.getElementById('topright');
       if(r&&tr&&tr.innerHTML){ var t=tr.getBoundingClientRect(); if(t.width>0&&!(t.right<=r.left+1)) bad.push('the credits readout ends at x '+Math.round(t.right)+', over the X that starts at '+Math.round(r.left)); }
       b.click(); if(document.getElementById('tradermodal').classList.contains('on')) bad.push('the X did not close the shop');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'31.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
