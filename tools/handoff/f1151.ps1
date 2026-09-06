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

# v11.51 CHECK, inserted before the v11.50 entry. The sector keys hold a middot,
# so they are read from the shipped map at run time, never typed here.
SubRx @'
  {v:'11.50',what:'opening THE STASH with the Undercroft backpack open commits and closes the backpack first, so what you pack at the terminal is not overwritten by the stale backpack snapshot when it closes',
'@ @'
  {v:'11.51',what:'the two baked sector-facts lines are exact-only: the line with its own figures still maps to his wording, and a sector line with other figures is left as the game drew it instead of being rewritten by digit shape into the other map name',
   run:function(){
     if(!(window.__tx&&__tx.get&&__tx.ship)) return 'SKIP: this build has no text engine to drive';
     var ship=__tx.ship(), keys=[], k;
     for(k in ship) if(k.indexOf('test robot extracts')>=0) keys.push(k);
     if(keys.length<2) return 'SKIP: the baked map holds '+keys.length+' sector-facts lines, not both';
     var bad=[];
     for(var i=0;i<keys.length;i++){
       var key=keys[i];
       // The exact line still maps to his wording.
       if(__tx.get(key)!==ship[key]) bad.push('the exact sector line no longer maps to his wording');
       // A line with other figures, as the game draws it for another player or
       // another day, must pass through untouched.
       var mut=key.replace(/\d+/, function(d){ return String((+d)+7); });
       if(mut===key) continue;
       var got=__tx.get(mut);
       if(got!==mut) bad.push('a sector line with other figures was rewritten by digit shape into "...'+String(got).slice(-34)+'", so one map can print the other map name');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.50',what:'opening THE STASH with the Undercroft backpack open commits and closes the backpack first, so what you pack at the terminal is not overwritten by the stale backpack snapshot when it closes',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
