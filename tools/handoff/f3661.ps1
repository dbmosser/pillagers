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

if ($s.Contains("  {v:'36.61',what:")) { throw "check 36.61 is in the fixture already" }

SubRx @'
  {v:'36.60',what:
'@ @'
  {v:'36.61',what:'captured-footage title has 24px breathing room and a 96px underline, and its wake prompt clears the lower recorded UI',
   run:function(){
     var oldState=state, oldArc=ARCADE.on, oldGate=FSG.open, last=ATT.last, bad=[], d, name, prompt, cs;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __hubEnter(); __topClear();
       ARCADE.on=false; FSG.open=false;
       if(document.activeElement&&document.activeElement.blur) document.activeElement.blur();
       ATT.last=Date.now()-31000; attShow('data:video/mp4;base64,AAAA'); d=attEl(); d.style.display='block';
       name=d.querySelector('.attname'); prompt=d.querySelector('.attpress'); cs=getComputedStyle(name);
       if(Math.abs(parseFloat(cs.paddingTop)-Math.max(24,innerHeight*24/1080))>0.6) bad.push('title padding does not scale from 24px');
       cs=getComputedStyle(name,'::after');
       if(Math.abs(parseFloat(cs.width)-Math.max(96,innerHeight*96/1080))>0.6) bad.push('title underline does not scale from 96px');
       if(Math.abs(parseFloat(cs.height)-Math.max(4,innerHeight*4/1080))>0.6) bad.push('title underline does not scale from 4px');
       if(prompt.getBoundingClientRect().bottom>innerHeight*.87) bad.push('wake prompt still sits over the low footage edge');
       return bad.length?bad.join('; '):null;
     }finally{ attStop(); state=oldState; ARCADE.on=oldArc; FSG.open=oldGate; ATT.last=last; __topClear(); }
   }},
  {v:'36.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
