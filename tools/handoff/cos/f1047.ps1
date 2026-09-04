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
  {v:'10.46',what:'a capstone is earned by owning every other piece on its rack, and the next-piece line counts the pieces left',
'@ @'
  {v:'10.47',what:'the eye, clothing and boots racks each have a capstone, earned by owning every other piece on the rack, with a colour and a swatch',
   run:function(){
     var bad=[];
     if(typeof COSMETICS==='undefined'||typeof cosRackComplete!=='function') return 'SKIP: no rack gates in this build';
     var caps=[['eyesilver','eyes'],['gold','fit'],['gilded','boots']];
     // THE FINDING. On v10.46 only the hair rack had a capstone.
     var missing=caps.filter(function(c){ var o=cosFind(c[0]); return !o||o.kind!==c[1]||String(o.how)!=='rack:'+c[1]; }).map(function(c){ return c[0]; });
     if(missing.length) return 'no capstone on: '+missing.join(', ');
     __resetCfg(); __pinDefaults(0); __cleanProfile();
     var P2=__P(); var keep={runs:P2.runs,ext:P2.ext,kills:P2.kills,xpLevel:P2.xpLevel,spClaimed:P2.spClaimed,nightExt:P2.nightExt,bestStreak:P2.bestStreak};
     function fresh(){ P2.runs=0; P2.ext=0; P2.kills={}; P2.xpLevel=1; P2.spClaimed=[]; P2.nightExt=0; P2.bestStreak=0; }
     function maxed(){ P2.runs=999; P2.ext=999; P2.kills={warden:99,crawler:999}; P2.xpLevel=99; P2.spClaimed=(typeof SEASON_TIERS!=='undefined')?SEASON_TIERS.map(function(t,i){ return i; }):[]; P2.nightExt=99; P2.bestStreak=99; }
     caps.forEach(function(cc){
       var id=cc[0], kind=cc[1], cap=cosFind(id);
       fresh();
       if(cosOwned(cap)) bad.push(id+' is owned on a fresh profile');
       if(!cosNeed(cap)) bad.push(id+' has no requirement text');
       if(/>\?</.test(cosSwatch(cap))) bad.push(id+' has no swatch');
       if(kind==='eyes'&&!(typeof EYECOL!=='undefined'&&EYECOL[id])) bad.push(id+' has no colour');
       if(kind==='fit'&&!(typeof FITCOL!=='undefined'&&FITCOL[id])) bad.push(id+' has no colour');
       if(kind==='boots'&&!(typeof BOOTCOL!=='undefined'&&BOOTCOL[id])) bad.push(id+' has no colour');
       maxed();
       var others=COSMETICS.filter(function(c){ return c.kind===kind&&c.id!==id&&String(c.how).indexOf('rack:')!==0; });
       var locked=others.filter(function(c){ return !cosOwned(c); });
       if(locked.length) bad.push('staging: with every counter maxed these '+kind+' stay locked: '+locked.map(function(c){ return c.id; }).join(', '));
       else if(!cosOwned(cap)) bad.push('every other '+kind+' is owned and '+id+' is not');
       // One piece locked again, and the distance says one.
       var gated=others.filter(function(c){ return c.how!=='always'; })[0];
       if(gated){ var d0=cosDist(gated); if(d0&&d0.k!=='board'){ var key={runs:'runs',extracts:'ext',level:'xpLevel',kills:null,night:'nightExt',streak:'bestStreak',warden:null}[d0.k];
           var saved=null; if(key){ saved=P2[key]; P2[key]=(d0.k==='level')?1:0; } else if(d0.k==='warden'||d0.k==='kills'){ saved=P2.kills; P2.kills={}; }
           var locked2=others.filter(function(c){ return !cosOwned(c); }).length;
           if(!locked2) bad.push('staging: nothing on '+kind+' locks when '+gated.id+' should');
           else { if(cosOwned(cap)) bad.push(id+' is owned with '+locked2+' '+kind+' locked'); var d=cosDist(cap); if(!d||d.need-d.cur!==locked2) bad.push('the distance to '+id+' is '+(d?d.need-d.cur:'?')+', not '+locked2); }
           if(key) P2[key]=saved; else P2.kills=saved; } }
     });
     // CONTROL: the hair capstone still reads its own rack, not these.
     maxed(); if(!cosOwned(cosFind('platinum'))) bad.push('control: Platinum is not owned with everything earned');
     for(var k in keep) P2[k]=keep[k];
     return bad.length?bad.join('; '):null; }},
  {v:'10.46',what:'a capstone is earned by owning every other piece on its rack, and the next-piece line counts the pieces left',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
