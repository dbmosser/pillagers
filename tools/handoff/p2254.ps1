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

# PICKUP ROWS SAY WHERE IT WENT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function autoBelt(key){
'@ @'
// v22.54, the raid text rewrite (R17): WHERE IT WENT IS THE PICKUP ROW'S TAG. BELTAT is where the last autoBelt call put the item:
// the belt key index, -2 for the backpack (no free key), -1 for nowhere new. A quiet call (the loot grant) says nothing; the grant
// writes beltTag() on the item's row in the pickup stack instead.
var BELTAT=-1;
function beltTag(){ return (BELTAT>=0)?('SLOT '+(BELTAT+1)):(BELTAT===-2?'BACKPACK':''); }
function autoBelt(key,quiet){
  BELTAT=-1;
'@

SubRx @'
        say(_gbTxt);
'@ @'
        BELTAT=gi; if(!quiet) say(_gbTxt);
'@

SubRx @'
    say(_gfTxt,'info',{sub:(it.name+' in backpack').toUpperCase()});
'@ @'
    BELTAT=-2; if(!quiet) say(_gfTxt,'info',{sub:(it.name+' in backpack').toUpperCase()});
'@

SubRx @'
      say(_beltTxt);
'@ @'
      BELTAT=bi; if(!quiet) say(_beltTxt);
'@

SubRx @'
        say(_svTxt);
'@ @'
        BELTAT=_svi; if(!quiet) say(_svTxt);
'@

SubRx @'
    say('NO FREE KEY','info',{sub:String(it.name).toUpperCase()});
'@ @'
    BELTAT=-2; if(!quiet) say('NO FREE KEY','info',{sub:String(it.name).toUpperCase()});
'@

SubRx @'
  var _gunLine='', _beltKeep=[], _beltGot; _lootSub='';
'@ @'
  var _gunLine='', _beltKeep=[], _beltGot, _ptags=[]; _lootSub='';   // v22.54 (R17): _ptags, where each item went, for its pickup row
'@

SubRx @'
          _lootSub=(padOn()?padB('LB or RB to swap'):('Press '+keyLabel('Digit'+(_swk+1),String(_swk+1))+' to swap')).toUpperCase();
'@ @'
          _lootSub=(padOn()?padB('LB or RB to swap'):('Press '+keyLabel('Digit'+(_swk+1),String(_swk+1))+' to swap')).toUpperCase();
          _ptags[l]='SLOT '+(_swk+1);   // v22.54 (R17): the row says the slot it took, and that slot is the key that swaps to it
'@

SubRx @'
          _gunLine=found.name+' equipped'+(cmp>0?', +'+cmp+'% damage':'')+'.';
'@ @'
          _gunLine=found.name+' equipped'+(cmp>0?', +'+cmp+'% damage':'')+'.';
          _ptags[l]='IN HAND';   // v22.54 (R17)
'@

SubRx @'
        _beltGot=autoBelt(key); if(_beltGot) _beltKeep.push(_beltGot);
      }
    }
    else { G.bag.push(key); _beltGot=autoBelt(key); if(_beltGot) _beltKeep.push(_beltGot); }
'@ @'
        _beltGot=autoBelt(key,1); if(_beltGot) _beltKeep.push(_beltGot); if(beltTag()) _ptags[l]=beltTag();   // v22.54 (R17): said on its row, not as a line
      }
    }
    else { G.bag.push(key); _beltGot=autoBelt(key,1); if(_beltGot) _beltKeep.push(_beltGot); if(beltTag()) _ptags[l]=beltTag(); }
'@

SubRx @'
      for(var _pk=0;_pk<keys.length;_pk++) if(ITEMS[keys[_pk]]) say(ITEMS[keys[_pk]].name,'pick',{item:keys[_pk]});
      if(_gunLine) say(_gunLine,'info',_lootSub?{sub:_lootSub}:null);   // v22.43: the stowed gun and its swap key
'@ @'
      // v22.54, the raid text rewrite (R17): PICKUP ROWS SAY WHERE IT WENT. A gun into the free slot said SHOTGUN STOWED with PRESS 2
      // TO SWAP under it, a gun into his hands said its name equipped with a damage figure, a gun or a Stim on a belt key said
      // SHOTGUN ON KEY 3, and a full belt said GUN SLOTS FULL, each a second line about the same item in the middle of the screen,
      // queued behind the first and pushing other lines off. Where it went is now the dim caps tag on the item's own row in the
      // pickup stack: SLOT 2 (the slot is the key that swaps to it), IN HAND, or BACKPACK when no key was free. Nothing else is said.
      for(var _pk=0;_pk<keys.length;_pk++) if(ITEMS[keys[_pk]]) say(ITEMS[keys[_pk]].name,'pick',{item:keys[_pk],tag:_ptags[_pk]||''});
'@

SubRx @'
            if(_where) sayWhenFree(_where,'info',_lootSub?{sub:_lootSub}:null);   // v22.43: with the swap key under a stowed gun
'@ @'
            // v22.54 (R17): where it went is the tag on its pickup row, so no second line follows.
'@

SubRx @'
    say('Took '+it.name+' from '+nm+'.'); if(where) sayWhenFree(where);
'@ @'
    say('Took '+it.name+' from '+nm+'.');   // v22.54 (R17): where it went is the tag on its pickup row
'@

SubRx @'
      // v22.50 (R16): no Took line; openContainer above has put each item in the pickup stack.
      if(where) sayWhenFree(where);
'@ @'
      // v22.50 (R16): no Took line; openContainer above has put each item in the pickup stack.
      // v22.54 (R17): and where each went is the tag on its row, so no where line follows.
'@

SubRx @'
var VER='22.53';
'@ @'
var VER='22.54';
'@

$pat = "(?m)^  now:'v22\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.54: A pickup row says where the item went: SLOT 2, IN HAND or BACKPACK. Check 22.54 fails on v22.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
