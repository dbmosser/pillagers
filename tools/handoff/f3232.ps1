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

if ($s.Contains("  {v:'32.32',what:")) { throw "check 32.32 is in the fixture already" }

SubRx @'
  {v:'32.31',what:
'@ @'
  {v:'32.32',what:'a hard cap on loud sound: everything ends in a master limiter, the rain is a third quieter, and the demo lowers blasts and guns',
   run:function(){
     var a, same0, o, m, on0, bad=[];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(typeof masterOut!=='function') return 'there is no master limiter (no masterOut)';
       if(typeof rainLevel!=='function'||typeof sndDemoTrim!=='function') return 'no rainLevel or sndDemoTrim';
       var dest={n:'dest'}, prm=function(){ return {value:0}; };
       a={destination:dest, createDynamicsCompressor:function(){ var c={threshold:prm(),knee:prm(),ratio:prm(),attack:prm(),release:prm(),to:null}; c.connect=function(x){ c.to=x; }; return c; }};
       same0=NET.same; NET.same=null;
       try{ o=netSndOut(a); m=netMusOut(a); } finally { NET.same=same0; }
       if(!o||o===a.destination||!o.threshold||o.ratio.value<20||o.threshold.value>-1) bad.push('the world sound does not end in a limiter');
       if(o&&o.to!==dest) bad.push('the limiter does not feed the speakers');
       if(m!==o) bad.push('the music does not end in the same limiter');
       if(Math.abs(rainLevel(1)-0.030)>0.0005) bad.push('rain at full strength is '+rainLevel(1)+', not a third under 0.045');
       on0=ARCADE.on;
       try{ ARCADE.on=1; if(!(sndDemoTrim('imp')<=0.75&&sndDemoTrim('gun')<1&&sndDemoTrim('foley')===1)) bad.push('the demo does not lower blasts and guns'); ARCADE.on=0; if(sndDemoTrim('imp')!==1) bad.push('career sound is lowered'); }
       finally { ARCADE.on=on0; }
       return bad.length?bad.join('; '):null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
