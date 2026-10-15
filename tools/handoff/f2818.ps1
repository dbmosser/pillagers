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

if ($s.Contains("  {v:'28.18',what:")) { throw "check 28.18 is in the fixture already" }

SubRx @'
  {v:'28.17',what:
'@ @'
  {v:'28.18',what:'outfit sets: five complete looks built from the layers, owned when every piece is, worn in one click, shown on your own operator',
   run:function(){
     if(typeof COSSETS==='undefined'||typeof setApply!=='function') return 'there are no outfit sets in this build';
     var bad=[], keep={}, ks=['cosAll','cosOutfit','cosScheme','cosHat','cosVest','cosPads','cosPack','cosBoots','cosGloves','runs','ext','xpLevel','kills','spClaimed','cosBought','cosBuild','cosHair'], i, k, c, box, el, names=[];
     function paint(st){
       var cv2=document.createElement('canvas'), x2, kw=wc;
       cv2.width=240; cv2.height=240; x2=cv2.getContext('2d'); wc=x2;
       try{ x2.translate(120,200); x2.scale(3,3); drawOp(0,0,0,0,'#242832',0,0,'none',0,st); } finally { wc=kw; }
       return x2.getImageData(0,0,240,240).data;
     }
     function diff(a,b){ var n=0, j; for(j=0;j<a.length;j+=4) if(a[j]!==b[j]||a[j+1]!==b[j+1]||a[j+2]!==b[j+2]) n++; return n; }
     try{
       for(i=0;i<ks.length;i++) keep[ks[i]]=P[ks[i]];
       if(COSSETS.length<5) bad.push('only '+COSSETS.length+' sets');
       COSSETS.forEach(function(s){
         var kk, p; names.push(s.name);
         if(!s.parts||!s.parts.scheme||!s.parts.hat||!s.parts.vest||!s.parts.pack||!s.parts.boots) bad.push(s.name+' is missing a piece');
         for(kk in s.parts){ p=cosFind(s.parts[kk]); if(!p||p.kind!==kk) bad.push(s.name+' piece '+kk+' is '+s.parts[kk]+', which is not on that rack'); }
       });
       if(['Scavenger','Raider','Engineer','Recon','Heavy'].join()!==names.join()) bad.push('the sets are '+names.join());
       // a fresh profile owns none of the big ones and is told the first piece it needs
       P.cosAll=false; P.runs=0; P.ext=0; P.xpLevel=1; P.kills={}; P.spClaimed=[]; P.cosBought={};
       if(setOwned(cosFind('setheavy'))) bad.push('the Heavy set is owned on a fresh profile');
       var need=cosNeed(cosFind('setheavy'));
       if(!/^needs /.test(need)||!/[A-Za-z]/.test(need)) bad.push('a locked set says '+need);
       if(need.length>90) bad.push('the line for a locked set is '+need.length+' characters');
       // earn what the Scavenger needs, and only that
       P.runs=5;
       if(!setOwned(cosFind('setscav'))) bad.push('the Scavenger is still locked at 5 raids ('+cosNeed(cosFind('setscav'))+')');
       if(setOwned(cosFind('setraid'))) bad.push('the Raider is owned at 5 raids');
       // wearing it
       P.cosOutfit='outrobot'; P.cosScheme='schstd'; P.cosHat='none'; P.cosPack='packbrown'; P.cosBoots='bootblack'; P.cosGloves='barehands'; P.cosVest='vestplate'; P.cosPads='padsnone';
       var b0=paint({hero:1,own:{wep:null}});
       setApply(cosFind('setscav'));
       if(cosWorn('outfit')!=='outnone') bad.push('a set leaves the suit on');
       if(cosWorn('scheme')!=='schdrab'||cosWorn('hat')!=='band'||cosWorn('boots')!=='boottan'||cosWorn('gloves')!=='glovetan') bad.push('a set did not write its pieces: '+cosWorn('scheme')+' '+cosWorn('hat')+' '+cosWorn('boots')+' '+cosWorn('gloves'));
       if(!setWorn(cosFind('setscav'))) bad.push('the worn set does not say it is worn');
       if(setWorn(cosFind('setraid'))) bad.push('another set says it is worn');
       if(diff(b0,paint({hero:1,own:{wep:null}}))<300) bad.push('wearing the Scavenger changes the figure by only '+diff(b0,paint({hero:1,own:{wep:null}}))+' pixels');
       // everything unlocked: every set wears, and they draw differently
       P.cosAll=true; var seen=[];
       COSSETS.forEach(function(s){ if(!setOwned(s)) bad.push(s.name+' is locked with everything unlocked'); setApply(s); seen.push(paint({hero:1,own:{wep:null}})); });
       for(i=0;i<seen.length;i++) for(k=i+1;k<seen.length;k++) if(diff(seen[i],seen[k])<400) bad.push(COSSETS[i].name+' and '+COSSETS[k].name+' draw alike');
       // the face and the build are the player own
       P.cosBuild='curved'; P.cosHair='red'; setApply(cosFind('setraid'));
       if(cosWorn('build')!=='curved'||cosWorn('hair')!=='red') bad.push('a set overwrote the build or the hair'); P.cosBuild='lean'; P.cosHair='dark';
       // the rack on screen
       P.cosAll=false; P.runs=5;
       box=document.createElement('div'); renderCosmetics(box,'set');
       var tiles=box.querySelectorAll('.costile');
       if(tiles.length!==COSSETS.length) bad.push('the SETS rack shows '+tiles.length+' tiles');
       el=box.querySelector('.costile[data-id="setheavy"]'); if(!el||!el.classList.contains('lock')) bad.push('the Heavy tile is not shown locked');
       if(el&&!/needs/i.test((el.querySelector('.cosreq')||{}).textContent||'')) bad.push('the locked tile does not say what it needs');
       el=box.querySelector('.costile[data-id="setscav"]'); if(!el||el.classList.contains('lock')) bad.push('the Scavenger tile is shown locked at 5 raids');
       if(el&&!el.querySelector('img')) bad.push('a set tile has no picture of the set');
       P.cosScheme='schstd'; P.cosHat='none';
       if(el) el.click();
       if(cosWorn('scheme')!=='schdrab'||cosWorn('hat')!=='band') bad.push('clicking the Scavenger tile left '+cosWorn('scheme')+' and '+cosWorn('hat'));
       el=box.querySelector('.costile[data-id="setheavy"]'); P.cosScheme='schstd'; if(el) el.click();
       if(cosWorn('scheme')!=='schstd') bad.push('clicking a locked set changed the look to '+cosWorn('scheme'));
       if(typeof lookSnap==='function'&&lookSnap().scheme!==cosWorn('scheme')) bad.push('a saved look and the worn scheme disagree');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ for(i=0;i<ks.length;i++){ var k3=ks[i]; if(keep[k3]===undefined) delete P[k3]; else P[k3]=keep[k3]; } try{ saveProfile(); }catch(_sp){} }
     return bad.length?bad.join('; '):null; }},
  {v:'28.17',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
