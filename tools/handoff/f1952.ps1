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

if ($s.Contains("  {v:'19.52',what:")) { throw "check 19.52 is in the fixture already" }

SubRx @'
  {v:'19.51',what:
'@ @'
  {v:'19.52',what:'map label boxes follow his wording: a map word he lengthened is measured at its new length, and one he blanked is not placed at all',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw';
     if(typeof mapPlaceLabels!=='function'||typeof TX!=='function') return 'SKIP: no label placer here';
     var bad=[], g, mpl=mapPlaceLabels, Qs=null, had=!!P.txt, t0=had?JSON.parse(JSON.stringify(P.txt)):null, LONG='ZQX A MUCH LONGER WORD FOR CACHE', i, c=null, s=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:1,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.ents.length=0; g.bagOpen=false; g.mapOpen=true;
       P.txt=P.txt||{}; P.txt['CACHE']=LONG; P.txt['STRONGBOX']=' ';
       mapPlaceLabels=function(Q,h,fn){ Qs=Q.slice(); return mpl.apply(this,arguments); };
       __frame(0.001);
       if(!Qs) return 'SKIP: the map labels were not placed';
       for(i=0;i<Qs.length;i++){ if(String(Qs[i].s)==='CACHE'&&!c) c=Qs[i]; if(String(Qs[i].s)==='STRONGBOX'&&!s) s=Qs[i]; }
       if(!c) return 'SKIP: no CACHE label on this map';
       ctx.save(); ctx.font=c.font; var wl=ctx.measureText(LONG).width; ctx.restore();
       if(Math.abs(c.w-wl)>1) bad.push('a lengthened CACHE is measured '+Math.round(c.w)+' wide, drawn '+Math.round(wl));
       if(s) bad.push('a blanked STRONGBOX still takes room on the map');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ mapPlaceLabels=mpl; if(had) P.txt=t0; else delete P.txt; try{ var g2=__state(); if(g2){ g2.mapOpen=false; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
