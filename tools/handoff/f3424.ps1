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

if ($s.Contains("  {v:'34.24',what:")) { throw "check 34.24 is in the fixture already" }

SubRx @'
  {v:'34.23',what:
'@ @'
  {v:'34.24',what:'the raid HUD has one panel fill: every hudPanel and hudPlate in a raid frame is the same graphite (the critic on screens 21, 19, 37, 61: panel styles disagree)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     var proto=CanvasRenderingContext2D.prototype, o=proto.fill, seen={}, n=0, g, k, list=[], tmp=document.createElement('canvas').getContext('2d');
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false;
       __frame(0.001);
       proto.fill=function(){ var st=String(new Error().stack); if(this===ctx&&this.globalAlpha>0.05&&(/hudPlate|hudPanel/).test(st)){ tmp.globalAlpha=1; tmp.fillStyle=this.fillStyle; var s=String(tmp.fillStyle)+'@'+this.globalAlpha; seen[s]=(seen[s]||0)+1; n++; } return o.apply(this,arguments); };
       __frame(0.001);
       for(k in seen) list.push(k);
       if(n<3) return 'only '+n+' HUD panels were drawn';
       if(list.length>1) return 'the raid HUD panels use '+list.length+' fills: '+list.join(' ; ');
       return null;
     }catch(e){ return 'threw: '+(e&&e.message||e); }
     finally{ proto.fill=o; try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); } }},
  {v:'34.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
