$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.08',what:
'@ @'
  {v:'14.09',what:'the empty second-gun slot says how to fill it: with one gun carried, selecting the vacant second slot leaves its explanation as the message rather than a "x0" cell line (raid HUD and map screen audit 2026-09-15, finding 6)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__say)) return 'SKIP: this fixture cannot deploy or read the message';
     if(typeof setHot!=='function'||typeof hotbarSlots!=='function') return 'SKIP: no belt in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       if(!g||!p||g.sim) return 'SKIP: no live raid';
       g.ents.length=0; g.hotAssign={}; g.hotAuto={};
       p.sec=null; p.secAmmo=0; p.secIssued=true; p.secFromArmory=false; p.swapped=false;   // no second gun at all: the belt draws the vacant cell only for this
       // CONTROL: a line said here reaches the message.
       __say('PROBE LINE SEVEN');
       if(g.msg!=='PROBE LINE SEVEN') return 'SKIP: say does not reach the message in this fixture, so nothing here can be measured';
       var sl=hotbarSlots(), vi=-1;
       for(var i=0;i<sl.length;i++) if(sl[i]&&sl[i].vacant){ vi=i; break; }
       if(vi<0) return 'SKIP: no vacant second-gun cell with one gun carried';
       g.hot=(vi===0?1:0);
       setHot(vi);
       var NEED=['No','second','weapon'].join(' ');
       if(String(g.msg||'').indexOf(NEED)!==0) bad.push('selecting the empty second-gun slot left the message as "'+g.msg+'" instead of how to fill it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.08',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
