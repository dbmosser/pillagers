$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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
      if(P.merc===id){ return; }
      if(P.credits<cost) return;
      P.credits-=cost; P.merc=id; saveProfile(); renderMerc(); renderHub();
'@ @'
      if(P.merc===id){ return; }
      // v14.15, Undercroft audit finding 1: A SECOND HIRE DOES NOT EAT THE FIRST FEE. With someone hired, clicking another
      // row charged the new fee and replaced the hire, so the first fee was gone with no question asked, while Hire nobody
      // asks first because that fee is not refunded (v8.17). And a row he could not afford answered the click with nothing.
      var _mt='that one', _cur='your hire';
      for(var _mi=0;_mi<IDENTITIES.length;_mi++){
        if(IDENTITIES[_mi].id===id) _mt=IDENTITIES[_mi].tag||_mt;
        if(P.merc&&IDENTITIES[_mi].id===P.merc) _cur=IDENTITIES[_mi].tag||_cur;
      }
      if(P.merc){ say2(_cur+' is already hired. Press Hire nobody first; that fee is not refunded.'); try{ sfx('clank'); }catch(e){} return; }
      if(P.credits<cost){ say2('Not enough credits to hire '+_mt+'.'); try{ sfx('clank'); }catch(e){} return; }
      P.credits-=cost; P.merc=id; saveProfile(); renderMerc(); renderHub();
'@
SubRx @'
var VER='14.14';
'@ @'
var VER='14.15';
'@

$pat = "(?m)^  now:'v14\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.15: A SECOND HIRE DOES NOT EAT THE FIRST FEE. With someone hired, clicking another row on the hire bench charged the new fee and replaced the hire, so the first fee was gone with no question, and a row he could not afford said nothing. Now a second row leaves the credits and the hire alone and says to press Hire nobody first, and a short row says there are not enough credits. Check 14.15 hires once, clicks a second row, then clicks with no credits; it fails on v14.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
