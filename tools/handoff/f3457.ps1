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

if ($s.Contains("  {v:'34.57',what:")) { throw "check 34.57 is in the fixture already" }

SubRx @'
  {v:'34.56',what:
'@ @'
  {v:'34.57',what:'cw-runinfocol: in a career raid the run info panel is exactly as wide as the corner column (the minimap), his one column order, whatever the contract rows say',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__forceSize&&window.__runPrep&&window.__topClear&&window.__endRaid)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof HUDBOX==='undefined'||typeof MMAP==='undefined'||typeof careerPostBuild!=='function') return 'SKIP: no HUD boxes here';
     var bad=[], g=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       try{ careerPostBuild(g); }catch(_cp){}
       __P().hud={};
       __P().contracts=[{type:'extract',n:1,prog:0,desc:'extract with a haul worth $12,000 or more'},{type:'kills',n:5,prog:1,desc:'kill five sentries before the second horn'},{type:'district',d:0,n:3,prog:2,desc:'search 3 containers in the long dock or scrap yard line'}];
       for(var f=0;f<3;f++) __frame(0.2);
       __frame(0.016);
       var mm=MMAP.box, rc=HUDBOX.cond;
       if(!mm||!rc) return 'SKIP: no minimap or run info panel drawn';
       if(Math.abs(rc.w-mm.w)>1.5) bad.push('the run info panel is '+rc.w.toFixed(1)+' px wide and the minimap '+mm.w.toFixed(1));
       if(Math.abs((rc.x+rc.w)-(mm.x+mm.w))>1.5) bad.push('the run info panel ends at x '+(rc.x+rc.w).toFixed(1)+' and the minimap at '+(mm.x+mm.w).toFixed(1));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} try{ __cleanProfile(); }catch(_cl){} __topClear(); try{ __forceSize(1920,1080); }catch(_z){} }
     return bad.length?bad.join('; '):null; }},
  {v:'34.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
