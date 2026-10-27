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

# ITCH: NEW PLAYER DEFAULTS AND A DIFFICULTY ROW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
})();// v10.28: which option the LIVE dials match, or -1 when a slider has put them
'@ @'
})();
// v28.xx (cw-itcheasy), HIS ORDERS 2026-10-26: "when you put the new one to itch, make it so that it defaults to the easiest settings
// (except kid mode), so noobs can play it and not be overwhelmed", then "I want visible settings for all this stuff so that a itch player
// can make the game as difficult as the other/main game". On itch (the page runs on itch.zone / hwcdn.net inside the itch.io frame) a
// profile with no saved choice starts on the NEW PLAYER set: forgiving hits, the long raid, rich loot, light shake, the large crosshair
// and seven extras off. Only the row defaults move, so a saved choice always wins and every single row stays visible and changeable.
// The DIFFICULTY row at the top of THE RAID switches all twelve at once between NEW PLAYER and MAIN GAME (his PC, the party copy and
// stable boot on MAIN GAME, exactly as before); a hand change to any one row reads CUSTOM there.
function itchHost(h){ return /(^|\.)(itch\.zone|itch\.io|hwcdn\.net)$/i.test(h||''); }
var ON_ITCH=(function(){ try{ return itchHost(location.hostname)||window.__itchTest===1; }catch(_e){ return false; } })();
var DIFF_KEYS=['hits','clock','loot','shake','xhSz','xfAffix','xfRamp','xfOvPh','xfEvRamp','xfEvBounty','xfEvDebris','xfSupp'];
var ITCH_EASY={hits:3,clock:0,loot:0,shake:1,xhSz:2,xfAffix:1,xfRamp:1,xfOvPh:1,xfEvRamp:1,xfEvBounty:1,xfEvDebris:1,xfSupp:1};
var MAIN_GAME={hits:2,clock:1,loot:1,shake:2,xhSz:1,xfAffix:0,xfRamp:0,xfOvPh:0,xfEvRamp:0,xfEvBounty:0,xfEvDebris:0,xfSupp:0};
function itchDefs(on){
  var i, r, t=on?ITCH_EASY:MAIN_GAME;
  for(i=0;i<GAMEOPTS.length;i++){ r=GAMEOPTS[i]; if(DIFF_KEYS.indexOf(r.k)>=0&&typeof t[r.k]==='number') r.def=t[r.k]; }
}
if(ON_ITCH) itchDefs(1);
function diffNow(){
  var e=true, m=true, i, v;
  for(i=0;i<DIFF_KEYS.length;i++){ v=gameOptLive(DIFF_KEYS[i]); if(v!==ITCH_EASY[DIFF_KEYS[i]]) e=false; if(v!==MAIN_GAME[DIFF_KEYS[i]]) m=false; }
  return e?'new player':(m?'main game':'custom');
}
function diffRowHtml(){
  var d=diffNow(), home=ON_ITCH?'new player':'main game';
  return '<div class="row"><div style="flex:1"><b>difficulty</b><div class="hint">new player: softer hits, longer raids, more loot, fewer extras</div></div>'+
    '<button id="set_diff" style="padding:6px 12px;min-width:92px'+(d===home?'':';color:var(--amber)')+'">'+d+'</button></div>';
}
function diffSet(t){
  var i, k, row, oi, o, tk=tunedKeys();
  P.gameOpts=P.gameOpts||{};
  for(i=0;i<DIFF_KEYS.length;i++){
    k=DIFF_KEYS[i]; P.gameOpts[k]=t[k];
    for(row=null,oi=0;oi<GAMEOPTS.length;oi++) if(GAMEOPTS[oi].k===k) row=GAMEOPTS[oi];
    if(row) for(oi=0;oi<row.opts.length;oi++) for(o in row.opts[oi].cfg) delete tk[o];
  }
  applyGameOpts(); saveProfile();
}
// v10.28: which option the LIVE dials match, or -1 when a slider has put them
'@

SubRx @'
  _SEC['THE RAID']=(_SEC['THE RAID']||'')+expRowHtml();   // v32.xx (cw-expmenu2): the open row ends THE RAID, where the features it switches are
'@ @'
  _SEC['THE RAID']=diffRowHtml()+(_SEC['THE RAID']||'')+expRowHtml();   // v32.xx (cw-expmenu2): the open row ends THE RAID, where the features it switches are; v28.xx (cw-itcheasy): the difficulty row heads it
'@

SubRx @'
  var _eo=document.getElementById('exp_open');
'@ @'
  var _sd=document.getElementById('set_diff');   // v28.xx (cw-itcheasy)
  if(_sd) _sd.onclick=function(){ var _rs0=CFG.raidSec; diffSet(diffNow()==='new player'?MAIN_GAME:ITCH_EASY); gameOptRaidNow(_rs0); renderSettings(); };
  var _eo=document.getElementById('exp_open');
'@

SubRx @'
var VER='34.91';
'@ @'
var VER='34.92';
'@

$pat = "(?m)^  now:'v34\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.92: On itch: the new player set, and the difficulty row puts the main game back in one click. Everywhere else: the main game, with the same row. Check 34.92 fails on v34.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
