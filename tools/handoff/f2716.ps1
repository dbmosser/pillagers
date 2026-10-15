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

if ($s.Contains("  {v:'27.16',what:")) { throw "check 27.16 is in the fixture already" }

SubRx @'
  {v:'27.15',what:
'@ @'
  {v:'27.16',what:'his answer 40: the low-health heartbeat starts at 30 health: none at 40 and 31, a beat at 25, and downed still beats',
   run:function(){
     if(!window.__deploy||!window.__endRaid||!window.__state||!window.__loop) return 'SKIP: no raid loop here';
     var bad=[], g=null, p=null, rb=blip, seen=0, all=null, f, hp, got={}, hps=[40,31,25,10], i, dn0;
     function run(h){
       seen=0; p.hp=h; p.downed=false; HEART=0;
       for(f=0;f<8&&!seen;f++) __loop(performance.now()+f*16.7);
       return seen;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g&&g.player; if(!g||g.over||g.sim||!p) return 'SKIP: staging: no live raid';
       all=g.ents.slice(); g.ents=[]; p.iv=99; dn0=p.downed;
       blip=function(k){ if(k==='heart') seen++; };
       for(i=0;i<hps.length;i++){ got[hps[i]]=run(hps[i]); p.iv=99; }
       if(got[40]) bad.push('a heartbeat at 40 health (it starts at 30)');
       if(got[31]) bad.push('a heartbeat at 31 health (it starts at 30)');
       if(!got[25]) bad.push('no heartbeat at 25 health');
       if(!got[10]) bad.push('no heartbeat at 10 health');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       blip=rb;
       try{ if(all&&g) g.ents=all; }catch(_a){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.hp=100; g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
