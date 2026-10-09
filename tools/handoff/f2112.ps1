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

if ($s.Contains("  {v:'21.12',what:")) { throw "check 21.12 is in the fixture already" }

SubRx @'
  {v:'21.11',what:
'@ @'
  {v:'21.12',what:'the death card leaves the two issued loaner Bandages out of what was lost: dying with them and three finds lists 2 items and 2 Bandages of money fewer than the same backpack with nothing issued, and no Bandage reads LOST',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(!document.getElementById('oc_manifest')||!ITEMS.bandage) return 'SKIP: no run report manifest or Bandage in this page';
     var bad=[], X=null, k, P2=__P(), keepSt=(P2.stash||[]).slice(), A, B, a, b, mA, mB, RX=/(\d+) items? (?:and \d+ guns? )?lost, \$([\d,]+) gone/, LOSTB=ITEMS.bandage.name+'  LOST';
     for(k in ITEMS){ var it=ITEMS[k]; if(it&&k!=='medkit'&&k!=='bandage'&&it.use!=='key'&&it.use!=='gun'&&it.use!=='heal'&&it.use!=='throw'&&ival(k)>=40){ X=k; break; } }
     if(!X) return 'SKIP: nothing plain to carry beside the Bandages';
     function run(issued){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g||!g.player) return null;
       g.ents.length=0; g.player.downed=false; g.pedCarry=0; g.pedSold=0; g.hotAssign={};
       g.bag=['bandage','bandage',X,X,X]; g.issuedBandages=issued; g.bandSeen=undefined;
       g.tel.deathKiller='sentry'; g.player.pendKiller='sentry';
       __endRaid('dead');
       return String(document.getElementById('oc_manifest').textContent||'');
     }
     try{
       A=run(2);
       if(A===null) return 'SKIP: no live raid to die in';
       B=run(0);
       if(B===null) return 'SKIP: no live raid for the control';
       a=A.match(RX); b=B.match(RX);
       if(!a||!b) return 'SKIP: the death card printed no lost line to read';
       if(B.indexOf(LOSTB)<0) bad.push('control: with nothing issued no Bandage read LOST, so this check cannot read the rows');
       if(A.indexOf(LOSTB)>=0) bad.push('an issued loaner Bandage is listed as LOST');
       if((+b[1])-(+a[1])!==2) bad.push('the issued pair moved the lost count by '+((+b[1])-(+a[1]))+', not 2 ('+a[0]+' against '+b[0]+')');
       mA=+String(a[2]).replace(/,/g,''); mB=+String(b[2]).replace(/,/g,'');
       if(mB-mA!==2*ival('bandage')) bad.push('the issued pair moved the money gone by $'+(mB-mA)+', not $'+(2*ival('bandage'))+' ('+a[0]+' against '+b[0]+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.stash=keepSt; saveProfile(); }catch(_s){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'21.11',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
