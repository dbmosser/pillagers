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

if ($s.Contains("  {v:'34.54',what:")) { throw "check 34.54 is in the fixture already" }

SubRx @'
  {v:'34.53',what:
'@ @'
  {v:'34.54',what:'career raid: the controls list starts folded; the folded line and the opened list stand mid-bottom left, clear of the feed and vitals (his rs-1)',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof careerPostBuild!=='function') return 'SKIP: no raid in this fixture';
     var bad=[], r0=P.runs, oSay=say, g=null, lb, fb, hb, hh, i, others;
     function hit(a,b){ return a&&b&&a.w>0&&b.w>0&&a.x<b.x+b.w&&b.x<a.x+a.w&&a.y<b.y+b.h&&b.y<a.y+a.h; }
     function inLL(a,n){ if(!a) return n+' has no box'; if(a.x+a.w>W/2) return n+' is not in the left half: right edge '+Math.round(a.x+a.w); if(a.y<H/2) return n+' is not in the lower half: y '+Math.round(a.y); return null; }
     try{
       say=function(){};
       P.runs=0; __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: staging: no raid';
       g.legendOn=1; g.career=0; g.arcade=0; careerPostBuild(g);
       if(g.legendOn!==0) bad.push('a career raid starts with the list open ('+g.legendOn+')');
       g.career=1; g.legendAutoDone=true;
       g.legendOn=0; for(i=0;i<12;i++) __frame();
       hh=(typeof LEGHINT!=='undefined')?LEGHINT:null; fb=FEEDBOX; hb=HUDBOX.body;
       if(!fb||!fb.on) return 'SKIP: no feed box this frame';
       if(inLL(hh,'the folded line')) bad.push(inLL(hh,'the folded line'));
       else {
         if(hit(hh,fb)) bad.push('the folded line overlaps the feed');
         if(hit(hh,hb)) bad.push('the folded line overlaps the vitals');
       }
       g.legendOn=1; for(i=0;i<12;i++) __frame();
       lb=HUDBOX.legend;
       if(inLL(lb,'the opened list')) bad.push(inLL(lb,'the opened list'));
       else {
         if(hit(lb,fb)) bad.push('the opened list overlaps the feed');
         if(hit(lb,hb)) bad.push('the opened list overlaps the vitals');
         if(hh&&lb.y+lb.h>hh.y+hh.h+2) bad.push('the opened list does not end where the folded line ends');
         if(hh&&Math.abs(lb.x-hh.x)>LH(14)) bad.push('the opened list and the folded line do not share a left edge: '+Math.round(lb.x)+' vs '+Math.round(hh.x));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ say=oSay; P.runs=r0; try{ if(G&&!G.over) __endRaid('abandon'); __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null;
   }},
  {v:'34.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
