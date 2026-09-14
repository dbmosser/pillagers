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
  {v:'14.56',what:
'@ @'
  {v:'14.57',what:'the backpack does not open while he is down: I opens it standing, and while downed I leaves it shut (backpack audit finding 2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof raidKey!=='function') return 'SKIP: no raid keys in this build';
     var bad=[], g0=null;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g&&g.player; if(!g||!p) return 'SKIP: no live raid';
       g0=g; p.iv=99;
       // CONTROL: standing, I opens the backpack.
       g.bagOpen=false; p.downed=false; p.dying=false;
       raidKey('KeyI',false,null);
       if(!g.bagOpen) return 'SKIP: I did not open the backpack standing up here';
       raidKey('KeyI',false,null);
       if(g.bagOpen) return 'SKIP: I did not close the backpack here';
       // THE FIX: downed, I does not open it.
       p.downed=true;
       raidKey('KeyI',false,null);
       if(g.bagOpen) bad.push('I opened the backpack while he was down, so a tile can be held through the bleed-out');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(g0){ g0.bagOpen=false; g0.drag=null; if(g0.player){ g0.player.downed=false; g0.player.dying=false; g0.player.iv=0; } if(!g0.over) __endRaid('abandon'); } }catch(_e){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
