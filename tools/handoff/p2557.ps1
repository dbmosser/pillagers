$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# THE FORGE: EXTRACT IT AND YOU KEEP IT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  out.sort(function(a,b){ return (WTIER[b.id]||0)-(WTIER[a.id]||0); });
  return out;
}
'@ @'
  out.sort(function(a,b){ return gunTierOf(b)-gunTierOf(a); });   // v23.xx (forge12): a forged gun ranks by its MK too
  return out;
}
// v23.xx, THE FORGE (2026-10-12), forge12. HIS RULE: "if you extract with an upgraded gun you get to keep it". CAREER only (the DEMO
// never reaches this settle). P.forged holds one record per gun model, {fk, el}, because the armoury holds one of each model.
// forgeBank, on an extraction after the banking: every forged gun carried out (both hands unless issued, and the backpack copies
// still matched to backpack keys) writes its model's record when that model is in the armoury; the highest MK wins, the hands win a
// tie, and an extracted gun never downgrades a record (a MK II carried out over a MK III record keeps the MK III). A plain armoury
// rifle with a MK III rifle extracted becomes the MK III; the extra plain copy goes to the stash as before. The deploy re-applies the
// record to gun 1 and gun 2 (forgeApply), so the rules of losing it are the armoury rules: a death loses the armoury gun carried and
// its record with it, an abandon puts the armoury back as it was and never writes a record bought that raid. forgeSweep drops a record
// whose model you no longer own anywhere (the armoury, the stash, or carried up this raid), or that is not a real gun, MK or element;
// it runs on load, on every save, and at the end of every raid. No draw on any stream.
function forgeBank(){
  var p=G&&G.player, L=[], best={}, i, w, q, gk, n, j, o;
  if(!p||G.sim||G.arcade||!P||!Array.isArray(P.weapons)) return 0;
  if(p.wep&&!p.wepIssued) L.push([p.wep,2]);
  if(p.sec&&!p.secIssued) L.push([p.sec,2]);
  if(G.stowQ) for(gk in G.stowQ){ q=G.stowQ[gk]; if(!q||!q.length) continue; n=gunQCount(gk); for(j=Math.max(0,q.length-n);j<q.length;j++) L.push([q[j],1]); }
  for(i=0;i<L.length;i++){
    w=L[i][0]; if(!w||!(w.fk===1||w.fk===2)||!WEAPONS[w.id]) continue;
    gk=w.id; o=best[gk];
    if(!o||w.fk>o.fk||(w.fk===o.fk&&L[i][1]>o.pr)) best[gk]={fk:w.fk,el:(w.fk===2&&w.el&&ELEM[w.el])?w.el:'',pr:L[i][1]};
  }
  if(!P.forged||typeof P.forged!=='object'||Array.isArray(P.forged)) P.forged={};
  n=0;
  for(gk in best){
    if(P.weapons.indexOf(gk)<0) continue;
    o=P.forged[gk];
    if(o&&o.fk>best[gk].fk) continue;
    P.forged[gk]={fk:best[gk].fk,el:best[gk].el}; n++;
  }
  return n;
}
function forgeOwned(k){
  var i, L;
  if(!P) return false;
  if(Array.isArray(P.weapons)&&P.weapons.indexOf(k)>=0) return true;
  if(Array.isArray(P.stash)&&P.stash.indexOf('gun_'+k)>=0) return true;
  if(Array.isArray(P.raidSpliced)&&P.raidSpliced.indexOf(k)>=0) return true;
  if(typeof G!=='undefined'&&G&&!G.sim&&Array.isArray(G.spliced)&&G.spliced.indexOf(k)>=0&&!G.forgeDead) return true;
  L=Array.isArray(P.gunPiled)?P.gunPiled:[];
  for(i=0;i<L.length;i++) if(L[i]&&L[i].gk===k) return true;
  return false;
}
function forgeSweep(how){
  var F, k, o, i, gone;
  if(!P) return 0;
  F=P.forged;
  if(F===undefined) return 0;
  if(!F||typeof F!=='object'||Array.isArray(F)){ P.forged={}; return 0; }
  if(how==='dead'&&typeof G!=='undefined'&&G){
    G.forgeDead=1;
    gone=(G.forgeGone||[]).concat(G.spliced||[]);
    for(i=0;i<gone.length;i++) if(P.weapons.indexOf(gone[i])<0) delete F[gone[i]];
  }
  for(k in F){
    if(!Object.prototype.hasOwnProperty.call(F,k)) continue;
    o=F[k];
    if(!o||typeof o!=='object'||!WEAPONS[k]||!(WEAPONS[k].mag>0)||!ITEMS['gun_'+k]||!(o.fk===1||o.fk===2)||(o.fk===2&&!(typeof o.el==='string'&&ELEM[o.el]))||!forgeOwned(k)){ delete F[k]; continue; }
    if(o.fk===1) o.el='';
  }
  return 1;
}
'@

SubRx @'
    // v15.58, first run audit finding: EXTRACTING WITH THE FREEBIE KIT KEEPS THE GUN YOU CHOSE IN GUN 1.
'@ @'
    if(!G.sim) forgeBank();   // v23.xx (forge12): extract with an upgraded gun and you keep it
    // v15.58, first run audit finding: EXTRACTING WITH THE FREEBIE KIT KEEPS THE GUN YOU CHOSE IN GUN 1.
'@

SubRx @'
      if(wi>=0){ P.weapons.splice(wi,1);
'@ @'
      if(wi>=0){ P.weapons.splice(wi,1); (G.forgeGone=G.forgeGone||[]).push(gone[j].id);   // v23.xx (forge12): its forge goes with it
'@

SubRx @'
    if(G.abandonFee>0) lines.push('<span style="color:var(--rust)">Walked out on the job. XP -'+G.abandonFee+'.</span>');
  }
'@ @'
    if(G.abandonFee>0) lines.push('<span style="color:var(--rust)">Walked out on the job. XP -'+G.abandonFee+'.</span>');
  }
  if(!G.sim) forgeSweep(how);   // v23.xx (forge12): a death takes the forge of the armoury gun lost; an abandon writes nothing
'@

SubRx @'
          P.weapons=P.weapons.filter(function(k){ return !!WEAPONS[k]; });
'@ @'
          P.weapons=P.weapons.filter(function(k){ return !!WEAPONS[k]; });
          try{ forgeSweep(); }catch(_fsw){}   // v23.xx (forge12): a bad saved forge record is dropped on load
'@

SubRx @'
  P.cfg=CFG; P.cfgv=18; storeSet(JSON.stringify(P));
'@ @'
  try{ forgeSweep(); }catch(_fsw){}   // v23.xx (forge12): a gun sold or gone takes its forge record with it
  P.cfg=CFG; P.cfgv=18; storeSet(JSON.stringify(P));
'@

SubRx @'
    sec=bakeWear(P.equippedSec); secIss=false;
  }
'@ @'
    sec=bakeWear(P.equippedSec); secIss=false;
  }
  // v23.xx (forge12): THE FORGE. Gun 1 and gun 2 from the armoury come up with the upgrade you extracted with. Not the sim, not the DEMO.
  if(!sim&&!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on)&&P.forged&&typeof P.forged==='object'){
    if(!wepIssued&&wep&&wep.id&&P.forged[wep.id]) wep=forgeApply(wep,P.forged[wep.id].fk,P.forged[wep.id].el);
    if(!secIss&&sec&&sec.id&&sec.id!=='fists'&&P.forged[sec.id]) sec=forgeApply(sec,P.forged[sec.id].fk,P.forged[sec.id].el);
  }
'@

SubRx @'
var VER='25.56';
'@ @'
var VER='25.57';
'@

$pat = "(?m)^  now:'v25\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.57: In CAREER an upgraded gun you extract with stays upgraded in your armoury. Check 25.57 fails on v25.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
