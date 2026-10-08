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

if ($s.Contains("  {v:'20.57',what:")) { throw "check 20.57 is in the fixture already" }

SubRx @'
  {v:'20.56',what:
'@ @'
  {v:'20.57',what:'the HP number fits inside its bar at any text size: at the largest text size its font is no taller than the 26 high bar holds',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawHUD!=='function') return 'SKIP: no HUD here';
     var bad=[], g, u0, got=null, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), of=ctx.fillText, px;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       u0=P.uiScale; P.uiScale=2;
       ctx.fillText=function(t,x,y){ if(String(t).indexOf('HP  ')===0) got={f:ctx.font,y:y}; return of.apply(this,arguments); };
       drawHUD();
       if(!got) return 'SKIP: the HP number was not drawn';
       px=parseFloat((/([\d.]+)px/.exec(got.f)||[0,0])[1]);
       if(!(px<=26*1.08+0.6)) bad.push('at the largest text size the HP number is '+px+'px tall in a bar 26 high');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       if(own) ctx.fillText=of; else delete ctx.fillText;
       if(u0===undefined) delete P.uiScale; else P.uiScale=u0;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
