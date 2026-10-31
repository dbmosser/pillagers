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

if ($s.Contains("  {v:'36.79',what:")) { throw "check 36.79 is in the fixture already" }

SubRx @'
  {v:'36.78',what:
'@ @'
  {v:'36.79',what:'cw-xcountplate3: the inbound extraction line keeps two spaces either side of the ring letter, as the landed line does, so the ring name badge has room and is not read as part of the words',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawHUD!=='function') return 'SKIP: no raid HUD here';
     var bad=[], g, p, z, CP=CanvasRenderingContext2D.prototype, oF=CP.fillText, rec=[], c0=(typeof CAREER_ON==='number')?CAREER_ON:0, i, hit=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CAREER_ON=1; __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.mapFirst=false; g.bagOpen=false; g.paused=false; p.hp=100; p.downed=false; p.iv=999; g.timeLeft=300; g.waypoint=null;
       z=(g.zones||[])[0]; if(!z) return 'SKIP: staging: no ring';
       z.open=true; g.active=z; p.x=z.x; p.y=z.y; z.beaconT=9; z.hold=null; g.beaconT=9; g.shipHold=null;
       CP.fillText=function(s){ try{ rec.push(String(s)); }catch(_e){} return oF.apply(this,arguments); };
       try{ drawHUD(); }catch(e){ bad.push('drawHUD threw '+(e&&e.message||e)); }
       CP.fillText=oF;
       for(i=0;i<rec.length;i++) if(/^extract\s+[a-z]\s+inbound/i.test(rec[i])){ hit=rec[i]; break; }
       if(!hit) bad.push('the inbound line was not drawn');
       else if(!/^extract {2}[a-z] {2}inbound/i.test(hit)) bad.push('the ring letter has one space either side: '+JSON.stringify(hit));
     }catch(e){ bad.push('threw: '+(e.message||e)); }
     finally{ CP.fillText=oF; CAREER_ON=c0; try{ __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
