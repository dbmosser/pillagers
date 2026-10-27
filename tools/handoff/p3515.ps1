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

# FOG OF WAR HIDES THE REST OF LIVE ACTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(th.burstEcho) continue;   // an echo is a pending gunshot, not a grenade in the air
'@ @'
    if(th.burstEcho) continue;   // an echo is a pending gunshot, not a grenade in the air
    if(!fowLive(th.x,th.y)) continue;   // v28.xx (cw-cx-fowlive-rest): his 10-27 order, no live action out of sight
'@

SubRx @'
    var sm=G.smokes[i];
'@ @'
    var sm=G.smokes[i];
    if(!fowLive(sm.x,sm.y)) continue;   // v28.xx (cw-cx-fowlive-rest): lingering smoke is live action too
'@

SubRx @'
    if(!(f>=0&&f<1)){ G.deathAnims.splice(i,1); continue; }
'@ @'
    if(!(f>=0&&f<1)){ G.deathAnims.splice(i,1); continue; }
    if(!fowLive(a.x,a.y)) continue;   // v28.xx (cw-cx-fowlive-rest): gate both kinds of fall after expiry cleanup
'@

SubRx @'
      a=G.arcs[i]; a.t+=dt; if(a.t>=a.life){ G.arcs.splice(i,1); continue; }
'@ @'
      a=G.arcs[i]; a.t+=dt; if(a.t>=a.life){ G.arcs.splice(i,1); continue; }
      if(!fowLive(a.x1,a.y1)||!fowLive(a.x2,a.y2)) continue;   // v28.xx (cw-cx-fowlive-rest): neither end of a live bolt may reveal an unseen body
'@

SubRx @'
    if(!e.seen) continue;   // v28.xx (cw-elemseen), job 127 pictures: in sight only, like the body (VIS). Flames, arcs, ice and their glow drew through walls and fog for any burning, shocked or frozen body
'@ @'
    if(!e.seen) continue;   // v28.xx (cw-elemseen), job 127 pictures: in sight only, like the body (VIS). Flames, arcs, ice and their glow drew through walls and fog for any burning, shocked or frozen body
    if(!fowLive(e.x,e.y)) continue;   // v28.xx (cw-cx-fowlive-rest): flames, shock, frost and acid also obey current fog sight
'@

SubRx @'
    if(!GFXDMG_KINDS[e.kind]) continue;
'@ @'
    if(!GFXDMG_KINDS[e.kind]) continue;
    if(!fowLive(e.x,e.y)) continue;   // v28.xx (cw-cx-fowlive-rest): damaged machine smoke and sparks stay with the visible body
'@

SubRx @'
  var shHi=inb?(.30+.34*urg):.14, shPu=inb?(.10*Math.sin(G.t*(5+9*urg))):(.06*Math.sin(G.t*2.4));
  var shW=inb?(7+9*urg):7;
  var shft=wc.createLinearGradient(0,az.y-150,0,az.y);
  shft.addColorStop(0,'rgba(53,214,200,0)');
  shft.addColorStop(1,'rgba(53,214,200,'+Math.max(0,shHi+shPu)+')');
  wc.fillStyle=shft; wc.fillRect(az.x-shW,az.y-150,shW*2,150);
'@ @'
  if(fowLive(az.x,az.y)){   // v28.xx (cw-cx-fowlive-rest): the pulsing extract shaft is live action; the ground marker stays
  var shHi=inb?(.30+.34*urg):.14, shPu=inb?(.10*Math.sin(G.t*(5+9*urg))):(.06*Math.sin(G.t*2.4));
  var shW=inb?(7+9*urg):7;
  var shft=wc.createLinearGradient(0,az.y-150,0,az.y);
  shft.addColorStop(0,'rgba(53,214,200,0)');
  shft.addColorStop(1,'rgba(53,214,200,'+Math.max(0,shHi+shPu)+')');
  wc.fillStyle=shft; wc.fillRect(az.x-shW,az.y-150,shW*2,150);
  }
'@

SubRx @'
var VER='35.14';
'@ @'
var VER='35.15';
'@

$pat = "(?m)^  now:'v35\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.15: fog of war hides grenades, smoke, falls and damage effects out of sight. Check 35.15 fails on v35.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
