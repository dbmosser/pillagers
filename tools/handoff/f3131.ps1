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

if ($s.Contains("  {v:'31.31',what:")) { throw "check 31.31 is in the fixture already" }

SubRx @'
  {v:'31.30',what:
'@ @'
  {v:'31.31',what:'the stash is a card with a 5 percent margin on every side (90 x 90 of the screen), and its X sits inside the card',
   run:function(){
     if(!(window.__hubEnter&&window.__showScreen)) return 'SKIP: this fixture cannot walk the Undercroft';
     var bad=[], h, r, tw=window.innerWidth, th=window.innerHeight, b, q;
     try{
       __topClear(); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       renderHub(); h=document.getElementById('hub'); h.classList.add('on');
       var cs=getComputedStyle(h), hb=h.getBoundingClientRect();
       r={left:parseFloat(cs.left),top:parseFloat(cs.top),right:tw-parseFloat(cs.right),bottom:th-parseFloat(cs.bottom)}; r.width=r.right-r.left;
       if(!(Math.abs(r.left-tw*0.05)<=3)) bad.push('the stash left margin is '+Math.round(r.left)+' px, not 5 percent ('+Math.round(tw*0.05)+')');
       if(!(Math.abs(tw-r.right-tw*0.05)<=3)) bad.push('the stash right margin is '+Math.round(tw-r.right)+' px, not 5 percent');
       if(!(Math.abs(r.top-th*0.05)<=3)) bad.push('the stash top margin is '+Math.round(r.top)+' px, not 5 percent ('+Math.round(th*0.05)+')');
       if(!(Math.abs(th-r.bottom-th*0.05)<=3)) bad.push('the stash bottom margin is '+Math.round(th-r.bottom)+' px, not 5 percent');
       b=document.getElementById('stashclose'); q=b?b.getBoundingClientRect():null;
       if(!q||!(q.width>8)) bad.push('the stash X has no box');
       else if(!(q.right<=hb.right+0.5&&q.left>hb.left+hb.width*0.8&&q.top>=hb.top-1)) bad.push('the stash X is not inside the card top right ('+Math.round(q.left)+','+Math.round(q.top)+','+Math.round(q.right)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ document.getElementById('hub').classList.remove('on'); __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'31.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
