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

# BACKPACK FULL IS ONE RED ROW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var q=(G.pick=G.pick||[]), now=G.t||0, it=(o&&o.item)||'', n=(o&&o.n>0)?Math.round(o.n):1, i, r;
'@ @'
  var q=(G.pick=G.pick||[]), now=G.t||0, it=(o&&o.item)||'', n=(o&&o.n>0)?Math.round(o.n):1, i, r;
  // v22.59 (R19): a keyed row (o.key) said again, as BACKPACK FULL is every frame E is held on a full backpack, refreshes where it
  // is: new words, a new detail, its full time again, and no count.
  if(o&&o.key){ for(i=0;i<q.length;i++){ r=q[i]; if(r.key===o.key&&r.T>0){ r.m=String(m); r.sub=o.sub?String(o.sub):''; if(o.c) r.c=o.c; r.T=PICKLIFE; return; } } }
'@

SubRx @'
  q.push({m:String(m),item:it,n:n,tag:(o&&o.tag)?String(o.tag):'',c:(o&&o.c)||'',T:(o&&o.life>0)?o.life:PICKLIFE,at:now});
'@ @'
  q.push({m:String(m),item:it,n:n,tag:(o&&o.tag)?String(o.tag):'',c:(o&&o.c)||'',T:(o&&o.life>0)?o.life:PICKLIFE,at:now,key:(o&&o.key)?String(o.key):'',sub:(o&&o.sub)?String(o.sub):''});   // v22.59 (R19): key and detail
'@

SubRx @'
function pickTag(item,tag){
'@ @'
// v22.59 (R19): the detail under BACKPACK FULL names the button that drops the selected item on the device in hand: the key Z is
// bound to on the keyboard (keyLabel, so an unmoved keyboard reads [Z]), and Y on a controller, the button pollPad gives
// bagDropSel with the backpack open (padB names it for a PlayStation pad).
function bagDropHint(){ return padOn()?padB('[Y] drops the selected item.'):('['+keyLabel('KeyZ','Z')+'] drops the selected item.'); }
function pickTag(item,tag){
'@

SubRx @'
      col=pickCol(r); nm=String(r.m); cnt=(r.n>1)?('x'+r.n):''; tag=r.tag?String(r.tag).toUpperCase():'';
'@ @'
      col=pickCol(r); nm=String(r.m); cnt=(r.n>1)?('x'+r.n):''; tag=r.sub?String(r.sub):(r.tag?String(r.tag).toUpperCase():'');   // v22.59 (R19): a detail is drawn as written
'@

SubRx @'
      say(P.autoloot?('Backpack full ('+cap+') and nothing left worth dropping.')
                    :('Backpack full ('+cap+'). Z drops the selected item.'),'info',{key:'bagfull'});   // v21.91 (R07): said every frame E is held, so it refreshes its row
'@ @'
      // v22.59, the raid text rewrite (R19): BACKPACK FULL IS ONE RED ROW. HIS ORDER (2026-10-09): a raid line is a short caps
      // headline and, only when needed, a short detail. This said Backpack full with the raw capacity number in brackets and Z drops
      // the selected item, in the middle of the screen, naming Z even with a controller in hand. It is now one keyed red row in the
      // pickup stack, BACKPACK FULL, refreshed every frame E is held (v21.91: never a second row), with the button that drops the
      // selected item on the device in hand as its detail, or that nothing is left worth dropping when autoloot is on.
      say('BACKPACK FULL','pick',{key:'bagfull',c:'danger',sub:P.autoloot?'Nothing left worth dropping.':bagDropHint()});
'@

SubRx @'
  if(!_pAmmo&&bagWeight()+wt>cap){ say('Backpack full.'); return; }
'@ @'
  if(!_pAmmo&&bagWeight()+wt>cap){ say('BACKPACK FULL','pick',{key:'bagfull',c:'danger',sub:bagDropHint()}); return; }   // v22.59 (R19): the same red row as a search
'@

SubRx @'
var VER='22.58';
'@ @'
var VER='22.59';
'@

$pat = "(?m)^  now:'v22\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.59: A full backpack is one red BACKPACK FULL row naming the drop button of the device in hand. Check 22.59 fails on v22.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
