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

# A DOWNED PARTNER GETS A CLEAR ALERT AND A PULSING ARROW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sndDowned(mine,wx,wy){
'@ @'
// v31.xx (cw-matedown), HIS ANSWER 2.72 a (2026-10-18): "when your partner goes down, a clear alert sound plays and the edge arrow pointing at them pulses".
// The old sound for a downed partner was the low thud placed where he fell, silent past 1400 units. This is a plain two-note alert, the same
// loudness wherever he is, played with it. The arrow pulse is a scale between 1 and 1.5, two beats a second, only while he is down.
function mateArrowPulse(dn,ms){
  if(!dn) return 1;
  return 1+0.25*(1+Math.sin((+ms||0)/1000*Math.PI*4));
}
function sndMateAlert(){
  var a, out, t, i, o, og, f=[880,660,880,660], at;
  if(G&&G.sim) return false;
  if(typeof NET==='object'&&NET&&NET.specTick) return false;
  a=ac(); if(!a) return false;
  out=sndBus('sting'); if(!out) return false;
  t=a.currentTime;
  try{
    for(i=0;i<f.length;i++){
      at=t+i*0.16;
      o=a.createOscillator(); og=a.createGain(); o.type='triangle'; o.frequency.setValueAtTime(f[i],at);
      og.gain.setValueAtTime(0.0001,at); og.gain.exponentialRampToValueAtTime(0.2,at+0.012); og.gain.exponentialRampToValueAtTime(0.0001,at+0.14);
      o.connect(og); og.connect(out); o.start(at); o.stop(at+0.16);
    }
  }catch(err){ return false; }
  SND_DOWN.alert=(SND_DOWN.alert|0)+1;
  return true;
}
function sndDowned(mine,wx,wy){
'@

SubRx @'
try{ sndDowned(0,x,y); }catch(_dn){}
'@ @'
try{ sndDowned(0,x,y); }catch(_dn){} try{ sndMateAlert(); }catch(_mq){}
'@

SubRx @'
ctx.save(); ctx.translate(ax,ay); ctx.rotate(a); if(r>1) ctx.scale(r,r);
'@ @'
ctx.save(); ctx.translate(ax,ay); ctx.rotate(a); if(r>1) ctx.scale(r,r); if(g.dn){ var _mp=mateArrowPulse(1,(typeof performance!=='undefined'&&performance.now)?performance.now():Date.now()); ctx.scale(_mp,_mp); }   // v31.xx (cw-matedown): the arrow of a downed partner pulses
'@

SubRx @'
var VER='31.78';
'@ @'
var VER='31.79';
'@

$pat = "(?m)^  now:'v31\.78:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.79: When your partner goes down you hear a clear two-note alert, and the arrow pointing at them pulses. Check 31.79 fails on v31.78',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
