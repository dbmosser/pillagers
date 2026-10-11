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

if ($s.Contains("  {v:'23.19',what:")) { throw "check 23.19 is in the fixture already" }

SubRx @'
  {v:'23.18',what:
'@ @'
  {v:'23.19',what:'the ARMOUR number never stands taller than its bar at a large text size',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function') return 'SKIP: no HUD here';
     var bad=[], g, p, seen=[], own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), of=ctx.fillText, us0=P.uiScale;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       P.uiScale=1.6; p.armor=40; G.bagOpen=false;
       ctx.fillText=function(t){ if(String(t).indexOf('ARMOUR')===0) seen.push(ctx.font); return of.apply(this,arguments); };
       drawHUD();
       if(!seen.length) return 'SKIP: the armour line was not drawn';
       var px=parseFloat((/([\d.]+)px/.exec(seen[0])||[0,0])[1]);
       if(!(px<=16*1.08+0.06)) bad.push('at text size 1.6 the ARMOUR number is '+px+' units tall over a 16 unit bar');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(own) ctx.fillText=of; else delete ctx.fillText; if(us0===undefined) delete P.uiScale; else P.uiScale=us0; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
