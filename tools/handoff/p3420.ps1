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

# RACKS AND REWARDS LOOK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
<style id="pix-fashion-fit">
'@ @'
<style id="mf-racks-rewards">
/* v28.xx (cw-rackrew) task 99, critic 2 on 13 rewards ("flat wall of identical rows, empty xp bar, no reward-type cues, toast on the card border") and 14 racks ("thin strip of five near-identical flat buttons and grey paragraphs in a mostly empty card, no hero, no primary action"). Looks only; nothing a rack or reward does, costs or gives changes. */
/* rewards: 36px bar, one filled lime claim all in a footer under the list, a 4px type bar on every row (credits amber, gun cyan, kit grey), the next reward raised, a lime bar on the focused row for the pad */
#root #seasonbar{height:36px !important;border-color:var(--ui-line-hi);}
#root #seasontext{font-size:20px !important;line-height:36px !important;}
#root #seasonclaimall{order:9;align-self:flex-end;margin:16px 0 0 !important;min-height:var(--btn-h);min-width:240px;font-size:var(--fs-body);}
#root #seasonclaimall:not(:disabled){background:var(--acc);color:var(--acc-ink);border-color:var(--acc);}
#root #seasonclaimall:not(:disabled):hover,#root #seasonclaimall:not(:disabled):focus-visible{background:var(--acc-hover);}
#root #seasonclaimall:disabled{background:transparent;color:var(--tx-2);border-color:var(--ui-line-hi);opacity:1;}
#root #seasonlist .row{border-left:4px solid var(--ui-line-hi);padding-left:16px;}
#root #seasonlist .row.rw-credits{border-left-color:var(--warn);}
#root #seasonlist .row.rw-wep{border-left-color:var(--coolant);}
#root #seasonlist .row.rw-next{background:var(--ui-raised);}
#root #seasonlist .row.rw-next .nm,#root #seasonlist .row.rw-ready .nm{color:var(--tx-1) !important;font-weight:700;}
#root #seasonlist .row.rw-ready button:not(:disabled){background:transparent;color:var(--acc);border:1px solid var(--acc);}
#root #seasonlist .row:focus-within{box-shadow:inset 3px 0 0 var(--acc);background:var(--ui-raised);}
/* racks: a hero rack row, then two columns (build, fold, slot on the left, the friend import on the right), a 64px lime build button when it can be built, a lime bar on the focused button */
#root #opane_mf{padding-top:var(--sp-3);}
#root #opane_mf > #mfstatus,#root #opane_mf > div:not(#mfstatus){max-width:calc(var(--sp-5) * 28);}
#root #opane_mf > #mfstatus{display:flex;align-items:center;gap:8px;font-size:var(--fs-body) !important;padding:0 0 var(--sp-3) !important;}
#root #opane_mf #mfstatus > span{width:64px !important;height:40px !important;margin-right:0 !important;box-sizing:border-box;}
#root #opane_mf #mfstatus b{font-size:32px;margin-left:var(--sp-2);}
#root #opane_mf > div:not(#mfstatus){display:grid !important;grid-template-columns:1fr 1fr;column-gap:var(--sp-5);row-gap:var(--sp-2);align-items:start;padding:0 !important;}
#root #opane_mf > div:not(#mfstatus) > *{margin-top:0 !important;min-width:0;}
#root #opane_mf #mfbuild{grid-column:1;grid-row:1;}
#root #opane_mf #mfhint{grid-column:1;grid-row:2;}
#root #opane_mf #mfarray{grid-column:1;grid-row:3;}
#root #opane_mf #mfslot{grid-column:1;grid-row:4;}
#root #opane_mf > div:not(#mfstatus) > div:not(.hint){grid-column:2;grid-row:1;}
#root #opane_mf #mfghosthint{grid-column:2;grid-row:2 / span 3;}
#root #opane_mf #mfbuild,#root #opane_mf #mfarray,#root #opane_mf #mfslot,#root #opane_mf #mfghost,#root #opane_mf #mfghostname{min-height:64px;font-size:var(--fs-body) !important;}
#root #opane_mf button:disabled{color:var(--tx-2);background:var(--ui-raised);border-color:var(--ui-line);opacity:1;}
#root #opane_mf #mfbuild:not(:disabled){background:var(--acc);color:var(--acc-ink);border-color:var(--acc);}
#root #opane_mf #mfbuild:not(:disabled):hover,#root #opane_mf #mfbuild:not(:disabled):focus-visible{background:var(--acc-hover);}
#root #opane_mf button:not(#mfbuild):focus-visible{box-shadow:inset 3px 0 0 var(--acc);background:var(--ui-raised);}
/* v28.xx (cw-rackrew): a toast may cross the outer margin (style guide section 3): on these two tabs it sits above the card, clear of its bottom border */
body:has(#opmodal.on #opane_rew[style*="display: flex"]) #hubtoast,body:has(#opmodal.on #opane_mf[style*="display: flex"]) #hubtoast{top:4px;bottom:auto;padding:6px 16px;font-size:18px;line-height:1.2;background:var(--ui-raised);}
</style>
<style id="pix-fashion-fit">
'@

SubRx @'
    _sb.textContent=_sr?('CLAIM ALL EARNED  ('+_sr+')'):'NOTHING READY TO CLAIM';

'@ @'
    _sb.textContent=_sr?('CLAIM ALL  ('+_sr+')'):'CLAIM ALL';   // v28.xx (cw-rackrew), critic task 99: the sentence "nothing ready to claim" is gone (Q8: the disabled button already says nothing is ready)

'@

SubRx @'
  var cl=seasonClaimed();
  SEASON_TIERS.forEach(function(T,ix){
    var row=document.createElement('div'); row.className='row';
    var got=cl.indexOf(ix)>=0,ready=!got&&sp>=T.sp;

'@ @'
  var cl=seasonClaimed();
  var _rwNx=-1; for(var _ri=0;_ri<SEASON_TIERS.length;_ri++){ if(cl.indexOf(_ri)<0&&sp<SEASON_TIERS[_ri].sp){ _rwNx=_ri; break; } }   // v28.xx (cw-rackrew): the next reward to earn reads first
  SEASON_TIERS.forEach(function(T,ix){
    var row=document.createElement('div'); row.className='row';
    var got=cl.indexOf(ix)>=0,ready=!got&&sp>=T.sp;
    row.className+=' rw-'+T.kind+(ready?' rw-ready':'')+(ix===_rwNx?' rw-next':'');   // v28.xx (cw-rackrew): type cue (credits, wep, kit), ready, next

'@

SubRx @'
var VER='34.19';
'@ @'
var VER='34.20';
'@

$pat = "(?m)^  now:'v34\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.20: Rewards and racks tabs look finished: type cues, one lime action, two column racks, toast clear of the card. Check 34.20 fails on v34.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
