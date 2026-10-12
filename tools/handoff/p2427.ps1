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

# KEYS ARE KEYCAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  ctx.fillStyle=(o&&o.col)||HUDC.text; hudText(t,x,y,2*Math.max(1,(typeof hudRes==='function')?hudRes():1)/Math.max(0.25,_pa));
  i0=t.indexOf('['); i1=(i0>=0)?t.indexOf(']',i0):-1;
  if(i1>i0){ ctx.textAlign='left'; ctx.fillStyle=HUDC.warn; ctx.fillText(t.slice(i0,i1+1),x-w/2+ctx.measureText(t.slice(0,i0)).width,y); ctx.textAlign='center'; }
'@ @'
  // v24.27, UI REDESIGN ui7 (his #50): THE KEY IS A KEYCAP. The [E] of the line is cut out of it with a clip and an amber keycap with
  // the key in dark ink (the pad button in its own colour on a controller) is drawn in its place. The line is still drawn whole, one
  // fillText through the TX door, so his wording of the whole sentence, the word editor and the line as read are all unchanged.
  var _pc=(o&&o.col)||HUDC.text, _plw=2*Math.max(1,(typeof hudRes==='function')?hudRes():1)/Math.max(0.25,_pa), _T=TX(t), _x0, _k0, _kW;
  i0=_T.indexOf('['); i1=(i0>=0)?_T.indexOf(']',i0):-1;
  ctx.fillStyle=_pc;
  if(i1>i0+1){
    _x0=x-w/2; _k0=_x0+hudRawW(_T.slice(0,i0)); _kW=hudRawW(_T.slice(i0,i1+1));
    ctx.save(); ctx.beginPath(); ctx.rect(_x0-LH(12),y-a-LH(8),w+LH(24),a+d+LH(16)); ctx.rect(_k0,y-a-LH(8),_kW,a+d+LH(16)); ctx.clip('evenodd');
    try{ hudText(t,x,y,_plw); } finally { ctx.restore(); }
    hudKey(_T.slice(i0+1,i1),_k0,y,a,_kW);
    ctx.fillStyle=_pc; ctx.textAlign='center';
  }
  else hudText(t,x,y,_plw);
'@

SubRx @'
function hudPrompt(s,x,y,o){
'@ @'
// v24.27, UI REDESIGN ui7 (his #50): hudKey draws a keycap at x (its left), on the baseline y of a line whose capitals rise a above it,
// sw wide (the room the key had in the line): an amber key with a darker lip and the key in dark ink; on a controller A, B, X and Y
// are round buttons in their own colours and the bumpers and triggers are pills. hudRawW measures a string as it stands.
function hudRawW(s){ try{ return (TXMW?TXMW.call(ctx,s):ctx.measureText(s)).width; }catch(_w){ return 0; } }
var HUDKEY_PAD={A:'#5fbf6a',B:'#e5482f',X:'#3f9de9',Y:'#f5b73b'};
function hudKey(label,x,y,a,sw,o){
  var L=String(label), kh=a+LH(7), kw=Math.max(kh*0.9,(sw>0?sw:hudRawW(L)+LH(12))-LH(2)), kx=x+((sw>0?sw:kw+LH(2))-kw)/2, top=y-a-LH(3.5), r=Math.min(LH(3),kh/2);
  var pc=padOn()?HUDKEY_PAD[L]:null, pill=padOn()&&(/^(LB|RB|LT|RT|LS|RS|VIEW|MENU|BACK)$/).test(L), oa=ctx.textAlign, of=ctx.fillStyle;
  ctx.fillStyle='rgba(0,0,0,.55)';
  if(pc){ var cr=Math.min(kw,kh)/2; ctx.beginPath(); ctx.arc(kx+kw/2,top+kh/2+LH(1.5),cr,0,Math.PI*2); ctx.fill(); ctx.fillStyle=pc; ctx.beginPath(); ctx.arc(kx+kw/2,top+kh/2,cr,0,Math.PI*2); ctx.fill(); }
  else {
    if(pill) r=kh/2;
    ctx.beginPath();
    if(ctx.roundRect){ ctx.roundRect(kx,top+LH(1.5),kw,kh,r); ctx.fill(); ctx.fillStyle=(o&&o.fill)||UIC.acc; ctx.beginPath(); ctx.roundRect(kx,top,kw,kh,r); ctx.fill(); }
    else { ctx.fillRect(kx,top+LH(1.5),kw,kh); ctx.fillStyle=(o&&o.fill)||UIC.acc; ctx.fillRect(kx,top,kw,kh); }
  }
  ctx.fillStyle=(o&&o.ink)||UIC.acc_ink; ctx.textAlign='center';
  ctx.fillText(L,kx+kw/2,y-LH(0.5));
  ctx.textAlign=oa; ctx.fillStyle=of;
  return kw;
}function hudPrompt(s,x,y,o){
'@

SubRx @'
function keyLabel(code,fallback){
'@ @'
// v24.27, UI REDESIGN ui7 (his #50): uiKey(code) is the DOM keycap of a key, named as keyLabel names it (the key as set, or the pad
// button through padB on a controller): a key for the keyboard, a coloured round button for A, B, X and Y, a pill for the bumpers.
function uiKey(code,fallback){
  var L=String(keyLabel(code,fallback)), c='ui-key';
  if(padOn()&&HUDKEY_PAD[L]) c+=' pad pad-'+L.toLowerCase(); else if(padOn()&&(/^(LB|RB|LT|RT|LS|RS|VIEW|MENU|BACK)$/).test(L)) c+=' pill';
  return '<span class="'+c+'">'+L.replace(/&/g,'&amp;').replace(/</g,'&lt;')+'</span>';
}
function keyLabel(code,fallback){
'@

SubRx @'
  #root #hub #stashclose{ position:absolute; right:22px; bottom:31.74px; margin:0 !important; min-width:120px; color:var(--tx-1); border-color:var(--ui-line-hi); }
'@ @'
  #root #hub #stashclose{ position:absolute; right:22px; bottom:31.74px; margin:0 !important; min-width:120px; color:var(--tx-1); border-color:var(--ui-line-hi); }
  /* v24.27, UI REDESIGN ui7 (his #50): KEYCAPS. The title key row and the stash key bar draw their keys as keycaps (a key with a lip,
     not a pill or bold words), the same keycap as .ui-key and as the world prompts on the HUD. */
  #title .kbrow b, #root .keybar kbd{ display:inline-flex; align-items:center; justify-content:center; min-width:24px; height:24px; padding:0 6px;
    box-sizing:border-box; border:1px solid var(--tx-1); border-bottom-width:2px; border-radius:3px; background:rgba(0,0,0,.35); color:var(--tx-1);
    font-family:var(--f-cond); font-weight:700; font-size:13px; line-height:1; letter-spacing:.04em; text-transform:uppercase; vertical-align:middle; }
  #title .kbrow b{ margin-right:4px; }
  .ui-key.pad{ border-radius:50%; width:24px; min-width:24px; padding:0; border:0; color:#111315; }
  .ui-key.pad-a{ background:#5fbf6a; } .ui-key.pad-b{ background:#e5482f; } .ui-key.pad-x{ background:#3f9de9; } .ui-key.pad-y{ background:#f5b73b; }
  .ui-key.pill{ border-radius:12px; padding:0 9px; }
'@

SubRx @'
var VER='24.26';
'@ @'
var VER='24.27';
'@

$pat = "(?m)^  now:'v24\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.27: Prompts in the world and the key rows on the title and in the stash show each key as a keycap instead of a letter in brackets. Check 24.27 fails on v24.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
