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
  {v:'13.62',what:
'@ @'
  {v:'13.63',what:'nothing on the belt is spent while downed: using a Bandage from the Medical cell on the floor is refused and the Bandage is kept, while the same use standing still spends it (in-raid audit 2026-09-14, finding 2)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof useHot!=='function'||typeof setHot!=='function'||typeof hotbarSlots!=='function') return 'SKIP: no belt in this build';
     var bad=[];
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, i, hc=-1;
       g.ents.length=0; p.iv=99; p.prep=null; p.healQ=0;
       g.bag=['bandage'];
       var sl=hotbarSlots(); for(i=0;i<sl.length;i++) if(sl[i]&&sl[i].kind==='heal') hc=i;
       if(hc<0) return 'SKIP: no Medical cell on the belt';
       // THE FINDING: down, with the self-revive spent.
       p.hp=0; p.downed=true; p.downT=30; p.revived=true;
       setHot(hc); useHot();
       if(g.bag.indexOf('bandage')<0) bad.push('using the Medical cell while downed spent the Bandage, and the heal never ticks on the floor');
       if(p.prep) bad.push('using the Medical cell while downed started a heal that cannot finish');
       // CONTROL: standing, the same use spends it.
       p.downed=false; p.downT=0; p.hp=40; p.prep=null; p.healQ=0; g.bag=['bandage'];
       setHot(hc); useHot();
       if(g.bag.indexOf('bandage')>=0) bad.push('control: standing at 40 health the Medical cell did not use the Bandage, so this check cannot see a use');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&g2.player){ g2.player.downed=false; g2.player.iv=0; g2.player.prep=null; } if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.62',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
