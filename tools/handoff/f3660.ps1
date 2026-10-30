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

if ($s.Contains("  {v:'36.60',what:")) { throw "check 36.60 is in the fixture already" }

SubRx @'
  {v:'36.59',what:
'@ @'
  {v:'36.60',what:'recorded-footage titles have opaque backplates, the wake prompt stays above the lower footage and the elapsed badge scales with resolution',
   run:function(){
     var bad=[], d, name, prompt, mark, cs, oldState=state, oldArc=ARCADE.on, oldGate=FSG.open, last=ATT.last, shown=REC.mark&&REC.mark.style.display;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __hubEnter(); __topClear(); ARCADE.on=false; FSG.open=false;
       if(document.activeElement&&document.activeElement.blur) document.activeElement.blur();
       ATT.last=Date.now()-31000; attShow('data:video/mp4;base64,AAAA'); d=attEl();
       if(d.getAttribute('data-capture-playback')!=='1') bad.push('the footage layout was not selected');
       d.style.display='block'; name=d.querySelector('.attname'); prompt=d.querySelector('.attpress');
       cs=getComputedStyle(name);
       if(cs.backgroundImage!=='none'||cs.backgroundColor!=='rgb(11, 12, 13)') bad.push('the title still lets recorded labels through');
       if(parseFloat(cs.fontSize)<55) bad.push('the footage title is below 56px');
       cs=getComputedStyle(prompt);
       if(cs.backgroundImage!=='none'||cs.backgroundColor!=='rgb(11, 12, 13)') bad.push('the wake prompt still has a transparent band');
       if(parseFloat(cs.fontSize)<31) bad.push('the footage wake prompt is below 32px');
       if(prompt.getBoundingClientRect().bottom>innerHeight*.89) bad.push('the wake prompt is too close to the footage edge');
       recMark(true); mark=REC.mark; cs=getComputedStyle(mark);
       if(Math.abs(parseFloat(cs.fontSize)-Math.max(20,innerHeight*20/1080))>0.6) bad.push('the recording badge does not scale to a readable 1080p size');
       if(cs.borderRadius!=='4px') bad.push('the recording badge has a separate pill style');
       attStop(); if(d.hasAttribute('data-capture-playback')) bad.push('the footage layout leaked into the arcade');
       return bad.length?bad.join('; '):null;
     }finally{ attStop(); if(REC.mark) REC.mark.style.display=shown||'none'; state=oldState; ARCADE.on=oldArc; FSG.open=oldGate; ATT.last=last; __topClear(); }
   }},
  {v:'36.59',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
