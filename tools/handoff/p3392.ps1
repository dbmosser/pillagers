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

# PIXEL FASHION READABILITY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
</style><canvas id="cv"></canvas>
'@ @'
</style>
<style id="pix-fashion-fit">
/* v28.xx (cw-cx-pixrackfit): visible worn/focus states and four complete racks in the existing fashion columns. */
#root #appearmodal.pixfashion > .msub,#root #appearmodal.pixfashion #apptabs{display:none !important}
#root #appearmodal.pixfashion > .hubgrid{grid-template-columns:360px minmax(0,1fr) !important;margin-top:16px !important}
#root #appearmodal.pixfashion .panel > h2{font:600 20px/24px var(--f-cond) !important;color:var(--tx-1) !important;letter-spacing:.04em !important}
#root #appearmodal.pixfashion #appavatarpicker{padding:12px !important}
#root #appearmodal.pixfashion .pixrack{margin:0 0 16px !important}
#root #appearmodal.pixfashion .pixrack:last-child{margin-bottom:0 !important}
#root #appearmodal.pixfashion .pixrack .glab{font:600 20px/24px var(--f-cond) !important;margin:0 0 8px !important;color:var(--tx-1) !important}
#root #appearmodal.pixfashion .pixtiles{display:grid !important;grid-template-columns:repeat(3,minmax(0,1fr)) !important;gap:8px !important}
#root #appearmodal.pixfashion [data-pixrack="set"] .pixtiles{grid-template-columns:repeat(4,minmax(0,1fr)) !important}
#root #appearmodal.pixfashion #appavatarpicker .costile{display:grid !important;grid-template-columns:76px minmax(0,1fr) !important;grid-template-rows:1fr 1fr !important;column-gap:16px !important;row-gap:8px !important;align-items:center !important;justify-items:start !important;width:100% !important;min-width:0 !important;height:128px !important;min-height:128px !important;padding:4px 12px !important;box-sizing:border-box !important;text-align:left !important;border:1px solid var(--ui-line-hi) !important;background:var(--ui-raised) !important;box-shadow:none !important;border-radius:4px !important}
#root #appearmodal.pixfashion #appavatarpicker .costile.on{border:2px solid var(--acc) !important;box-shadow:inset 4px 0 0 var(--acc) !important;padding:3px 11px !important}
#root #appearmodal.pixfashion #appavatarpicker .costile.on .cosreq{color:var(--acc) !important}
#root #appearmodal.pixfashion #appavatarpicker .costile.padfocus,#root #appearmodal.pixfashion #appavatarpicker .costile:focus-visible{outline:2px solid var(--acc) !important;outline-offset:2px !important;background:#292e32 !important}
#root #appearmodal.pixfashion #appavatarpicker .costile canvas{grid-column:1 !important;grid-row:1 / span 2 !important;width:76px !important;height:auto !important;margin:0 !important;image-rendering:pixelated !important}
#root #appearmodal.pixfashion #appavatarpicker .costile .cosname{grid-column:2 !important;grid-row:1 !important;align-self:end !important;font:600 20px/24px var(--f-cond) !important;color:var(--tx-1) !important;margin:0 !important;letter-spacing:.02em !important}
#root #appearmodal.pixfashion #appavatarpicker .costile .cosreq{grid-column:2 !important;grid-row:2 !important;align-self:start !important;font:600 16px/20px var(--f-cond) !important;color:var(--tx-2) !important;margin:0 !important;padding:0 !important;min-height:0 !important;letter-spacing:0 !important}
#root #appearmodal.pixfashion #appopscroll{display:flex !important;flex-direction:column !important}
#root #appearmodal.pixfashion #appavatar{display:flex !important;align-items:center !important;justify-content:center !important;flex:1 !important;min-height:320px !important;background:var(--ui-raised) !important}
#root #appearmodal.pixfashion #avcv{width:320px !important;height:320px !important;margin:0 !important;background:var(--ui-raised) !important;border-radius:4px !important}
#root #appearmodal.pixfashion #applooks{flex:none !important;padding:16px !important;background:var(--ui-panel) !important}
#root #appearmodal.pixfashion #looksurprise{min-height:48px !important;font:600 20px/24px var(--f-cond) !important;margin-bottom:16px !important}
#root #appearmodal.pixfashion #applooks > .glab{font:600 16px/24px var(--f-cond) !important;color:var(--tx-2) !important;margin:0 0 8px !important}
#root #appearmodal.pixfashion #applooks .avslot{opacity:1 !important;min-height:56px !important;gap:8px !important;padding:4px 8px !important;box-sizing:border-box !important}
#root #appearmodal.pixfashion #applooks .avsval,#root #appearmodal.pixfashion #applooks .avsic{font:600 16px/20px var(--f-cond) !important;color:var(--tx-1) !important}
#root #appearmodal.pixfashion #applooks .avslab{display:none !important}
#root #appearmodal.pixfashion #applooks [data-looksave]{font:600 16px/20px var(--f-cond) !important;min-width:56px !important;min-height:48px !important;padding:4px 8px !important;margin-left:8px !important}
body:has(#appearmodal.pixfashion.on) #hubtoast{display:none !important}
@media(max-height:1000px){
#root #appearmodal.pixfashion #appavatarpicker .costile{height:120px !important;min-height:120px !important;padding:3px 12px !important}
#root #appearmodal.pixfashion #appavatarpicker .costile.on{padding:2px 11px !important}
}

</style><canvas id="cv"></canvas>
'@

SubRx @'
function renderAvatar(host,pickHost){
'@ @'
function renderAvatar(host,pickHost){
  // v28.xx (cw-cx-pixrackfit): only the pixel wardrobe uses its compact rack and saved-look styling.
  var fashion=document.getElementById('appearmodal');if(fashion)fashion.classList.toggle('pixfashion',pixOn());
'@

SubRx @'
  return '<canvas class="avcv" id="avcv" width="380" height="470"></canvas>';
'@ @'
  return '<canvas class="avcv" id="avcv" width="320" height="320"></canvas>'; // v28.xx (cw-cx-pixrackfit): a whole 4x figure in a compact, flat turntable
'@

SubRx @'
      <h2>Your operator</h2>
'@ @'
      <h2>your pillager</h2> <!-- v28.xx (cw-cx-pixrackfit): his player name is pillager. -->
'@

SubRx @'
function drawAvatarCanvas(){
'@ @'
// v28.xx (cw-cx-pixrackfit): a shallow preview shadow through the same painter, retaining linked seat rings.
function pixFashionGround(x,y,st){shadowE(x,y+1,11,.5,.28);var s=seatMarkOf(st);if(s>=0)drawSeatRing(x,y,s);}
function drawAvatarCanvas(){
'@

SubRx @'
  try{ drawOp(0,0,AVANG,AVPH,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}}); }   // v28.29 (cosm7): turning
  catch(e){}
  wc=keep; x2.restore();
'@ @'
  var ground=opGround; // v28.xx (cw-cx-pixrackfit): preview-only shadow; restore both painter globals even on failure
  try{if(pixOn())opGround=pixFashionGround;drawOp(0,0,AVANG,AVPH,'#242832',0,0,'none',0,{hero:1,moving:false,sprint:false,ads:false,hurt:0,rl:0,own:{wep:null}});}
  catch(e){}finally{opGround=ground;wc=keep;x2.restore();}
'@

SubRx @'
var VER='33.91';
'@ @'
var VER='33.92';
'@

$pat = "(?m)^  now:'v33\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.92: Four complete racks fit the fashion page with clear worn and pad states, a flat 4x preview and readable save controls. Check 33.92 fails on v33.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
