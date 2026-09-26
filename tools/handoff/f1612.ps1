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

if ($s.Contains("  {v:'16.12',what:")) { throw "check 16.12 is in the fixture already" }

SubRx @'
  {v:'16.11',what:
'@ @'
  {v:'16.12',what:'the what is new card fits again and says what is true: the co-op entry says world sound plays from one window, not that the second has its own; the lightning line names the enemy',
   run:function(){
     if(!window.__words||typeof __words.whatsnew!=='function') return 'SKIP: this build cannot report its card';
     var wn=__words.whatsnew(), bad=[], L=wn.lines||[], all=L.join(' ').toUpperCase();
     if(all.indexOf('WITH ITS OWN CONTROLLER AND SOUND')>=0) bad.push('the card still says the second window has its own sound');
     if(all.indexOf('SOUND PLAYS FROM ONE OF THE TWO')<0) bad.push('the card does not say world sound plays from one window');
     if(all.indexOf('SHOWS YOU TO THE ENEMY')<0) bad.push('the lightning line does not name who the flash shows you to');
     return bad.length?bad.join('; '):null; }},
  {v:'16.11',what:
'@


$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
