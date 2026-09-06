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

# THE RESTORE CODE LEFT THE ARMOURY BEHIND. The card promises "what you have
# unlocked" and the panel says REPLACES, and the maker (v11.03) carried the
# credits, the XP, the stash, the cosmetics and the junk, and not one gun: not
# the guns owned, not the one in hand, not the second slot, not the wear on
# any of them. A friend restored from his code came back with the fresh
# profile's Scav Pistol and nothing else. The code carries the armoury now,
# and applying it brings the guns back; an older code without that block
# leaves the guns as they are rather than stripping them.
SubRx @'
  for(var i=0;i<st.length;i++) o.s[st[i]]=(o.s[st[i]]||0)+1;
  return o;
}
'@ @'
  for(var i=0;i<st.length;i++) o.s[st[i]]=(o.s[st[i]]||0)+1;
  // v11.57: the armoury. Guns owned, the one in hand, the second slot, and the
  // rounds worn through each, which is what condition is made of.
  o.g={w:(P.weapons||[]).slice(),e:P.equipped||'fists',e2:P.equippedSec||'none',wr:{}};
  for(var wk in (P.wear||{})) if(P.wear[wk]) o.g.wr[wk]=P.wear[wk]|0;
  return o;
}
'@
SubRx @'
  P.stash=st;
  saveProfile();
  return true;
}
'@ @'
  P.stash=st;
  // v11.57: the armoury, when the code carries one. A gun this build does not
  // know is dropped, the same rule as the stash; an older code without the
  // block leaves the guns as they are rather than stripping them.
  if(o.g){
    var gw=[], gi, gl=(o.g.w||[]);
    for(gi=0;gi<gl.length;gi++) if(WEAPONS[gl[gi]]&&gl[gi]!=='fists'&&gw.indexOf(gl[gi])<0) gw.push(gl[gi]);
    P.weapons=gw;
    P.equipped=(o.g.e&&gw.indexOf(o.g.e)>=0)?o.g.e:'fists';
    P.equippedSec=(o.g.e2&&gw.indexOf(o.g.e2)>=0&&o.g.e2!==P.equipped)?o.g.e2:'none';
    P.wear={};
    for(var wk in (o.g.wr||{})) if(WEAPONS[wk]) P.wear[wk]=Math.max(0,o.g.wr[wk]|0);
  }
  saveProfile();
  return true;
}
'@
SubRx @'
  return o.n+', '+(o.r|0)+' raid'+((o.r|0)===1?'':'s')+', '+'$'+(o.c|0).toLocaleString()+
         ', '+(o.x|0).toLocaleString()+' XP, '+st+' item'+(st===1?'':'s')+' in the stash.';
'@ @'
  var ng=(o.g&&o.g.w)?o.g.w.length:0;
  return o.n+', '+(o.r|0)+' raid'+((o.r|0)===1?'':'s')+', '+'$'+(o.c|0).toLocaleString()+
         ', '+(o.x|0).toLocaleString()+' XP, '+st+' item'+(st===1?'':'s')+' in the stash'+
         (o.g?', '+ng+' gun'+(ng===1?'':'s'):'')+'.';
'@

# STAMPS.
SubRx @'
var VER='11.56';
'@ @'
var VER='11.57';
'@
SubRx @'
var WHATSNEW_VER='11.56';
'@ @'
var WHATSNEW_VER='11.57';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'YOUR RESTORE CODE NOW CARRIES YOUR GUNS. The code at the bottom of every run report promised what you had unlocked and left the armoury out: restored from it, you came back with a Scav Pistol. It carries every gun you own, the one in hand, the second slot and their wear now. Copy a fresh one.',
'@
$cnt=([regex]::Matches($s,"now:'v11\.56:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v11.56 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v11\.56:[^']*'",{ param($m) "now:'v11.57: the restore code left the armoury behind. restoreMake carried credits, XP, stash, cosmetics and junk and not one gun, while the card promised what you have unlocked and the panel said REPLACES; a friend restored from it came back with the fresh Scav Pistol. The code carries guns owned, the one in hand, the second slot and the wear on each now, applying it brings them back with unknown guns dropped, and an older code without the block leaves the guns as they are. From the v11.46 audit, P1.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
