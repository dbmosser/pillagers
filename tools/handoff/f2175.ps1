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

if ($s.Contains("  {v:'21.75',what:")) { throw "check 21.75 is in the fixture already" }

SubRx @'
  {v:'21.74',what:
'@ @'
  {v:'21.75',what:'his note: the gun card never says STOWED over the gun in your hands; the other gun reads OTHER GUN and Bare Hands gets no line',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function') return 'SKIP: no HUD here';
     var bad=[], g, p, said=[], own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), of=ctx.fillText, sec0, sa0;
     function drew(){ said=[]; drawHUD(); return said; }
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g||g.over) return 'SKIP: no live raid';
       sec0=p.sec; sa0=p.secAmmo; G.bagOpen=false;
       ctx.fillText=function(t){ said.push(String(t)); return of.apply(this,arguments); };
       p.sec=Object.assign({},WEAPONS.fists); p.secAmmo=0;
       drew().forEach(function(t){ if(/STOWED/.test(t)) bad.push('with Bare Hands in the other slot the card says '+t); if(/OTHER GUN/.test(t)) bad.push('Bare Hands is listed as the other gun'); });
       p.sec=Object.assign({},WEAPONS.pistol); p.secAmmo=7;
       var s2=drew();
       if(s2.some(function(t){ return /STOWED/.test(t); })) bad.push('the card still says STOWED');
       if(!s2.some(function(t){ return t.indexOf('OTHER GUN  '+WEAPONS.pistol.name+'  7')===0; })) bad.push('the other gun is not listed as OTHER GUN with its rounds');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ if(own) ctx.fillText=of; else delete ctx.fillText; try{ if(p){ p.sec=sec0; p.secAmmo=sa0; } var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
