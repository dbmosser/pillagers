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

# THE RACKS PAGE READS AT A GLANCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #opane_mf button:not(#mfbuild):focus-visible{box-shadow:inset 3px 0 0 var(--acc);background:var(--ui-raised);}
'@ @'
#root #opane_mf button:not(#mfbuild):focus-visible{box-shadow:inset 3px 0 0 var(--acc);background:var(--ui-raised);}
/* v28.xx (cw-rackpolish) o-09g critic on 14, all scores 2: (1) a part you cannot use looked the same as one you can: a disabled button is now an empty dashed outline in the dim text colour, an enabled one a raised fill with a solid border and bright text; (2) the rack counter was teal (extract only, style guide section 1): now tx-1, and the array count and the pay line lose their purple and lime for the same reason; (3) empty rack slots were styled like built ones: an empty slot is a dashed outline with no fill, a built one is solid ok green; (4) rows and columns did not line up: the ten slots now span exactly the left column (the build button column) and the count starts where the friend column starts; (5) the cost text was 16px grey: the parts are 20px tx-1, a part you are short of is in the danger colour. */
#root #opane_mf > #mfstatus{display:grid;grid-template-columns:repeat(10,calc((100% - var(--sp-5)) / 20 - 7.2px)) 1fr;column-gap:8px;align-items:center;}
#root #opane_mf #mfstatus > span.rkslot{width:auto !important;height:48px !important;border-radius:var(--rad);}
#root #opane_mf #mfstatus > span.rkslot.rkoff{background:transparent;border:1px dashed var(--ui-line-hi);}
#root #opane_mf #mfstatus > span.rkslot.rkon{background:var(--ok);border:1px solid var(--ok);}
#root #opane_mf #mfstatus .rkinfo{display:flex;flex-wrap:wrap;align-items:baseline;column-gap:var(--sp-2);margin-left:calc(var(--sp-5) - 8px);}
#root #opane_mf #mfstatus .rkinfo b{margin-left:0;color:var(--tx-1);}
#root #opane_mf #mfstatus .rkinfo .rkpay{font-size:var(--fs-body);color:var(--tx-2);}
#root #opane_mf button:disabled{background:transparent;color:var(--tx-3);border:1px dashed var(--ui-line);}
#root #opane_mf button:not(:disabled):not(#mfbuild){background:var(--ui-raised);color:var(--tx-1);border:1px solid var(--ui-line-hi);}
#root #opane_mf button:not(:disabled):not(#mfbuild):hover{background:var(--ui-hover);}
#root #opane_mf #mfhint .rkparts{display:block;margin:var(--sp-1) 0;}
#root #opane_mf #mfhint .rkp{font-size:var(--fs-body);color:var(--tx-1);}
#root #opane_mf #mfhint .rkp.short{color:var(--danger);}
'@

SubRx @'
bars+='<span style="display:inline-block;width:34px;height:12px;margin-right:5px;border:1px solid var(--steel-hi);background:'+(i<r?'rgba(53,214,200,.35)':'rgba(0,0,0,.3)')+'"></span>';
'@ @'
bars+='<span class="rkslot '+(i<r?'rkon':'rkoff')+'"></span>';   // v28.xx (cw-rackpolish): built and empty slots are classes now (solid ok green, dashed empty outline), not one inline teal
'@

SubRx @'
st.innerHTML=bars+'  <b style="color:var(--coolant)">'+r+' of '+RACK_CAP+' racks</b>'+
'@ @'
st.innerHTML=bars+'<div class="rkinfo"><b class="rkcount">'+r+' of '+RACK_CAP+' racks</b>'+
'@

SubRx @'
(_ar>0?'  <b style="color:#b9a8ff">'+_ar+' array'+(_ar===1?'':'s')+'</b>':'')+
'@ @'
(_ar>0?'<b class="rkarr">'+_ar+' array'+(_ar===1?'':'s')+'</b>':'')+
'@

SubRx @'
(mfPayPer()>0?'  <span style="color:var(--amber)">+$'+mfPayPer().toLocaleString()+' per extraction</span>':'');
'@ @'
(mfPayPer()>0?'<span class="rkpay">+$'+mfPayPer().toLocaleString()+' per extraction</span>':'')+'</div>';
'@

SubRx @'
hn.textContent=(r>=RACK_CAP)?(
'@ @'
hn.innerHTML=(r>=RACK_CAP)?(
'@

SubRx @'
:('A rack costs '+rackCostLine()+'. Each pays $'+RACK_PAY+' every time you extract alive. Junk becomes infrastructure.'); }
'@ @'
:('A rack costs <span class="rkparts">'+rackCostHtml()+'</span>Each pays $'+RACK_PAY+' every time you extract alive. Junk becomes infrastructure.'); }
'@

SubRx @'
function buildRack(){
'@ @'
// v28.xx (cw-rackpolish): the same line as rackCostLine, each part in its own span; a part you hold too few of is marked short
function rackCostHtml(){
  var c=stashCounts(),parts=[];
  for(var k in RACK_COST) parts.push('<span class="rkp'+((c[k]||0)<RACK_COST[k]?' short':'')+'">'+RACK_COST[k]+' '+(ITEMS[k]?ITEMS[k].name:k)+' ('+(c[k]||0)+' held)</span>');
  return parts.join(', ')+'. ';
}
function buildRack(){
'@

SubRx @'
var VER='36.84';
'@ @'
var VER='36.85';
'@

$pat = "(?m)^  now:'v36\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.85: The racks page shows built and empty slots, usable and unusable buttons, and the parts you are short of, at a glance. Check 36.85 fails on v36.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
