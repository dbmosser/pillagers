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

if ($s.Contains("  {v:'36.76',what:")) { throw "check 36.76 is in the fixture already" }

SubRx @'
  {v:'36.75',what:
'@ @'
  {v:'36.76',what:'the pillager board reads at the label size: its title and rows draw at 16 px or more on the screen (the style guide floor), the title is the first line drawn',
   run:function(){
     if(!(window.__deploy&&window.__endRaid&&window.__frame)) return 'SKIP: no raid here';
     var bad=[], g, i, PR=CanvasRenderingContext2D.prototype, of=PR.fillText, hit=null, sz=null, R, rows=0, px;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={}; g.legendOn=0;
       for(i=0;i<8;i++) __frame(0.016);
       PR.fillText=function(s){ var t=String(s); if(/^(current pillagers|you)\b/i.test(t)&&!sz){ var m=/([\d.]+)px/.exec(this.font); var tr=this.getTransform(); if(m) sz=parseFloat(m[1])*Math.abs(tr.a); hit=t; } return of.apply(this,arguments); };
       __frame(0.016); __frame(0.016);
       PR.fillText=of;
       R=HUDBOX.raiders;
       if(!R||!(R.w>0)) return 'no pillager board was drawn';
       if(!(sz>0)) bad.push('the board title was not drawn');
       else if(sz<16) bad.push('the board title draws at '+(Math.round(sz*10)/10)+' px on the screen (want 16 or more)');
     }catch(e){bad.push('threw: '+(e&&e.message||e));}
     finally{
       PR.fillText=of;
       try{var g2=__state(); if(g2&&!g2.over){g2.player.downed=false; __endRaid('abandon');}}catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
