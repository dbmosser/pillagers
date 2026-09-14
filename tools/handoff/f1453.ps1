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
  {v:'14.52',what:
'@ @'
  {v:'14.53',what:'a note with a line break stays one line in the run report: a floor note typed over two lines prints on its labelled line with the break shown, and no report line starts with its second half (report audit finding 4)',
   run:function(){
     if(typeof buildExport!=='function') return 'SKIP: no run report builder in this build';
     var bad=[], keep=P.floorNotes;
     try{
       P.floorNotes=[{run:P.runs||0,t:Date.now(),txt:'zqx first half\nzqx second half'}];
       var out=String(buildExport());
       // CONTROL: the floor note reached the report.
       if(out.indexOf('zqx first half')<0) return 'SKIP: the floor note did not reach the report here';
       var lines=out.split('\n');
       if(lines.some(function(l){ return l.indexOf('zqx second half')===0; })) bad.push('the second line of a floor note printed at the left margin with no label, reading as a line of the report itself');
       if(out.indexOf('zqx first half / zqx second half')<0) bad.push('the two halves of the note were not joined on its labelled line');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ P.floorNotes=keep; }
     return bad.length?bad.join('; '):null; }},
  {v:'14.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
