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

# v13.25 CHECK, inserted before the v13.24 entry.
#
# IT READS THE LIST, NOT THE PAGE, so the phrases below are data and not a page
# search that would find its own needles.
#
# THE RULE THAT STAYS TRUE, rather than one exact sentence: no entry may promise
# that Escape keeps fullscreen unless it also says that only holds with the game in
# its own tab. A future rewording of the line passes as long as it stays honest.
SubRx @'
  {v:'13.24',what:'finding a better gun with the second slot free tells you to swap to it on the tactical belt, not to press X, which searches',
'@ @'
  {v:'13.25',what:'the what-is-new card no longer promises Escape keeps fullscreen where it cannot: an entry about Escape and fullscreen says it only holds in the game own tab, and what happens inside another page such as itch (his report of 2026-09-12)',
   run:function(){
     if(typeof WHATSNEW==='undefined') return 'SKIP: this build has no what-is-new card';
     var bad=[], about=0, honest=0;
     for(var i=0;i<WHATSNEW.length;i++){
       var t=String(WHATSNEW[i]), u=t.toUpperCase();
       if(u.indexOf('ESC')<0||u.indexOf('FULLSCREEN')<0) continue;
       about++;
       var qualified=(u.indexOf('OWN TAB')>=0)||(u.indexOf('ANOTHER PAGE')>=0);
       if(u.indexOf('NO LONGER DROPS YOU OUT OF FULLSCREEN')>=0&&!qualified)
         bad.push('the card still promises that Escape no longer drops you out of fullscreen, and on itch, where every friend plays, it does, so the one line about it is false in exactly the place it is read');
       if(qualified) honest++;
     }
     if(about&&!honest)
       bad.push('no entry about Escape and fullscreen says what happens when the game is played inside another page, so a player on itch is told nothing true about the key he reported');
     return bad.length?bad.join('; '):null; }},
  {v:'13.24',what:'finding a better gun with the second slot free tells you to swap to it on the tactical belt, not to press X, which searches',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
