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

if ($s.Contains("  {v:'19.59',what:")) { throw "check 19.59 is in the fixture already" }

SubRx @'
  {v:'19.58',what:
'@ @'
  {v:'19.59',what:'a board dragged low still names a rival: with the pillager board dragged to the lower half and pillagers down, it shows YOU and at least one other name',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawRaiderBoard!=='function') return 'SKIP: no raider board here';
     var bad=[], g, oFT=ctx.fillText, texts=[], h0=P.hud?JSON.parse(JSON.stringify(P.hud)):undefined, names=0, i, t, more=false;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.ents.length=0; g.bagOpen=false; g.mapOpen=false;
       P.hud=P.hud||{}; P.hud.raiders={dx:0,dy:Math.round(H*0.5),c:0};
       ctx.fillText=function(s){ texts.push(String(s)); return oFT.apply(this,arguments); };
       ctx.save(); try{ drawRaiderBoard(); } finally { ctx.restore(); }
       for(i=0;i<texts.length;i++){ t=texts[i]; if(/^\+\d+ more/.test(t)) more=true; if(t==='YOU'||/^CURRENT /.test(t)||/^\+\d/.test(t)||/ out /.test(t)||/\$|^\[|DEAD|EXTRACTED|DOWN|^\s*$/.test(t)) continue; names++; }
       if(!more) return 'SKIP: every pillager fits on the board even dragged low';
       if(names<1) bad.push('the board dragged low shows only YOU and a count, no rival named');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; if(h0===undefined) delete P.hud; else P.hud=h0; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
