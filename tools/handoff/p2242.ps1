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

# A STIM KEEPS ITS KEY WHEN THE PLATE TAKES KEY 9 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(pax<GUNKEYS&&ITEMS[G.hotAssign[pa]]&&ITEMS[G.hotAssign[pa]].use==='gun') continue;   // v21.83: a gun pin on a gun key never yields
      if(pax>=0&&pax<out.length&&out[pax].kind!=='empty'){
        var nix=-1;
        for(var ni=out.length-1;ni>=0;ni--)
          if(out[ni].kind==='empty'&&G.hotAssign[ni]===undefined){ nix=ni; break; }
'@ @'
      if(pax<GUNKEYS&&ITEMS[G.hotAssign[pa]]&&ITEMS[G.hotAssign[pa]].use==='gun') continue;   // v21.83: a gun pin on a gun key never yields
      if(pax<GUNKEYS&&out[pax]&&out[pax].gunFill) continue;   // v22.42: nor any pin on a gun key no gun took (the fill comes after)
      if(pax>=0&&pax<out.length&&out[pax].kind!=='empty'){
        var nix=-1;
        for(var ni=out.length-1;ni>=0;ni--)
          if(out[ni].kind==='empty'&&G.hotAssign[ni]===undefined){ nix=ni; break; }
        // v22.42, from the review of the four-gun belt (build 3): AN AUTOMATIC PIN WITH NO EMPTY KEY LEFT TAKES A FREE GUN KEY 3 OR 4,
        // instead of vanishing. With four gun keys, three throws and Medical, key 9 is the only empty key, and the plate takes it the
        // moment he picks a plate up: a Stim pinned there found no empty key, its pin was deleted, and the Stim left the belt.
        if(nix<0) for(ni=GUNKEYS-1;ni>=2;ni--) if(G.hotAssign[ni]===undefined){ nix=ni; break; }
'@

SubRx @'
      var _beltTxt=it.name+' to belt slot '+(bi+1)+'.';
      say(_beltTxt);
      // v13.35: handed back as well, because the loot grant writes its Found line over this one.
      return _beltTxt;
    }
  }
}
'@ @'
      var _beltTxt=it.name+' to belt slot '+(bi+1)+'.';
      say(_beltTxt);
      // v13.35: handed back as well, because the loot grant writes its Found line over this one.
      return _beltTxt;
    }
  }
  // v22.42, from the review of the four-gun belt (build 3): A STIM WITH NO EMPTY KEY TAKES A VACANT GUN KEY 3 OR 4. Carrying a plate
  // (the freebie kit always has one), key 9 is the plate and no key is empty, so a Stim found or paid at a revive got no key and no
  // line. It goes on the highest vacant gun key (any item may go on a gun key, decision D2); with none it says so.
  if(it.use==='stim'&&!G.hubFloor){
    for(var _svi=GUNKEYS-1;_svi>=2;_svi--){
      if(G.hotAssign[_svi]===undefined&&slots[_svi]&&slots[_svi].vacant){
        G.hotAssign[_svi]=key; G.hotAuto=G.hotAuto||{}; G.hotAuto[_svi]=1;
        var _svTxt=it.name+' to belt slot '+(_svi+1)+'.';
        say(_svTxt);
        return _svTxt;
      }
    }
    say('NO FREE KEY','info',{sub:String(it.name).toUpperCase()});
  }
}
'@

SubRx @'
var VER='22.41';
'@ @'
var VER='22.42';
'@

$pat = "(?m)^  now:'v22\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.42: A Stim keeps a belt key when you carry an Armour Plate: it goes on a free gun key 3 or 4. Check 22.42 fails on v22.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
