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

# SELL ALL FROM THE ITEM MENU (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      P.stash.splice(ix,1); clearKeysFor(key); P.credits+=ival(key); P.xp=(P.xp||0)+ival(key); syncXpLevel(); saveProfile(); refreshInv();
    }});
  }
  return rows;
'@ @'
      P.stash.splice(ix,1); clearKeysFor(key); P.credits+=ival(key); P.xp=(P.xp||0)+ival(key); syncXpLevel(); saveProfile(); refreshInv();
    }});
    // v24.xx (sellall), HIS ANSWER 24 (2026-10-12): "right click and choose sell". A stack sells whole from the same menu: Sell all N
    // under Sell one, priced on the row, same pay (credits and XP at the plain price). N is the stack the cell shows, so copies packed
    // in the backpack stay packed. Stash screen only, as Sell one.
    var _sn=Math.min(count||1,held);
    if(ctx==='stash'&&_sn>1&&_hbS&&_hbS.classList.contains('on')) rows.push({label:'Sell all '+_sn,hint:'$'+(ival(key)*_sn).toLocaleString(),act:function(){
      var got=0, ix2;
      for(var q=0;q<_sn;q++){ ix2=P.stash.indexOf(key); if(ix2<0) break; P.stash.splice(ix2,1); got++; }
      if(!got) return;
      clearKeysFor(key); P.credits+=ival(key)*got; P.xp=(P.xp||0)+ival(key)*got; syncXpLevel(); saveProfile(); refreshInv();
    }});
  }
  return rows;
'@

SubRx @'
var VER='24.27';
'@ @'
var VER='24.28';
'@

$pat = "(?m)^  now:'v24\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.28: Right-click a stack in the stash and choose Sell all to sell the whole stack at once. Check 24.28 fails on v24.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
