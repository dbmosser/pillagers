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

if ($s.Contains("  {v:'16.65',what:")) { throw "check 16.65 is in the fixture already" }

SubRx @'
  {v:'16.64',what:
'@ @'
  {v:'16.65',what:'player text tells the truth in his words: the PARTY window says the party ascends into the same raid, and the what is new card uses no retired word',
   run:function(){
     var pm=document.getElementById('partymodal'), bad=[], t, all;
     if(!pm||typeof WHATSNEW==='undefined') return 'SKIP: this build has no PARTY window or no card';
     t=String(pm.textContent||'');
     if(t.indexOf('played alone')>=0) bad.push('the PARTY window still says every raid is played alone');
     if(t.indexOf('same raid')<0) bad.push('the PARTY window does not say the party ascends into the same raid');
     all=WHATSNEW.slice(0,13).join(' ');   // the thirteen lines the card draws
     if((/wardrobe/i).test(all)) bad.push('the card says wardrobe, a word he retired');
     if((/\bbag\b|hotbar|touchdown|boarding|\bship\b/i).test(all)) bad.push('the card uses a retired word');
     if((/kit at the lift/i).test(all)) bad.push('the card says every player chooses a kit at the lift, which the quick ascent does not do');
     return bad.length?bad.join('; '):null; }},
  {v:'16.64',what:
'@

# The party line now says chooses a kit when the party ascends; check 16.54 reads the new words.
SubRx @'
     ['KIT AT THE LIFT','PING','MARKER','KILL FEED','KID MODE']
'@ @'
     ['CHOOSES A KIT','PING','MARKER','KILL FEED','KID MODE']
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
