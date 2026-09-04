$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'10.51',what:'behind the terminal plinth the Undercroft shows the operator through the wall, and pinned against it he does not run in place',
'@ @'
  {v:'10.52',what:'the prompt over a container is drawn as a callout and the items-left count under the search bar as a label, both on screen',
   run:function(){
     var bad=[];
     if(!(window.__startRaid&&window.__frame&&window.__textTrace&&typeof drawHUD==='function')) return 'SKIP: this build cannot trace the HUD';
     if(!(W>0&&H>0)) return 'SKIP: the pane is 0x0';
     __startRaid({seed:4242,mapIx:0});
     if(!G||!G.containers||!G.containers.length) return 'no containers on the map';
     var ct=null;
     for(var i=0;i<G.containers.length;i++){ var c=G.containers[i]; if(c&&!c.opened&&c.loot&&c.loot.length>=1&&!c.fallen&&!c.dropped){ ct=c; break; } }
     if(!ct) return 'no unopened container with loot to stand on';
     var p=G.player, keep={x:p.x,y:p.y,near:G.nearContainer,srch:G.searching,st:G.searchT,time:ct.time};
     try{
       p.x=ct.x+12; p.y=ct.y+2; p.downed=false;
       __frame(0.016);
       // Frame A: standing at the crate, not searching: the prompt.
       G.nearContainer=ct; G.searching=null; G.searchT=0;
       var trA=__textTrace(function(){ drawHUD(); });
       var pr=null;
       for(i=0;i<trA.length;i++){ if(/^\[.*\] SEARCH /.test(trA[i].t)){ pr=trA[i]; break; } }
       // Frame B: searching it: the count under the bar.
       G.searching=ct; G.searchT=0.05; if(!(ct.time>0)) ct.time=2;
       var trB=__textTrace(function(){ drawHUD(); });
       var cn=null;
       for(i=0;i<trB.length;i++){ if(/ items? left$/.test(trB[i].t)){ cn=trB[i]; break; } }
       if(!pr) bad.push('no SEARCH prompt was drawn while standing at the crate');
       else {
         if(pr.px<21) bad.push('the prompt "'+pr.t+'" is drawn at '+pr.px.toFixed(1)+' px, smaller than a callout (23.4 here at 1080p; the label it was is 18.7)');
         if(pr.x<0||pr.x>W||pr.y<0||pr.y>H) bad.push('the prompt is off screen at '+pr.x.toFixed(0)+','+pr.y.toFixed(0));
       }
       if(!cn) bad.push('no items-left count was drawn while searching');
       else {
         if(cn.px<17) bad.push('the count "'+cn.t+'" is drawn at '+cn.px.toFixed(1)+' px, smaller than a label (18.7 here at 1080p; the micro it was is 15.6)');
         if(cn.x<0||cn.x>W||cn.y<0||cn.y>H) bad.push('the count is off screen at '+cn.x.toFixed(0)+','+cn.y.toFixed(0));
       }
     } finally {
       p.x=keep.x; p.y=keep.y; G.nearContainer=keep.near; G.searching=keep.srch; G.searchT=keep.st; ct.time=keep.time;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'10.51',what:'behind the terminal plinth the Undercroft shows the operator through the wall, and pinned against it he does not run in place',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
