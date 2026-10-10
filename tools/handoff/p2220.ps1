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

# PLAYER 2 HEARS THE PILLBOX, PEDDLER AND SURVIVOR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(_cd2<e.rng&&!e.sang){ e.sang=1; if(!G.sim){ say('THE PILLBOX HAS SEEN YOU.'); sfx('dish',e.x,e.y); } }
'@ @'
      // v22.20, from the whole-game bug hunt of 2026-10-08 (K31): SAID TO THE PLAYER IT SAW. p is the nearest player, so when
      // player 2 walked into its reach the host was told, from across the map, and player 2 was told nothing. One of the party is
      // now told on his own window (netMarkTake), as the Crier and THE OVERSEER lines are (H11); the sound stays here, the relay
      // carries it.
      if(_cd2<e.rng&&!e.sang){ e.sang=1; if(!G.sim){ if(p&&p.net){ if(NET.on) netMarkSend({t:'mark',k:'pill',nid:e.nid|0,seat:p.seat|0}); } else say('THE PILLBOX HAS SEEN YOU.'); sfx('dish',e.x,e.y); } }
'@

SubRx @'
      if(!e.hailed&&pdd<240&&!G.sim&&canSee(p.x,p.y,p.face,e.x,e.y,G.vseg)){
        e.hailed=1;
        say(pedOpen()?'The Peddler waves you over.':'The Peddler turns his back on you.');
      }
'@ @'
      // v22.20 (K31): and the Peddler hails the player who walked up, on his own window, each player once (hailed for the host,
      // hailed1, hailed2 and so on for a seat), so player 2 reaching him first no longer spends the host greeting
      var _hk=(p&&p.net)?('hailed'+(p.seat|0)):'hailed';
      if(!e[_hk]&&pdd<240&&!G.sim&&canSee(p.x,p.y,p.face,e.x,e.y,G.vseg)){
        e[_hk]=1;
        if(p&&p.net){ if(NET.on) netMarkSend({t:'mark',k:'ped',nid:e.nid|0,seat:p.seat|0}); }
        else say(pedOpen()?'The Peddler waves you over.':'The Peddler turns his back on you.');
      }
'@

SubRx @'
      if(!e.found&&sdd<190&&!G.sim&&canSee(p.x,p.y,p.face,e.x,e.y,G.vseg)){
        e.found=1;
        say(e.helped?'The survivor is still there.'
          :('Someone is hiding in here. He needs a '+ITEMS[e.want].name.toLowerCase()+'.'));
        if(!e.helped) label(e.x,e.y-20,'NEEDS: '+ITEMS[e.want].name.toUpperCase(),'#7fc4a0',0,true);
        blip('pick',260);
      }
'@ @'
      if(!e.found&&sdd<190&&!G.sim&&canSee(p.x,p.y,p.face,e.x,e.y,G.vseg)){
        e.found=1;
        // v22.20 (K31): found by one of the party, the line is his, on his own window; the host, the one who can hand the item
        // over, is told a teammate found a survivor and what he needs, and keeps the map mark (found)
        if(p&&p.net){
          if(NET.on) netMarkSend({t:'mark',k:'sv',nid:e.nid|0,seat:p.seat|0,w:String(e.want||'')});
          if(!e.helped) say('TEAMMATE FOUND A SURVIVOR','obj',{sub:'Needs '+ITEMS[e.want].name});
        } else {
        say(e.helped?'The survivor is still there.'
          :('Someone is hiding in here. He needs a '+ITEMS[e.want].name.toLowerCase()+'.'));
        if(!e.helped) label(e.x,e.y-20,'NEEDS: '+ITEMS[e.want].name.toUpperCase(),'#7fc4a0',0,true);
        blip('pick',260);
        }
      }
'@

SubRx @'
  if(k==='big'){ if(mine&&!G.sim) say('Something very large has noticed you.'); return 'mark:big'; }
'@ @'
  if(k==='big'){ if(mine&&!G.sim) say('Something very large has noticed you.'); return 'mark:big'; }
  // v22.20, from the whole-game bug hunt of 2026-10-08 (K31): THE PILLBOX, THE PEDDLER AND THE SURVIVOR, told to the player who
  // walked up. The host sends these when one of the party is the player they saw (updateEnts); his own lines are said there.
  if(k==='pill'){ if(mine&&!G.sim) say('THE PILLBOX HAS SEEN YOU','warn'); return 'mark:pill'; }
  if(k==='ped'){ if(mine&&!G.sim) say(pedOpen()?'THE PEDDLER WAVES YOU OVER':'THE PEDDLER TURNS HIS BACK','ally'); return 'mark:ped'; }
  if(k==='sv'){
    if(e) e.found=1;   // so this window map shows the survivor too
    if(mine&&!G.sim){
      var _wk=netClean(m.w,24), _wn=(_wk&&Object.prototype.hasOwnProperty.call(ITEMS,_wk)&&ITEMS[_wk])?ITEMS[_wk].name:'';
      if(e&&e.helped) say('THE SURVIVOR IS STILL THERE','obj');
      else say('SURVIVOR FOUND','obj',{sub:_wn?('Needs '+_wn+'. Host hands it over.'):'Host hands it over.'});
      blip('pick',260);
    }
    return 'mark:sv';
  }
'@

SubRx @'
var VER='22.19';
'@ @'
var VER='22.20';
'@

$pat = "(?m)^  now:'v22\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.20: In co-op, the Pillbox warning, the Peddler greeting and the hidden Survivor line go to the player who walked up. Check 22.20 fails on v22.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
