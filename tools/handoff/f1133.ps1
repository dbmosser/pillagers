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
  {v:'11.32',what:'Copy report reports a refused clipboard as a failure that names the Recorder, and reports success only when a copy command actually succeeded',
'@ @'
  {v:'11.33',what:'the player-facing word for the pack is BACKPACK, not bag: the title controls line, the empty-panel hint and the full-pack message; and none of the three old strings survives anywhere the player reads',
   run:function(){
     var bad=[];
     // ONE: the title controls line, which a player reads on every load.
     var title=document.getElementById('title');
     if(!title) return 'SKIP: no title element in this document';
     var tt=(title.textContent||'').replace(/\s+/g,' ');
     if(tt.indexOf('TAB backpack')<0) bad.push('the title controls line does not say "TAB backpack": '+tt.slice(0,120));
     if(tt.indexOf('TAB bag')>=0) bad.push('the title controls line still says "TAB bag"');
     // TWO: the old strings are gone from everywhere the player reads, source
     // included. The needles are assembled so this check does not match itself.
     var src=document.documentElement.innerHTML;
     var old1=['Bag is ','empty.'].join(''), old2=['Bag full ','('].join(''), old3=['TAB ','bag '].join('');
     if(src.indexOf(old1)>=0) bad.push('the old empty-panel hint "'+old1+'" is still in the build');
     if(src.indexOf(old2)>=0) bad.push('the old full-pack message "'+old2+'" is still in the build');
     if(src.indexOf(old3)>=0) bad.push('the old "'+old3+'" wording is still in the build');
     // CONTROL: the replacement is present, so the strings were rewritten and
     // not merely deleted.
     var new1=['Backpack is ','empty.'].join('');
     if(src.indexOf(new1)<0) bad.push('control: the empty-panel hint was not rewritten to "'+new1+'", so it was removed rather than fixed');
     return bad.length?bad.join('; '):null; }},
  {v:'11.32',what:'Copy report reports a refused clipboard as a failure that names the Recorder, and reports success only when a copy command actually succeeded',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
