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

if ($s.Contains("  {v:'16.88',what:")) { throw "check 16.88 is in the fixture already" }

SubRx @'
  {v:'16.87',what:
'@ @'
  {v:'16.88',what:'the what is new card is current again: within fifteen builds, the co-op line still second, then his playtest line naming the controller layout, kid firing and the new kit answers, and no retired word on the lines the card draws',
   run:function(){
     if(!window.__words||typeof __words.whatsnew!=='function') return 'SKIP: this build cannot report its card';
     var wn=__words.whatsnew(), bad=[], L=wn.lines||[];
     var vNow=parseFloat(String(wn.build||'0').replace(/[^0-9.]/g,''))||0;
     var vCard=parseFloat(String(wn.ver||'0').replace(/[^0-9.]/g,''))||0;
     if(!(vNow&&vCard)) return 'SKIP: no version on the card or the build';
     if(vCard>16.88+0.001) return 'SKIP: the card has moved on to v'+wn.ver+', a later card check covers it';
     if(vNow-vCard>0.15) bad.push('the card is at v'+wn.ver+' against a build at v'+wn.build+', more than fifteen builds behind');
     var a=String(L[2]||'').toUpperCase();
     ['A ROLLS','B CROUCHES','RT FIRES','KID FIRING','TOP GEAR','RANDOM FROM STASH','PATCHES UP A TEAMMATE'].forEach(function(w){ if(a.indexOf(w)<0) bad.push('the playtest line does not say '+w.toLowerCase()); });
     if(String(L[1]||'').toUpperCase().indexOf('YOUR PARTY GOES UP TOGETHER')<0) bad.push('the co-op line is no longer second');
     if((/\bbag\b|hotbar|touchdown|boarding|\bship\b|wardrobe/i).test(L.slice(0,13).join(' '))) bad.push('the card draws a retired word');
     return bad.length?bad.join('; '):null; }},
  {v:'16.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
