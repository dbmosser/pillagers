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

# AN EMPTY MAGAZINE IS HALF GREY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      var empty=(S.count===0);
'@ @'
      var empty=(S.count===0);
      // v24.xx (beltgrey), HIS ORDER (2026-10-12): "guns on quickbar/belot should grey out only half way if they are out of magazine
      // ammo but player has ammo to reload the gun -- should only fully grey out if they are completely out of ammo". A gun key with an
      // empty magazine was greyed exactly like a gun with nothing left, so a gun one reload from firing read as dead. Three states now:
      // rounds in its magazine, full colour; an empty magazine while he carries rounds it can load (the one shared pool, p.reserve, or an
      // ammo box in the backpack, which is how the Undercroft belt carries packed ammo), HALF grey, with the 0 in the amber of the RELOAD
      // reticle; no rounds anywhere, fully grey as before. Every gun cell: in hand, stowed, a backpack gun on a gun key, the floor belt.
      // A gun with no magazine (melee) has no count and never greys. Derived every frame, so a pickup, a reload or the last shot shows
      // at once.
      var _bgHalf=false;
      if(empty&&S.kind==='gun'&&!S.vacant&&S.icon){
        var _bgP=G.player, _bgN=(_bgP&&+_bgP.reserve)||0, _bgi, _bgI;
        for(_bgi=0;_bgN<=0&&G.bag&&_bgi<G.bag.length;_bgi++){ _bgI=ITEMS[G.bag[_bgi]]; if(_bgI&&_bgI.use==='ammo') _bgN+=(_bgI.amt||1); }
        _bgHalf=_bgN>0;
      }
      var _bgDim=empty&&!_bgHalf;
'@

SubRx @'
if(_hr&&!empty){ var _hf=rfill(_hr); if(_hf){ ctx.fillStyle=_hf; ctx.fillRect(bx,hy,bw,bw); } }
'@ @'
if(_hr&&!_bgDim){ var _hf=rfill(_hr); if(_hf){ ctx.fillStyle=_hf; if(_bgHalf) ctx.globalAlpha=.5; ctx.fillRect(bx,hy,bw,bw); ctx.globalAlpha=1; } }   // v24.xx (beltgrey): a reloadable gun keeps half its wash
'@

SubRx @'
(_hr&&RCOL[_hr]&&!empty)?hexA(RCOL[_hr],.55)
'@ @'
(_hr&&RCOL[_hr]&&!_bgDim)?hexA(RCOL[_hr],.55)
'@

SubRx @'
ctx.globalAlpha=empty?.28:1;
'@ @'
ctx.globalAlpha=_bgDim?.28:(_bgHalf?.64:1);   // v24.xx (beltgrey): half grey while it can be reloaded
'@

SubRx @'
ctx.fillStyle=empty?'#7a5040':'#FFF6DC';
'@ @'
ctx.fillStyle=_bgDim?'#7a5040':(_bgHalf?'#ffc04a':'#FFF6DC');   // v24.xx (beltgrey): an empty magazine he can reload says 0 in the RELOAD amber
'@

SubRx @'
var VER='25.54';
'@ @'
var VER='25.55';
'@

$pat = "(?m)^  now:'v25\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.55: A gun with an empty magazine and ammo to reload is now half grey on the belt; fully grey only when all ammo is gone. Check 25.55 fails on v25.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
