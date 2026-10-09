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

if ($s.Contains("  {v:'21.14',what:")) { throw "check 21.14 is in the fixture already" }

SubRx @'
  {v:'21.13',what:
'@ @'
  {v:'21.14',what:'a backpack gun put in a slot held by a gun from the armoury sends that gun into the backpack, off the armoury list as a carried gun, never back to the armoury unseen',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof equipFromBag!=='function'||!WEAPONS.lance||!ITEMS.gun_lance||!ITEMS.gun_rifle) return 'SKIP: no lance or rifle here';
     var bad=[], g, p, w0=(P.weapons||[]).slice(), rs0=P.raidSpliced, ix, i, nl;
     try{
       __topClear(); __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       p=g.player;
       P.weapons=w0.filter(function(k){ return k!=='lance'; }).concat(['lance']); P.raidSpliced=[]; g.spliced=[];
       var L={}; for(var k in WEAPONS.lance) L[k]=WEAPONS.lance[k];
       p.sec=L; p.secAmmo=3; p.secIssued=false; p.secFromArmory=true;
       g.bag.push('gun_rifle'); ix=g.bag.length-1;
       if(!equipFromBag(ix,2)) return 'SKIP: staging: the rifle was not equipped';
       if(!(p.sec&&p.sec.id==='rifle')&&!(p.wep&&p.wep.id==='rifle')) bad.push('the rifle is not in a slot');
       nl=g.bag.filter(function(k){ return k==='gun_lance'; }).length;
       if(nl!==1) bad.push('the Meridian Lance it pushed out is not in the backpack ('+nl+')');
       if(P.weapons.indexOf('lance')>=0) bad.push('the Meridian Lance is still on the armoury list while in the backpack (two copies)');
       if((g.spliced||[]).indexOf('lance')<0) bad.push('the Meridian Lance is not counted as carried up');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var g2=__state(); if(g2&&!g2.over){ g2.spliced=[]; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       P.weapons=w0; P.raidSpliced=rs0;
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.13',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
