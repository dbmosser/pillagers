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

if ($s.Contains("  {v:'33.20',what:")) { throw "check 33.20 is in the fixture already" }

SubRx @'
  {v:'33.19',what:
'@ @'
  {v:'33.20',what:'low health filter: below 30 health the world mix low-passes softly (12 kHz down to 2.2 kHz at 0) on the same filter as the downed dip, waits out the dip, and opens again when health is back',
   run:function(){
     if(typeof lowHpFreq!=='function'||typeof sndLowHpApply!=='function') return 'there is no low health filter (no lowHpFreq)';
     var ny=24000, bad=[], f30=lowHpFreq(30,false,ny), f29=lowHpFreq(29,false,ny), f15=lowHpFreq(15,false,ny), f0=lowHpFreq(0,false,ny), r, dipNode=null, nowT=10, kd=SND_DOWN.dipEnd, kS=SND;
     if(f30!==ny||lowHpFreq(100,false,ny)!==ny) bad.push('health 30 and up is filtered');
     if(!(f29<ny&&f29>9000)) bad.push('health 29 is not a gentle start ('+f29+')');
     if(!(f15<f29&&f0<f15)) bad.push('the filter does not close as health falls');
     if(Math.abs(f0-2200)>1) bad.push('health 0 is not 2200 ('+f0+')');
     if(lowHpFreq(5,true,ny)!==ny) bad.push('downed is filtered here, it is the dip that owns that');
     function P(v){ var q={value:v,sets:[]}; q.setTargetAtTime=function(x){ q.sets.push(x); q.value=x; return q; }; q.cancelScheduledValues=function(){ return q; }; return q; }
     var a={sampleRate:48000,currentTime:nowT,createBiquadFilter:function(){ var o={type:'',frequency:P(24000),Q:P(0.5),connect:function(){},disconnect:function(){}}; dipNode=o; return o; }};
     var S={out:{},trim:{connect:function(){},disconnect:function(){}}};
     try{
       SND=S; SND_DOWN.dipEnd=0;
       r=sndLowHpApply(a,S,100,false); if(r!=='skip'||dipNode) bad.push('full health builds a filter ('+r+')');
       r=sndLowHpApply(a,S,10,false); if(r!=='set'||!dipNode||dipNode.frequency.sets.length!==1) bad.push('health 10 does not set the filter ('+r+')');
       else if(Math.abs(dipNode.frequency.sets[0]-lowHpFreq(10,false,24000))>1) bad.push('health 10 sets the wrong cutoff');
       r=sndLowHpApply(a,S,10,false); if(r!=='same') bad.push('the same health sets again ('+r+')');
       SND_DOWN.dipEnd=nowT+1.3; r=sndLowHpApply(a,S,3,false); if(r!=='dip'||dipNode.frequency.sets.length!==1) bad.push('the filter is set while the downed dip is running ('+r+')');
       SND_DOWN.dipEnd=0; S.lowHpF=0; r=sndLowHpApply(a,S,3,false); if(r!=='set') bad.push('the health does not set the filter after the dip ('+r+')');
       r=sndLowHpApply(a,S,100,false); if(r!=='set'||Math.abs(dipNode.frequency.sets[dipNode.frequency.sets.length-1]-24000)>1) bad.push('the filter does not open when health is back ('+r+')');
     } finally { SND_DOWN.dipEnd=kd; SND=kS; }
     return bad.length?bad.join('; '):null;
   }},
  {v:'33.19',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
