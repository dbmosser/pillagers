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

if ($s.Contains("  {v:'36.72',what:")) { throw "check 36.72 is in the fixture already" }

SubRx @'
  {v:'36.71',what:
'@ @'
  {v:'36.72',what:'big minimap, large HUD and open run info: the run info box stays clear of the belt keys and the air strike meter, and the feed lines stay clear of the belt, at 1080 and 4K in both windows',
   run:function(){
     if(typeof __frame!=='function'||typeof __forceSize!=='function'||typeof __corpusAirHandStage!=='function') return 'SKIP: no frame helpers';
     var sizes=[[1920,1080],[3840,2160]], roles=['host','join'], bad=[], si, ri, g, a, c, cells, air, rows, i, tag;
     function hit(p,q){ return p&&q&&p.w>0&&p.h>0&&q.w>0&&q.h>0&&p.x<q.x+q.w&&p.x+p.w>q.x&&p.y<q.y+q.h&&p.y+p.h>q.y; }
     try{
       for(si=0;si<sizes.length;si++) for(ri=0;ri<roles.length;ri++){
         tag=sizes[si][1]+'p '+roles[ri];
         __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
         __deploy({kit:['gun_carbine','bandage'],safe:null,mapIx:0,seed:4242});
         g=__state(); if(!g||!g.player||g.over) return 'no raid to stage';
         __pinDPR(1); __forceSize(sizes[si][0],sizes[si][1]);
         a=__corpusAirHandStage(roles[ri]); if(!a||!a.ok) return tag+': the air strike plate was not staged';
         CFG.minimap=1; CFG.mmSz=2; CFG.hudTv=1; g.legendOn=0;
         P.hud=P.hud||{}; P.hud.cond={o:1}; P.hud.mmap={c:0}; P.hud.raiders={c:1};
         if(g.fd) g.fd.lines=[];
         feedAdd('contract nearby: search 3 containers in the long dock or scrap line','obj',{key:'hb1'});
         feedAdd('contract nearby: open a vault in the sump','obj',{key:'hb2'});
         feedAdd('contract nearby: destroy 2 criers at the old pier','obj',{key:'hb3'});
         __frame(0); __frame(0); __frame(0);
         c=HUDBOX.cond; cells=g.hotCells||[]; air=g.airBox; rows=FEEDBOX.rows||[];
         if(!c||!(c.w>0)) { bad.push(tag+': run info not drawn'); continue; }
         if(!cells.length) { bad.push(tag+': no belt'); continue; }
         if(!air||!(air.w>0)) bad.push(tag+': no air strike plate drawn');
         for(i=0;i<cells.length;i++) if(hit(c,cells[i])) { bad.push(tag+': run info box '+Math.round(c.x)+','+Math.round(c.y)+','+Math.round(c.w)+','+Math.round(c.h)+' is on belt slot '+cells[i].i); break; }
         if(hit(c,air)) bad.push(tag+': run info is on the air strike meter');
         if(!rows.length) bad.push(tag+': no feed line drawn');
         for(i=0;i<rows.length;i++){ var k; for(k=0;k<cells.length;k++) if(hit(rows[i],cells[k])){ bad.push(tag+': feed line '+i+' ('+Math.round(rows[i].x)+','+Math.round(rows[i].y)+','+Math.round(rows[i].w)+','+Math.round(rows[i].h)+') is on belt slot '+cells[k].i); break; } }
       }
       return bad.length?bad.join('; '):null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'36.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
