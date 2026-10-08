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

if ($s.Contains("  {v:'18.71',what:")) { throw "check 18.71 is in the fixture already" }

SubRx @'
  {v:'18.70',what:
'@ @'
  {v:'18.71',what:'the belt text grows with the belt: at 4K the caption over the belt and a slot count are at least 12 percent of the slot size',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame&&window.__forceSize)) return 'SKIP: this fixture cannot deploy at a forced size';
     var bad=[], g, oFT=ctx.fillText, rec=[], bw=0, cap=null, cnt=null, i, px;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); }catch(_d){}
       __forceSize(3840,2160);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); g.bagOpen=false; g.mapOpen=false;
       __frame(0.016);
       ctx.fillText=function(s,x,y){ rec.push({s:String(s),f:String(ctx.font)}); return oFT.apply(this,arguments); };
       try{ __frame(0.016); } finally { delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; }
       if(g.hotCells&&g.hotCells[0]) bw=g.hotCells[0].w;
       if(!(bw>0)) return 'SKIP: no belt slots';
       for(i=0;i<rec.length;i++){ if(rec[i].s.indexOf('[FIRE] use')>=0) cap=rec[i]; }
       if(!cap) return 'SKIP: the belt caption was not drawn';
       px=parseFloat((/([\d.]+)px/).exec(cap.f)[1]);
       if(px<bw*0.115) bad.push('the belt caption is '+px+'px over slots '+Math.round(bw)+' across');
       for(i=0;i<rec.length;i++){ if(/^\d+$/.test(rec[i].s)&&rec[i].s.length<=3){ var p2=parseFloat((/([\d.]+)px/).exec(rec[i].f)[1]); if(cnt===null||p2>cnt) cnt=p2; } }
       if(cnt!==null&&cnt<bw*0.115) bad.push('the slot numbers and counts are at most '+cnt+'px in slots '+Math.round(bw)+' across');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ delete ctx.fillText; if(ctx.fillText!==oFT) ctx.fillText=oFT; try{ cv.style.width='';cv.style.height='';hcv.style.width='';hcv.style.height=''; resize(); }catch(_f){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
