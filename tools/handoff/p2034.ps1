$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# A GUN DROPPED FOR THE PARTY IS THEIRS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(_q&&netSend(_q,{t:'pile',k:key,x:Math.round(p.x),y:Math.round(p.y),ib:_ib})){ if(_ib){ G.issuedBandages--; if(G.bandSeen!==undefined) G.bandSeen--; } return key; }
'@ @'
    if(_q&&netSend(_q,{t:'pile',k:key,x:Math.round(p.x),y:Math.round(p.y),ib:_ib})){
      if(_ib){ G.issuedBandages--; if(G.bandSeen!==undefined) G.bandSeen--; }
      // v20.34, from the whole-game bug hunt of 2026-10-08 (H23): AN ARMOURY GUN DROPPED FOR THE PARTY IS THE PARTY'S NOW. The pile
      // is the host's, so whoever searches it banks the gun, but this window still had the gun on its list of armoury guns carried
      // up, and an abandon put it back in this armoury: one gun in two saves. It comes off the list at the drop, as a gift does.
      var _gk=(/^gun_/.test(key)&&ITEMS[key]&&ITEMS[key].gk)?ITEMS[key].gk:null, _j;
      if(_gk){ _j=(G.spliced||[]).indexOf(_gk); if(_j>=0) G.spliced.splice(_j,1); if(P.raidSpliced){ _j=P.raidSpliced.indexOf(_gk); if(_j>=0) P.raidSpliced.splice(_j,1); } try{ saveProfile(); }catch(_sp){} }
      return key;
    }
'@

SubRx @'
var VER='20.33';
'@ @'
var VER='20.34';
'@

$pat = "(?m)^  now:'v20\.33:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.34: In co-op, an armoury gun you drop for the other player is no longer copied back into your armoury. Check 20.34 fails on v20.33',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
