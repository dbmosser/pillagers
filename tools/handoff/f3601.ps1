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

if ($s.Contains("  {v:'36.01',what:")) { throw "check 36.01 is in the fixture already" }

SubRx @'
  {v:'36.00',what:
'@ @'
  {v:'36.01',what:'the medal spot shares the feed left edge and width, stays between feed and vitals, and clears the pillager board without pushing controls past 47 percent',
   run:function(){
     if(!(window.__deploy&&window.__endRaid&&window.__frame)) return 'SKIP: no raid here';
     if(typeof MEDALBOX==='undefined'||typeof feedRect!=='function') return 'no medal or feed layout';
     var bad=[], g, i, F, M, B, L, R;
     function hit(a,b){return a&&b&&a.w>0&&b.w>0&&a.x<b.x+b.w&&b.x<a.x+a.w&&a.y<b.y+b.h&&b.y<a.y+a.h;}
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={}; g.legendOn=1;
       for(i=0;i<10;i++) say('medal test line '+i,'info',{reach:'e'});
       for(i=0;i<6;i++) __frame(0.016);
       F=FEEDBOX; M=MEDALBOX; B=HUDBOX.body; L=HUDBOX.legend; R=HUDBOX.raiders;
       if(!F.on||!M.on||!(M.w>0)||!(M.h>0)) return 'feed or medal spot is not laid out';
       if(Math.abs(M.w-F.w)>2||Math.abs(M.x-F.x)>2) bad.push('medal spot '+M.x+'/'+M.w+' differs from feed '+F.x+'/'+F.w);
       if(M.h<48*Math.max(1,hudRes())) bad.push('medal spot is below the 48 px emblem height');
       if(F.y+F.h>M.y+0.5) bad.push('feed reaches the medal spot');
       if(B&&M.y+M.h>B.y+0.5) bad.push('medal spot reaches the vitals');
       if(F.rows.length!==FEED.show) bad.push('feed does not show its reserved line count');
       if(typeof hudRects==='function'&&!hudRects().medals) bad.push('medal spot is missing from HUD registry');
       if(!L||!(L.w>0)) bad.push('controls list was not drawn');
       else if(L.x+L.w>W*0.47+2) bad.push('controls list reaches past 47 percent');
       if(hit(R,M)) bad.push('pillager board overlaps the medal spot');
     }catch(e){bad.push('threw: '+(e&&e.message||e));}
     finally{
       try{var g2=__state(); if(g2&&!g2.over){g2.player.downed=false; __endRaid('abandon');}}catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
