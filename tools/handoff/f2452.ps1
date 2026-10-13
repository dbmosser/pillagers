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

if ($s.Contains("  {v:'24.52',what:")) { throw "check 24.52 is in the fixture already" }

SubRx @'
  {v:'24.51',what:
'@ @'
  {v:'24.52',what:'his #50 and #35 (UI redesign ui5q1n, from the AAA judge of the raid HUD shot): in a raid the belt caption draws its FIRE key as a keycap (hudKey), as every world prompt does, and still draws the caption line',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     if(typeof hudKey!=='function') return 'SKIP: no keycaps in this build';
     var bad=[], g, keys0=[], oK=hudKey, seen=[], real=CanvasRenderingContext2D.prototype.fillText, line;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['medkit','bandage'],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={};
       hudKey=function(l){ keys0.push(String(l)); return oK.apply(this,arguments); };
       CanvasRenderingContext2D.prototype.fillText=function(t){ seen.push(String(t)); return real.apply(this,arguments); };
       try{ __frame(0.016); }finally{ CanvasRenderingContext2D.prototype.fillText=real; hudKey=oK; }
       line=seen.filter(function(s){ return s.indexOf('] u'+'se')>=0; })[0];
       if(!line) return 'SKIP: no belt caption was drawn this frame';
       if(keys0.indexOf('FI'+'RE')<0) bad.push('the belt caption draws [FIRE] as a bracketed word, not a keycap ('+keys0.join(',')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ hudKey=oK; CanvasRenderingContext2D.prototype.fillText=real; keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
