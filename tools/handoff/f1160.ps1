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

# v11.60 CHECK, inserted before the v11.59 entry. The stale phrase is assembled
# so this check never matches its own text.
SubRx @'
  {v:'11.59',what:'a name with a character above U+00FF (a curly quote, an emoji) still gets a restore code and the code reads back the same name; a plain code written before this build still reads',
'@ @'
  {v:'11.60',what:'the in-raid notoriety banner at two or more names what notoriety costs rather than claiming the Peddler has shut his stall, which never shuts',
   run:function(){
     if(typeof notoBite!=='function'||typeof pedOpen!=='function') return 'SKIP: no notoriety banner in this build';
     if(!pedOpen()) return 'SKIP: the stall shuts in this build, so the old line would be true';
     var bad=[], stale=['done with',' you'].join(''), b1=String(notoBite(1)), b2=String(notoBite(2)), b3=String(notoBite(3));
     if(b2.indexOf(stale)>=0) bad.push('at notoriety 2 the banner says "'+b2+'" while the stall stays open');
     if(b3.indexOf(stale)>=0) bad.push('at notoriety 3 the banner says "'+b3+'" while the stall stays open');
     if(b2.indexOf('Hiring')<0) bad.push('at notoriety 2 the banner does not name the hiring cost: "'+b2+'"');
     if(b1.indexOf('Hiring')<0) bad.push('control: at notoriety 1 the banner does not name the hiring cost: "'+b1+'"');
     return bad.length?bad.join('; '):null; }},
  {v:'11.59',what:'a name with a character above U+00FF (a curly quote, an emoji) still gets a restore code and the code reads back the same name; a plain code written before this build still reads',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
