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

if ($s.Contains("  {v:'21.55',what:")) { throw "check 21.55 is in the fixture already" }

SubRx @'
  {v:'21.54',what:
'@ @'
  {v:'21.55',what:'the CURRENT PILLAGERS board ends just under its last name, with no empty row',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof drawRaiderBoard!=='function'||typeof hudPanel!=='function') return 'SKIP: no board here';
     var bad=[], g, panels=[], ys=[], oP=hudPanel, own=Object.prototype.hasOwnProperty.call(ctx,'fillText'), of=ctx.fillText, P0, last;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       hudPanel=function(x,y,w,h){ panels.push({x:x,y:y,w:w,h:h}); return oP.apply(this,arguments); };
       ctx.fillText=function(t,x,y){ ys.push(y); return of.apply(this,arguments); };
       drawRaiderBoard();
       if(!panels.length||ys.length<3) return 'SKIP: staging: the board drew too little';
       P0=panels[0]; last=Math.max.apply(null,ys.filter(function(y){ return y>P0.y&&y<P0.y+P0.h+40; }));
       if(P0.y+P0.h-last>LH(8)) bad.push('the board ends '+Math.round(P0.y+P0.h-last)+' px under its last name, a full empty row');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ hudPanel=oP; if(own) ctx.fillText=of; else delete ctx.fillText; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'21.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
