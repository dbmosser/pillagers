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

if ($s.Contains("  {v:'17.87',what:")) { throw "check 17.87 is in the fixture already" }

SubRx @'
  {v:'17.86',what:
'@ @'
  {v:'17.87',what:'a slow PC is told once where the levers are: ten seconds of frames mostly over 25 ms say the line, smooth frames never do, and it is said once a session',
   run:function(){
     if(typeof perfNote!=='function') return 'a slow PC is told nothing';
     var bad=[], lines=[], oSwf=sayWhenFree, w0=PERF.win, s0=PERF.said, i, n0, t0;
     try{
       sayWhenFree=function(t){ lines.push(String(t)); };
       PERF.win=[]; PERF.said=0; n0=performance.now();
       for(i=0;i<120;i++) perfNote(16.7);
       if(lines.length) bad.push('smooth frames said '+JSON.stringify(lines));
       PERF.win=[]; t0=performance.now()-9000;
       for(i=0;i<120;i++) PERF.win.push([t0+i*75,40]);
       perfNote(40);
       if(lines.length!==1||!/Render resolution/.test(lines[0])) bad.push('slow frames said '+JSON.stringify(lines));
       for(i=0;i<120;i++) perfNote(40);
       if(lines.length!==1) bad.push('the line was said '+lines.length+' times');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ sayWhenFree=oSwf; PERF.win=w0||[]; PERF.said=s0; }
     return bad.length?bad.join('; '):null; }},
  {v:'17.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
