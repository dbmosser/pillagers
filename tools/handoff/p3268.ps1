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

# PAD NAME PICKER READABILITY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  n.card.remove(); padSetFocus(n.input);
'@ @'
  n.card.remove(); document.getElementById('root').classList.remove('padnaming'); padSetFocus(n.input); // v28.xx (cw-cx-padnameview): restore the title only after closing its letter picker.
'@

SubRx @'
  n.card.querySelector('.pnhint').textContent=iniHint().toLowerCase();
'@ @'
  // v28.xx (cw-cx-padnameview): short, readable groups use the same button caps as the other menus. All letters stay lower case.
  n.dev=padOn();
  var hint=n.card.querySelector('.pnhint');
  if(n.dev) hint.innerHTML='<span class="pnhgroup"><span class="pnaxis" aria-label="up or down">&#8597;</span>letter</span><span class="pnhgroup"><span class="ui-key pad pad-a">a</span>next</span><span class="pnhgroup"><span class="ui-key pad pad-b">b</span>back</span><span class="pnhgroup"><svg class="pnmenu" viewBox="0 0 24 24" role="img" aria-label="menu"><circle cx="12" cy="12" r="10"/><path d="M7 8h10M7 12h10M7 16h10"/></svg>done</span>';
  else hint.textContent=iniHint().toLowerCase();
'@

SubRx @'
function padNameStart(input){
  if(PADNAME||!input||input.id!=='pnamein')return false;
  var st,card,v=String(input.value||'pillager').toLowerCase().slice(0,16),l=(v+'                ').slice(0,16).split('');
  if(!document.getElementById('padnamecss')){
    st=document.createElement('style'); st.id='padnamecss';
    st.textContent='#padnamecard{position:absolute;inset:0;z-index:100;display:grid;place-items:center;background:var(--scrim);color:var(--tx-1)}'+
      '#padnamecard .pnbox{box-sizing:border-box;width:min(680px,92%);padding:24px;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-radius:var(--rad)}'+
      '#padnamecard header{display:flex;align-items:center;justify-content:space-between;margin-bottom:24px}#padnamecard h2{margin:0;font:700 var(--fs-title)/1.2 var(--f-cond)}'+
      '#padnamecard .pnclose{width:48px;height:48px;padding:0;background:transparent;color:var(--tx-2);border:1px solid var(--ui-line-hi);font:600 var(--fs-title)/1 var(--f-cond)}'+
      '#padnamecard .pnl{display:grid;grid-template-columns:repeat(16,minmax(0,1fr));gap:4px;font:600 var(--fs-title)/1.5 var(--f-cond);text-align:center}'+
      '#padnamecard .pnl span{min-width:0;border-bottom:2px solid var(--ui-line-hi)}#padnamecard .pnl .cur{color:var(--acc);border-color:var(--acc);background:var(--ui-raised)}'+
      '#padnamecard .pnhint{margin-top:24px;color:var(--tx-2);font:600 var(--fs-label)/1.5 var(--f-cond)}'+
      '#padnamecard footer{display:flex;justify-content:flex-end;margin-top:24px}#padnamecard .pndone{min-height:48px;padding:8px 32px;background:var(--acc);color:var(--acc-ink);border:0;border-radius:var(--rad);font:600 var(--fs-body)/1 var(--f-cond)}';
    document.head.appendChild(st);
  }
  card=document.createElement('div'); card.id='padnamecard'; card.setAttribute('role','dialog'); card.setAttribute('aria-modal','true'); card.setAttribute('aria-labelledby','padnametitle');
  card.innerHTML='<section class="pnbox"><header><h2 id="padnametitle">pillager name</h2><button class="pnclose" aria-label="cancel">\u00d7</button></header><div class="pnl"></div><div class="pnhint"></div><footer><button class="pndone">done</button></footer></section>';
  PADNAME={input:input,l:l,pos:0,ay:1,card:card};
  card.querySelector('.pnclose').onclick=function(){padNameClose(false);}; card.querySelector('.pndone').onclick=function(){padNameClose(true);};
  document.getElementById('root').appendChild(card); input.blur(); padNameDraw(); return true;
}
'@ @'
// v28.xx (cw-cx-padnameview), J4 critic 10-20: a couch-readable letter row and one footer, with the title focus hidden behind the scrim.
function padNameStart(input){
  if(PADNAME||!input||input.id!=='pnamein')return false;
  var st,card,v=String(input.value||'pillager').toLowerCase().slice(0,16),l=(v+'                ').slice(0,16).split('');
  if(!document.getElementById('padnamecss')){
    st=document.createElement('style'); st.id='padnamecss';
    st.textContent='#root.padnaming #title{visibility:hidden!important}'+
      '#root #padnamecard{position:absolute;inset:0;z-index:100;display:grid;place-items:center;background:var(--scrim);color:var(--tx-1)}'+
      '#root #padnamecard .pnbox{box-sizing:border-box;width:min(816px,92%);padding:24px;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-radius:var(--rad)}'+
      '#root #padnamecard header{display:flex;align-items:center;justify-content:space-between;margin-bottom:24px}#root #padnamecard h2{margin:0;font:700 var(--fs-title)/1.2 var(--f-cond)!important}'+
      '#root #padnamecard .pnclose{width:48px;height:48px;padding:0;background:transparent;color:var(--tx-2);border:1px solid transparent;font:600 var(--fs-title)/1 var(--f-cond)}#root #padnamecard .pnclose:hover,#root #padnamecard .pnclose:focus-visible{border-color:var(--ui-line-hi)}'+
      '#root #padnamecard .pnl{display:grid;grid-template-columns:repeat(16,minmax(0,1fr));gap:8px;padding:16px 0;text-align:center}'+
      '#root #padnamecard .pnl span{position:relative;box-sizing:border-box;min-width:0;height:56px;display:grid;place-items:center;border:2px solid transparent;border-bottom:1px solid var(--ui-line-hi);color:var(--tx-1);font:700 var(--fs-title)/1 var(--f-cond)!important}'+
      '#root #padnamecard .pnl .cur{border:2px solid var(--acc);border-bottom-width:3px;background:var(--ui-raised);color:var(--tx-1)}'+
      '#root #padnamecard .pnl .cur:before,#root #padnamecard .pnl .cur:after{position:absolute;left:0;right:0;color:var(--acc);font:700 14px/16px var(--f-cond)}#root #padnamecard .pnl .cur:before{content:"\u25b2";top:-20px}#root #padnamecard .pnl .cur:after{content:"\u25bc";bottom:-20px}'+
      '#root #padnamecard footer{display:flex;align-items:center;justify-content:space-between;gap:24px;margin-top:24px;padding-top:24px;border-top:1px solid var(--ui-line)}'+
      '#root #padnamecard .pnhint{display:flex;align-items:center;flex-wrap:wrap;gap:24px;margin:0;color:var(--tx-1);font:600 var(--fs-body)/1.4 var(--f-cond)!important}#root #padnamecard .pnhgroup{display:inline-flex;align-items:center;gap:8px;white-space:nowrap;font:inherit;color:inherit}'+
      '#root #padnamecard .ui-key{width:32px;min-width:32px;height:32px;padding:0;font:700 20px/1 var(--f-cond)!important;text-transform:lowercase!important;border:2px solid var(--acc);border-radius:50%;color:var(--acc);background:var(--ui-raised)}'+
      '#root #padnamecard .pnaxis{display:inline-grid;place-items:center;width:32px;height:32px;color:var(--acc);font:600 24px/1 var(--f-cond)}#root #padnamecard .pnmenu{width:32px;height:32px;fill:none;stroke:var(--acc);stroke-width:1.5;flex:none}'+
      '#root #padnamecard .pndone{flex:none;min-height:48px;padding:8px 32px;background:var(--acc);color:var(--acc-ink);border:0;border-radius:var(--rad);font:600 var(--fs-body)/1 var(--f-cond)!important}'+
      '@media(max-width:700px){#root #padnamecard .pnbox{padding:16px}#root #padnamecard .pnl{gap:4px}#root #padnamecard footer{align-items:flex-start;gap:16px}#root #padnamecard .pnhint{gap:16px;font-size:16px!important}}';
    document.head.appendChild(st);
  }
  card=document.createElement('div'); card.id='padnamecard'; card.setAttribute('role','dialog'); card.setAttribute('aria-modal','true'); card.setAttribute('aria-labelledby','padnametitle');
  card.innerHTML='<section class="pnbox"><header><h2 id="padnametitle">pillager name</h2><button class="pnclose" aria-label="cancel">\u00d7</button></header><div class="pnl"></div><footer><div class="pnhint"></div><button class="pndone">done</button></footer></section>';
  PADNAME={input:input,l:l,pos:0,ay:1,card:card};
  card.querySelector('.pnclose').onclick=function(){padNameClose(false);}; card.querySelector('.pndone').onclick=function(){padNameClose(true);};
  var root=document.getElementById('root'); root.classList.add('padnaming'); root.appendChild(card); card.style.zoom=menuScale(); input.blur(); padNameDraw(); return true;
}
'@

SubRx @'
  padNameOp(padLetterInput(nw,PAD.ax,n,'ay')); return true;
'@ @'
  if(n.dev!==padOn())padNameDraw(); // v28.xx (cw-cx-padnameview): an idle open picker follows the last input device too.
  padNameOp(padLetterInput(nw,PAD.ax,n,'ay')); return true;
'@

SubRx @'
  document.querySelectorAll('.modal,.pausebox,.outcome,#hub').forEach(function(m){
'@ @'
  document.querySelectorAll('.modal,.pausebox,.outcome,#hub,#padnamecard').forEach(function(m){ // v28.xx (cw-cx-padnameview): the open picker follows menu scaling when the window resizes.
'@

SubRx @'
var VER='32.67';
'@ @'
var VER='32.68';
'@

$pat = "(?m)^  now:'v32\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.68: The pad name card has larger controls, a boxed letter with arrows and one footer. The title stays hidden while naming. Check 32.68 fails on v32.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
