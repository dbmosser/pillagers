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

if ($s.Contains("  {v:'27.14',what:")) { throw "check 27.14 is in the fixture already" }

SubRx @'
  {v:'27.13',what:
'@ @'
  {v:'27.14',what:'his answer 36: the pickup stack holds six rows, not four: eight different pickups in a row leave the newest six, and the stack draws all six',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||typeof pickSay!=='function'||typeof drawPickups!=='function') return 'SKIP: no pickup stack here';
     var bad=[], g=null, i, n, names=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       g.pick=[]; g.bagOpen=false; g.mapOpen=false;
       for(i=0;i<8;i++) pickSay('ZQ ROW '+i,{c:'text'});
       if(g.pick.length!==6) bad.push('eight pickups left '+g.pick.length+' rows in the stack, not 6');
       else if(g.pick[5].m!=='ZQ ROW 7'||g.pick[0].m!=='ZQ ROW 2') bad.push('the stack does not keep the newest six ('+g.pick[0].m+' to '+g.pick[5].m+')');
       g.t+=0.4;
       for(i=0;i<g.pick.length;i++) g.pick[i].at=g.t-1;
       n=drawPickups();
       if(H>=1000&&n!==6) bad.push('the stack drew '+n+' of its 6 rows at '+W+'x'+H);
       g.pick=[];
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(g) g.pick=[]; }catch(_p){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
