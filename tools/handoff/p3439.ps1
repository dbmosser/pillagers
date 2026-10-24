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

# DOWNED CARD IS THE RAID PANEL, RUN INFO NEVER WRAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function runInfoShort(t){ return String(t).replace(/^extract with a haul worth
'@ @'
// v34.39 (cw-downedcard), critic on screen 34 (P1 'contract rows wrap (run info)'): the panel is fitted to its rows. The widest row (its short form when that is shorter) sets the width, up to 1.6 of the column, growing to the left; below that cap no contract row wraps. Same space as the caller, so it holds at 1080p, 4K and in either window.
function runInfoFitW(bw,rows,pad){
  var need=0, i, t, s, w;
  for(i=0;i<rows.length;i++){ if(!rows[i].v) continue; t=TX(String(rows[i].v)); s=runInfoShort(t); w=Math.min(txRawW(ctx,t),txRawW(ctx,s)); if(w>need) need=w; }
  need=Math.ceil(need+pad*2+8);
  return Math.min(Math.max(bw,need),Math.round(bw*1.6));
}
function runInfoShort(t){ return String(t).replace(/^extract with a haul worth
'@

SubRx @'
var pad=8, lh=LH(13), bw=trBW(), inner=bw-pad*2-6;
'@ @'
var pad=8, lh=LH(13), bw=runInfoFitW(trBW(),rows,pad), inner=bw-pad*2-6;
'@

SubRx @'
function downPlateDraw(r){ DP_DRAWS++; uiPanel(ctx,r.x,r.y,r.w,r.h); }
'@ @'
function downPlateDraw(r){ DP_DRAWS++; hudPanel(r.x,r.y,r.w,r.h,0.9,true); ctx.save(); ctx.fillStyle=UIC.danger; ctx.fillRect(r.x+14,r.y,36,3); ctx.restore(); }   // v34.39 (cw-downedcard), critic on screen 34 (P0 'flat box, not the standard panel; wants a 3px danger top tab'): the same panel as every raid panel (hudPanel, plain) plus a 3px danger tab on top
'@

SubRx @'
ctx.fillStyle='#ff5a4a'; ctx.fillText('DOWN',W/2,_dy);
'@ @'
ctx.font=_fD; ctx.fillStyle=UIC.danger; ctx.fillText('DOWN',W/2,_dy-Math.round((_hH-_hD)*0.5));   // v34.39 (cw-downedcard), critic on screen 34: the word down is a danger label at the callout size; the timer below is the one hero
'@

SubRx @'
ctx.font=_fH; ctx.fillStyle=(p.dbGainT>DB_POP*0.5)?'#9fe8b0':'#ffb0a0'; ctx.textAlign='center';
'@ @'
ctx.font=FS(TYPE.num); ctx.fillStyle=(p.dbGainT>DB_POP*0.5)?'#9fe8b0':UIC.tx_1; ctx.textAlign='center';   // v34.39 (cw-downedcard): the timer is the hero, the biggest type on the card (44, the HUD hero size), in the text colour
'@

SubRx @'
bar(W/2-100,_barY,200,10,p.downT/CFG.downTime,'#c8452f');
'@ @'
bar(W/2-100,_barY,200,10,p.downT/CFG.downTime,UIC.danger);   // v34.39 (cw-downedcard): the guide danger colour
'@

SubRx @'
var VER='34.38';
'@ @'
var VER='34.39';
'@

$pat = "(?m)^  now:'v34\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.39: The downed card matches the other raid panels with the timer as the biggest number, and the run info panel grows leftward so no contract row breaks over two lines. Check 34.39 fails on v34.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
