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

if ($s.Contains("  {v:'27.78',what:")) { throw "check 27.78 is in the fixture already" }

SubRx @'
  {v:'27.77',what:
'@ @'
  {v:'27.78',what:'cloud-menus-ui-volume-finds: UI VOLUME scales the find sounds (a rare, elite, gun or uncommon pickup), so OFF silences them as the row promises',
   run:function(){
     if(typeof sndFindOut!=='function'||typeof volOf!=='function'||typeof SND_FIND==='undefined') return 'SKIP: no find sound here';
     function nf(){}
     function N(){ var o={gain:{value:1,cancelScheduledValues:nf,setTargetAtTime:nf}}; o.connect=function(t){ return t; }; o.disconnect=nf; return o; }
     var FK={currentTime:1,sampleRate:48000,state:'running',resume:nf,destination:N(),createGain:N};
     var hasNet=(typeof NET==='object'&&!!NET), kSame=hasNet?NET.same:undefined, kAC=AC, kBUS=BUS, kL=SND_FIND_LAST, kVU=CFG.volUi, bad=[], g;
     try{
       AC=FK; BUS=N(); BUS.gain.value=0.8; SND_FIND_LAST=null; if(hasNet) NET.same='';
       CFG.volUi=1; g=sndFindOut(FK,1);
       if(!g) return 'SKIP: sndFindOut made no node on a stand-in audio context';
       if(Math.abs(g.gain.value-0.8)>1e-6) bad.push('at UI VOLUME FULL a find is not at the effects level 0.8: '+g.gain.value);
       CFG.volUi=0.5; g=sndFindOut(FK,1);
       if(!g||Math.abs(g.gain.value-0.4)>1e-6) bad.push('at UI VOLUME 50% a find is not at half the effects level: '+(g&&g.gain.value));
       CFG.volUi=0; g=sndFindOut(FK,1);
       if(!g||g.gain.value!==0) bad.push('at UI VOLUME OFF a find still plays at '+(g&&g.gain.value));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       AC=kAC; BUS=kBUS; SND_FIND_LAST=kL; if(kVU===undefined) delete CFG.volUi; else CFG.volUi=kVU; if(hasNet) NET.same=kSame;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
