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

if ($s.Contains("  {v:'25.72',what:")) { throw "check 25.72 is in the fixture already" }

SubRx @'
  {v:'25.71',what:
'@ @'
  {v:'25.72',what:'a search always opens on the rummage itself, whatever the last search left behind: a dig due on the next hit, or a last clip of rummage, still opens on the rummage',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof foley!=='function'||typeof searchFoley!=='function') return 'SKIP: no raid or foley here';
     if(typeof SRCHFX!=='object') return 'SKIP: this build has no varied search sound';
     var bad=[], rec=[], kFoley=foley, kSim=null, g=null, i, s, tys=['locker','body','crate'], ct, st;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.over) return 'SKIP: no live raid';
       kSim=g.sim; g.sim=false;
       foley=function(r,x,y,o){ rec.push(r); return false; };
       for(s=0;s<6;s++){
         for(i=0;i<tys.length;i++){
           ct={type:tys[i]};
           SRCHFX.dig=3+(s%3); SRCHFX.n=(s%2)?(SRCHFX.dig-1):0; SRCHFX.last=(s<3)?'rummage':'equip'; SRCHFX.hit=(s%2)?2:1; SRCHFX.t=0;
           rec.length=0; searchFoley(ct,'rummage');
           if(rec.length!==1||rec[0]!=='rummage') bad.push(tys[i]+' search '+s+' opens on '+(rec[0]||'nothing')+', not the rummage');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ foley=kFoley; }catch(_f){}
       try{ if(g&&kSim!==null) g.sim=kSim; SRCHFX.t=0; SRCHFX.last=''; SRCHFX.n=0; SRCHFX.hit=0; SRCHFX.dig=4; }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.slice(0,5).join('; '):null; }},
  {v:'25.71',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
