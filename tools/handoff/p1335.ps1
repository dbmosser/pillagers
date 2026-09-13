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

# WHERE A LOOTED ITEM WENT WAS WRITTEN OVER BY "TOOK X." IN THE SAME FRAME.
#
# Found by the 2026-09-13 read-only hunt, confirmed by two skeptics, reproduced live
# on v13.34: hold E at a box holding a Burst Carbine with the second slot free; the
# carbine went to gun slot 2 and the only message shown was "Took Burst Carbine
# (field)."
#
# One updatePlayer call does all of it: the staged pull (openContainer(near,[_k]))
# reaches grantLoot, which builds the gun line (v12.73, v13.24) or lets autoBelt say
# the belt-key line, then says the gun line or "Found: X"; back in updatePlayer the
# pull says "Took X." say() keeps one line, so only Took ever reached the screen.
#
# FIX: autoBelt hands back the belt line it said; grantLoot collects it with its gun
# line and returns them; openContainer passes that back to the staged pull, which
# says Took as before and then sends the kept line through sayWhenFree, so it waits
# behind Took instead of being lost. No wording changes and no numbers move. The
# bot, the Peddler, and the full open at the end of the search ignore the new
# return value. Drafted by the fix-plan workflow and passed by its reviewer.
SubRx @'
  if(onlyKeys){ grantLoot(ct,onlyKeys); return; }
'@ @'
  if(onlyKeys) return grantLoot(ct,onlyKeys);   // v13.35: hands back where the item went, for the staged pull to show after Took
'@

SubRx @'
  var _gunLine='';
'@ @'
  // v13.35, 2026-09-13 hunt: WHERE IT WENT IS HANDED BACK. The belt line autoBelt
  // writes below is written over by the Found line in this same frame, and on a
  // staged pull the caller then writes Took over whatever is left, the gun line
  // included. Both are collected here and returned, and the staged pull in
  // updatePlayer queues them behind its Took line.
  var _gunLine='', _beltKeep=[], _beltGot;
'@

SubRx @'
      } else { G.bag.push(key); autoBelt(key); }
    }
    else { G.bag.push(key); autoBelt(key); }
'@ @'
      } else { G.bag.push(key); _beltGot=autoBelt(key); if(_beltGot) _beltKeep.push(_beltGot); }
    }
    else { G.bag.push(key); _beltGot=autoBelt(key); if(_beltGot) _beltKeep.push(_beltGot); }
'@

SubRx @'
    ping(p.x,p.y,90,false,false,'player','move');
  }
}
// Three-phase extract
'@ @'
    ping(p.x,p.y,90,false,false,'player','move');
  }
  // v13.35: empty unless something went into a hand or onto a belt key.
  return _beltKeep.length?((_gunLine?_gunLine+' ':'')+_beltKeep.join(' ')):_gunLine;
}
// Three-phase extract
'@

SubRx @'
      say(it.name+' to belt slot '+(bi+1)+'.');
      return;
'@ @'
      var _beltTxt=it.name+' to belt slot '+(bi+1)+'.';
      say(_beltTxt);
      // v13.35: handed back as well, because the loot grant writes its Found line over this one.
      return _beltTxt;
'@

SubRx @'
          openContainer(near,[_k]);
'@ @'
          var _where=openContainer(near,[_k]);   // v13.35: the gun slot or belt key it took, if any
'@

SubRx @'
            say('Took '+ITEMS[_k].name+'.');
'@ @'
            say('Took '+ITEMS[_k].name+'.');
            // v13.35, 2026-09-13 hunt: Took was the last word in the frame, written over
            // the line naming the gun slot or belt key the item had just taken, so that
            // line never showed. It now waits its turn behind Took.
            if(_where) sayWhenFree(_where);
'@

SubRx @'
var VER='13.34';
'@ @'
var VER='13.35';
'@

$pat = "(?m)^  now:'v13\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.35: WHERE A LOOTED ITEM WENT WAS WRITTEN OVER BY TOOK IN THE SAME FRAME. Found by a read-only hunt, confirmed by two skeptics and reproduced live on v13.34: holding E at a box with a Burst Carbine in it and the second slot free put the carbine in gun slot 2, and the only line on screen was Took Burst Carbine. One update did all of it: the staged pull reached grantLoot, which built the line saying the gun went to the empty slot and how to swap to it, or let autoBelt say which tactical belt key an item took, then said that line or the Found line; back in the search the pull then said Took, and say keeps one line, so only Took was ever drawn. autoBelt now hands back the belt line, grantLoot returns it with its gun line, and the staged pull says Took as before and sends the kept line through sayWhenFree, so it waits behind Took instead of being lost. No wording changes and no numbers move; the bot, the Peddler and the full open at the end of a search ignore the new return value. Check 13.35 holds X at a real box through the frame loop, once for the best gun with the second slot free and once for a stim with free belt keys, reads the message line after whole frames, requires each where-it-went line to reach the screen, and fails on v13.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
