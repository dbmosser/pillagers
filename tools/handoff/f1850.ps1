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

if ($s.Contains("  {v:'18.50',what:")) { throw "check 18.50 is in the fixture already" }

SubRx @'
  {v:'18.49',what:
'@ @'
  {v:'18.50',what:'a seal cut past the new need still opens: with a banked cut above sealNeed, holding E at the door completes it and pays out',
   run:function(){
     if(!(window.__seal&&__seal.here&&__seal.need)) return 'SKIP: no seal here';
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keysRef)) return 'SKIP: this fixture cannot deploy and loop';
     var bad=[], g, p, R, c0, t0, i, K;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; if(!g.seal) return 'SKIP: no seal in this raid';
       R=__seal.here(); c0=R.cut; t0=R.tier; R.cut=__seal.need(R.tier)+2;
       p.x=g.seal.x+30; p.y=g.seal.y; p.downed=false;
       K=__keysRef(); for(var k in K) delete K[k]; K['KeyE']=true;
       for(i=0;i<8&&!g.seal.done;i++) __loop(performance.now()+i*16.7);
       for(var k2 in K) delete K[k2];
       if(!g.seal.done) bad.push('a door banked past its need never opened (cut '+R.cut+' of '+__seal.need(R.tier)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var K2=__keysRef(); for(var k3 in K2) delete K2[k3]; }catch(_k){} try{ if(R){ R.cut=c0; R.tier=t0; R.done=0; } }catch(_r){} try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; if(g2.seal) g2.seal.gained=0; __endRaid('abandon'); } }catch(_e){} try{ if(R){ R.cut=c0; R.tier=t0; } }catch(_r2){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'18.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
