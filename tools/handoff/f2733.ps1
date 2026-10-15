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

if ($s.Contains("  {v:'27.33',what:")) { throw "check 27.33 is in the fixture already" }

SubRx @'
  {v:'27.32',what:
'@ @'
  {v:'27.33',what:'his order: each alert that takes the lane plays a short sting of its rank, and one refreshed in place or said again does not sting twice',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof styTone!=='function') return 'SKIP: no raid or sting bus here';
     var bad=[], g, calls=0, oT=styTone, got=[], ks=['crit','warn','ext'], i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       g.bagOpen=false; g.mapOpen=false; g.ents.length=0; keys={};
       styTone=function(n){ calls++; got.push(n&&n.length); return true; };
       for(i=0;i<ks.length;i++){
         g.alert=null; g.alertQ=[]; calls=0;
         say('STING TEST '+ks[i],ks[i],{key:'st'+ks[i]});
         if(calls!==1) bad.push('a '+ks[i]+' alert played '+calls+' stings, not 1');
         say('STING TEST '+ks[i],ks[i],{key:'st'+ks[i]});
         if(calls!==1) bad.push('a '+ks[i]+' alert said again played '+calls+' stings');
       }
       g.alert=null; g.alertQ=[]; calls=0;
       say('NOT AN ALERT','info');
       if(calls!==0) bad.push('a plain line played a lane sting');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ styTone=oT; try{ var g2=__state(); if(g2){ g2.alert=null; g2.alertQ=[]; if(!g2.over){ g2.player.downed=false; __endRaid('abandon'); } } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'27.32',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
