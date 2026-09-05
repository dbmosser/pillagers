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

# Richer samples, every 5 seconds: the waypoint the bot is steering at, its
# slide and stall timers, its goal kind and what it is standing next to.
SubRx @'
      samples.push([Math.round(G.t),Math.round(p.x),Math.round(p.y),Math.round(dist(p,{x:lx,y:ly})),inB(p),p.path?p.path.length:0,p.pathFail?1:0,Math.round(p.hp),+bagWeight().toFixed(0)]);
      lx=p.x; ly=p.y;
'@ @'
      var wp=(p.path&&p.path[p.pathI])?[Math.round(p.path[p.pathI].x),Math.round(p.path[p.pathI].y)]:null;
      var gk=p.goal?((p.goal.kind||p.goal.type||'goal')+'@'+Math.round(p.goal.x)+','+Math.round(p.goal.y)):'-';
      samples.push([Math.round(G.t),Math.round(p.x),Math.round(p.y),Math.round(dist(p,{x:lx,y:ly})),inB(p),p.path?p.path.length:0,p.pathFail?1:0,Math.round(p.hp),+bagWeight().toFixed(0),p.pathI|0,wp,+(p.slideT||0).toFixed(1),+(p.stallT||0).toFixed(1),gk,+(p.goalT||0).toFixed(0),+(p.noRouteT||0).toFixed(0)]);
      lx=p.x; ly=p.y;
'@
SubRx @'
      next+=10;
      var p=G.player;
      var wp=
'@ @'
      next+=5;
      var p=G.player;
      var wp=
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
