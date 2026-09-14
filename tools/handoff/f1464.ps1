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

# CHECK 10.37 ASSERTED BEHAVIOUR v14.49 AND v14.51 CHANGED ON PURPOSE. A stack location is now the lines that carry a line
# and column (v14.51), and messages differing only in a number are one crash (v14.49). The claims stay: a stack or a file is
# recorded, and the list keeps its newest twelve distinct crashes.
SubRx @'
     if(!/Error|probe\.js/.test(c.where||'')) bad.push('the entry carries no stack and no file: "'+c.where+'"');
'@ @'
     if(!/Error|probe\.js|:\d+:\d+/.test(c.where||'')) bad.push('the entry carries no stack and no file: "'+c.where+'"');   // v14.64: a line and column location counts (v14.51)
'@
SubRx @'
     for(var i=0;i<20;i++) fire('probe distinct '+i+' 4242');
     if(P2.crashes.length>12) bad.push('the list grew to '+P2.crashes.length+', past twelve');
     var newest=P2.crashes[P2.crashes.length-1]||{};
     if(newest.msg!=='probe distinct 19 4242') bad.push('the cap dropped the newest entry rather than the oldest: last is "'+newest.msg+'"');
'@ @'
     // v14.64: the probes differ in a letter, because since v14.49 messages differing only in a number are one crash.
     for(var i=0;i<20;i++) fire('probe distinct '+String.fromCharCode(97+i)+' 4242');
     if(P2.crashes.length>12) bad.push('the list grew to '+P2.crashes.length+', past twelve');
     var newest=P2.crashes[P2.crashes.length-1]||{};
     if(newest.msg!=='probe distinct t 4242') bad.push('the cap dropped the newest entry rather than the oldest: last is "'+newest.msg+'"');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
