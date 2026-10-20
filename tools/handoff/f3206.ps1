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

if ($s.Contains("  {v:'32.06',what:")) { throw "check 32.06 is in the fixture already" }

SubRx @'
  {v:'32.05',what:
'@ @'
  {v:'32.06',what:'under 32 health the red pulse is a screen-edge vignette: the middle stays clear and the corners go red',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function') return 'SKIP: no hud here';
     var bad=[], g, hp0, mx0;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       hp0=g.player.hp; g.player.hp=18; g.player.downed=false; g.player.hitFlash=0;
       mx0=mouse.x; mouse.x=W*.8; mouse.y=H*.2;
       drawHUD();
       var k=ctx.canvas.width/W, mid=ctx.getImageData(Math.round(W*.5*k),Math.round(H*.5*k),1,1).data, cor=ctx.getImageData(Math.round(8*k),Math.round(8*k),1,1).data;
       if(mid[3]>12) bad.push('the middle of the screen is washed red (alpha '+mid[3]+')');
       if(!(cor[3]>=50&&cor[0]>cor[1]*3)) bad.push('the corner is not red (rgba '+cor[0]+','+cor[1]+','+cor[2]+','+cor[3]+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2){ g2.player.hp=hp0; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } mouse.x=mx0; }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'32.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
