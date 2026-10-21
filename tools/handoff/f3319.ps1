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

if ($s.Contains("  {v:'33.19',what:")) { throw "check 33.19 is in the fixture already" }

SubRx @'
  {v:'33.18',what:
'@ @'
  {v:'33.19',what:'late night audio: a setting in AUDIO, off by default, that squeezes the world mix harder and catches peaks lower; off is the old mix exactly',
   run:function(){
     if(typeof lateNightApply!=='function'||typeof lateNightParams!=='function') return 'there is no late night audio (no lateNightApply)';
     var row=null, i, off=lateNightParams(false), on=lateNightParams(true), bad=[], S, ml, n, kc=CFG.lateNight;
     for(i=0;i<GAMEOPTS.length;i++){ if(GAMEOPTS[i].k==='lateNight') row=GAMEOPTS[i]; }
     if(!row) return 'AUDIO has no LATE NIGHT AUDIO row';
     if(row.sec!=='AUDIO'||row.def!==0||row.opts.length!==2||row.opts[0].cfg.lateNight!==0||row.opts[1].cfg.lateNight!==1) bad.push('the row is not an AUDIO off/on row that starts off');
     if(off.cr!==3.5||off.lt!==-3||off.tr!==0.5||off.mt!==-2) bad.push('off is not the old mix (ratio 3.5, limiter -3, trim 0.5, master -2)');
     if(!(on.cr>off.cr&&on.lt<off.lt&&on.tr<off.tr&&on.mt<off.mt)) bad.push('on does not squeeze harder and catch peaks lower');
     if(on.mt>-4||on.lt>-6||on.tr>0.45) bad.push('on is too gentle to matter for a quiet room');
     function P(v){ return {value:v}; }
     S={comp:{ratio:P(3.5)},lim:{threshold:P(-3)},trim:{gain:P(0.5)}}; ml={threshold:P(-2)};
     try{
       CFG.lateNight=0; if(lateNightOn()) bad.push('lateNightOn is true when the row is off');
       CFG.lateNight=1; if(!lateNightOn()) bad.push('lateNightOn is false when the row is on');
       n=lateNightApply(S,ml,true);
       if(n!==4||S.comp.ratio.value!==on.cr||S.lim.threshold.value!==on.lt||S.trim.gain.value!==on.tr||ml.threshold.value!==on.mt) bad.push('on does not reach the compressor, the limiter, the trim and the master limiter');
       n=lateNightApply(S,ml,true); if(n!==0) bad.push('a second apply wrote again');
       lateNightApply(S,ml,false);
       if(S.comp.ratio.value!==3.5||S.lim.threshold.value!==-3||S.trim.gain.value!==0.5||ml.threshold.value!==-2) bad.push('off does not put the old mix back');
     } finally { CFG.lateNight=kc; }
     return bad.length?bad.join('; '):null;
   }},
  {v:'33.18',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
