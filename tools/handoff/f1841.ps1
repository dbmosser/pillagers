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

if ($s.Contains("  {v:'18.41',what:")) { throw "check 18.41 is in the fixture already" }

SubRx @'
  {v:'18.40',what:
'@ @'
  {v:'18.41',what:'the posture chip is a HUD panel: a raid HUD frame draws a small panel at the left edge just above the stamina bar, behind the STANDING word',
   run:function(){
     if(typeof hudPanel!=='function') return 'SKIP: no HUD panel';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, oHP=hudPanel, seen=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); keys={}; g.mapOpen=false; g.bagOpen=false;
       hudPanel=function(x,y,w,h,a){ seen.push([x,y,w,h]); return oHP.apply(this,arguments); };
       __frame(0.016);
       hudPanel=oHP;
       if(!seen.some(function(r){ return r[0]>=16&&r[0]<=22&&r[3]<LH(20); })) bad.push('no posture chip panel ('+seen.length+' panels)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ hudPanel=oHP; keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
