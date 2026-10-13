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

if ($s.Contains("  {v:'24.41',what:")) { throw "check 24.41 is in the fixture already" }

SubRx @'
  {v:'24.40',what:
'@ @'
  {v:'24.41',what:'his #50 and #35 (UI redesign ui5q1l, from the AAA judge of the raid fight shot): the damage number is drawn inside the right end of the health bar, right aligned, and not out past the bar over the belt',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy';
     var bad=[], g, p, seen=[], real=CanvasRenderingContext2D.prototype.fillText, hit;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; keys={};
       p.lastDmg=37; p.dmgPopT=1.05;
       CanvasRenderingContext2D.prototype.fillText=function(t,x,y){ seen.push({t:String(t),x:x,y:y,al:this.textAlign}); return real.apply(this,arguments); };
       try{ __frame(0.001); }finally{ CanvasRenderingContext2D.prototype.fillText=real; }
       hit=seen.filter(function(s){ return s.t==='-'+'37'; })[0];
       if(!hit) bad.push('control: the damage number was not drawn ('+seen.length+' texts)');
       else if(!(hit.x<=16+360)) bad.push('the damage number is drawn at x '+Math.round(hit.x)+', past the end of the health bar (376)');
       else if(hit.al!=='right') bad.push('the damage number is not right aligned to the bar end');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ CanvasRenderingContext2D.prototype.fillText=real; keys={}; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'24.40',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
