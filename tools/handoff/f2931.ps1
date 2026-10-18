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

if ($s.Contains("  {v:'29.31',what:")) { throw "check 29.31 is in the fixture already" }

SubRx @'
  {v:'29.30',what:
'@ @'
  {v:'29.31',what:'the HUD has one hero: the corner credits are 24 px cream, not 32 px amber, and the backpack cue is a quiet grey, not amber (style guide)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     var bad=[], tr=document.getElementById('topright'), proto=CanvasRenderingContext2D.prototype, o=proto.fillText, hit=null, g, cs;
     if(!tr) return 'SKIP: no credits readout here';
     try{
       cs=getComputedStyle(tr);
       if(cs.fontSize!=='24px') bad.push('the credits readout is '+cs.fontSize+', not 24px');
       if(cs.color!=='rgb(239, 233, 220)') bad.push('the credits readout is '+cs.color+', not cream');
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false;
       proto.fillText=function(t,x,y){ if(/backpack/i.test(String(t))&&this.textAlign==='right') hit=String(this.fillStyle).toLowerCase(); return o.apply(this,arguments); };
       hit=null; __frame(0.001);
       if(hit===null) bad.push('the backpack cue was not drawn');
       else if(hit!=='#aaa498') bad.push('the backpack cue is '+hit+', not quiet grey');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ proto.fillText=o; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'29.30',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
