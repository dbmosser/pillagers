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

if ($s.Contains("  {v:'22.10',what:")) { throw "check 22.10 is in the fixture already" }

SubRx @'
  {v:'22.09',what:
'@ @'
  {v:'22.10',what:'kit carried up and then used no longer counts against the haul: at the raid end the carried-up value falls by what is gone from the backpack, by count, what went up still adds up, and kit still in the backpack changes nothing',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof ival!=='function') return 'SKIP: no raid here';
     var bad=[], g, ci0, ks0, mv, ix;
     function nOf(a,x){ var n=0, j; for(j=0;j<(a||[]).length;j++) if(a[j]===x) n++; return n; }
     try{
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:['medkit','medkit'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: no live raid';
       mv=ival('medkit'); if(!(mv>0)) return 'SKIP: a Medkit is worth nothing here';
       if(nOf(g.carriedKit,'medkit')!==2||nOf(g.bag,'medkit')!==2) return 'SKIP: staging: the two Medkits did not go up';
       ci0=g.carriedIn||0; ks0=g.kitSold||0;
       ix=g.bag.indexOf('medkit'); g.bag.splice(ix,1);
       g.player.downed=false; __endRaid('abandon');
       if(Math.abs((g.carriedIn||0)-(ci0-mv))>0.5) bad.push('one of the two Medkits carried up was used and the run still counts '+(g.carriedIn||0)+' as carried up, not '+(ci0-mv));
       if(Math.abs(((g.carriedIn||0)+(g.kitSold||0))-(ci0+ks0))>0.5) bad.push('what went up no longer adds up: '+ci0+' and '+ks0+' became '+(g.carriedIn||0)+' and '+(g.kitSold||0));
       __topClear();
       __deploy({kit:['medkit','medkit'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return bad.length?bad.join('; '):'SKIP: no second raid';
       ci0=g.carriedIn||0; ks0=g.kitSold||0;
       g.player.downed=false; __endRaid('abandon');
       if(Math.abs((g.carriedIn||0)-ci0)>0.5||Math.abs((g.kitSold||0)-ks0)>0.5) bad.push('with both Medkits carried up still in the backpack the carried-up value moved from '+ci0+' to '+(g.carriedIn||0));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'22.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
