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

if ($s.Contains("  {v:'34.25',what:")) { throw "check 34.25 is in the fixture already" }

SubRx @'
  {v:'34.24',what:
'@ @'
  {v:'34.25',what:'the raid HUD uses few type sizes: the words drawn on the HUD canvas in one raid frame land on at most 10 distinct on-screen sizes (the critic on screens 21, 19, 37, 61: too many type sizes), and the vitals share the gun card scale',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     var proto=CanvasRenderingContext2D.prototype, o=proto.fillText, seen={}, list=[], g, k;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false;
       __frame(0.001);
       proto.fillText=function(t,x,y){ if(this===ctx&&this.globalAlpha>0.05){ var m=/([\d.]+)px/.exec(this.font); if(m) seen[Math.round(parseFloat(m[1])*this.getTransform().a)]=1; } return o.apply(this,arguments); };
       __frame(0.001);
       for(k in seen) list.push(k);
       if(list.length<5) return 'only '+list.length+' sizes were drawn';
       if(list.length>10) return 'the raid HUD draws words at '+list.length+' sizes: '+list.join(', ');
       if(HUDZ.body!==HUDZ.gear) return 'the vitals zoom '+HUDZ.body+' is not the gun card zoom '+HUDZ.gear;
       return null;
     }catch(e){ return 'threw: '+(e&&e.message||e); }
     finally{ proto.fillText=o; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); } }},
  {v:'34.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
