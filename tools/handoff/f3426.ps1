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

if ($s.Contains("  {v:'34.26',what:")) { throw "check 34.26 is in the fixture already" }

SubRx @'
  {v:'34.25',what:
'@ @'
  {v:'34.26',what:'the raid HUD quiets its corners: the item count and backpack cue on the gun card are 16 px on screen (not 20 and 24), the pillager board title is cream not amber, and the hidden chip is label size',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     var proto=CanvasRenderingContext2D.prototype, o=proto.fillText, hit={}, bad=[], g, i;
     function px(c){ var m=/([\d.]+)px/.exec(c.font); return m?Math.round(parseFloat(m[1])*c.getTransform().a*10)/10:0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.pBush=true; g.pConceal=0.4;
       __frame(0.001);
       proto.fillText=function(t,x,y){ if(this===ctx){ var s=String(t); if(/  BACKPACK$/i.test(s)) hit.bp={px:px(this)}; else if(/^\d+ ITEMS?\b/i.test(s)) hit.it={px:px(this)}; else if(/^CURRENT PILLAGER/i.test(s)) hit.bd={c:String(this.fillStyle).toLowerCase()}; else if(/IN COVER|CONCEALED|HIDDEN/i.test(s)) hit.cc={px:px(this)}; } return o.apply(this,arguments); };
       g.pBush=true; g.pConceal=0.4;
       __frame(0.001);
       if(!hit.bp) bad.push('no backpack cue drawn'); else if(hit.bp.px>17) bad.push('the backpack cue is '+hit.bp.px+' px');
       if(!hit.it) bad.push('no item count drawn'); else if(hit.it.px>17) bad.push('the item count is '+hit.it.px+' px');
       if(!hit.bd) bad.push('no pillager board drawn'); else if(hit.bd.c==='#ffc04a') bad.push('the board title is amber');
       if(!hit.cc) bad.push('no hidden chip drawn'); else if(hit.cc.px>19) bad.push('the hidden chip is '+hit.cc.px+' px');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=o; try{ var g2=__state(); if(g2&&!g2.over){ g2.pBush=false; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'34.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
