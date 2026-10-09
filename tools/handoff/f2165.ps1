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

if ($s.Contains("  {v:'21.65',what:")) { throw "check 21.65 is in the fixture already" }

SubRx @'
  {v:'21.64',what:
'@ @'
  {v:'21.65',what:'the RECOVERING icon shows only while the regen really runs',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function'||typeof tickRegen!=='function') return 'SKIP: no HUD here';
     var bad=[], g, p, said=[], own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), of=ctx.fillText;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       p.hp=40; p.combatT=60; delete p.regenLive; g.t=Math.max(g.t||0,30);
       ctx.fillText=function(t){ said.push(String(t)); return of.apply(this,arguments); };
       drawHUD();
       if(said.some(function(t){ return t.indexOf('RECOVERING')>=0; })) bad.push('with no regen running the HUD still says RECOVERING');
       tickRegen(0.016); said=[]; drawHUD();
       if(!said.some(function(t){ return t.indexOf('RECOVERING')>=0; })) bad.push('with the regen running the HUD does not say RECOVERING');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(own) ctx.fillText=of; else delete ctx.fillText; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.64',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
