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

# ALL ON-SCREEN TEXT GOES INTO THE FEED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    G.lore=L={name:String(st.name||'').toUpperCase(),text:String(st.text||''),x:st.x,y:st.y,T:LORELIFE,at:G.t||0};
'@ @'
    G.lore=L={name:String(st.name||'').toUpperCase(),text:String(st.text||''),x:st.x,y:st.y,T:LORELIFE,at:G.t||0};
    // v28.xx (cw-feedall), HIS ORDER (2026-10-15): "All text shown to the player on screen also goes into the player feed." The lore card was the one text that never did (v22.xx R39 kept it out): its name is an objective line and its text a line under it.
    try{ if(L.name) feedAdd([{t:L.name,c:HUDC.warn}],'obj',{key:'lore:'+L.name}); if(L.text) feedAdd([{t:L.text,c:HUDC.text}],'info',{key:'loret:'+L.name,gl:''}); }catch(_lf){}
'@

SubRx @'
function cookShout(p){
'@ @'
// v28.xx (cw-feedall), HIS ORDER (2026-10-15): "All text shown to the player on screen also goes into the player feed." The last-second shout of a cooked grenade (cookShout) was drawn at the operator only; it is a danger line in the feed too, held on one key so a per-frame caller keeps one line.
function cookFeed(p){
  var s=cookShout(p);
  if(!s||!G||G.sim||!G.player) return null;
  return feedAdd([{t:s,c:HUDC.danger}],'danger',{key:'cookshout'});
}
function cookShout(p){
'@

SubRx @'
      var _cshout=cookShout(p);
'@ @'
      var _cshout=cookShout(p);
      try{ cookFeed(p); }catch(_cfd){}   // v28.xx (cw-feedall): the shout is in the feed too
'@

SubRx @'
  if((/^(WEAK SPOT|ACTIVE RELOAD|PICKED UP|CLOSE CALL|NOTORIETY \+\d+)$/).test(s)||(/ (DESTROYED|ELIMINATED)$/).test(s)||feedPwrOf(s)) return null;
'@ @'
  // v28.xx (cw-feedall), HIS ORDER (2026-10-15): "All text shown to the player on screen also goes into the player feed." ACTIVE RELOAD and a CLOSE CALL label with no score on it (a raid with no points) were skipped; they are lines now. WEAK SPOT (a hit mark), PICKED UP (the pickup row) and NOTORIETY +n (its own NOTORIETY line) stay out, and a kill has its own kill line.
  if((/^(WEAK SPOT|PICKED UP|NOTORIETY \+\d+)$/).test(s)||(/ (DESTROYED|ELIMINATED)$/).test(s)||feedPwrOf(s)) return null;
'@

SubRx @'
var VER='29.02';
'@ @'
var VER='29.03';
'@

$pat = "(?m)^  now:'v29\.02:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.03: The story card, a cooked grenade shout, ACTIVE RELOAD and CLOSE CALL also show in the feed. Check 29.03 fails on v29.02',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
