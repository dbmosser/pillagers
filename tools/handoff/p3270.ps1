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

# PAD NAME LETTERS AND STASH CLARITY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function padNameDraw(){
  var n=PADNAME,row,i,s;
  if(!n)return;
  row=n.card.querySelector('.pnl'); row.textContent='';
  for(i=0;i<n.l.length;i++){ s=document.createElement('span'); s.textContent=n.l[i]===' '?'\u00a0':n.l[i]; if(i===n.pos)s.className='cur'; row.appendChild(s); }
  // v28.xx (cw-cx-padnameview): short, readable groups use the same button caps as the other menus. All letters stay lower case.
  n.dev=padOn();
  var hint=n.card.querySelector('.pnhint');
  if(n.dev) hint.innerHTML='<span class="pnhgroup"><span class="pnaxis" aria-label="up or down">&#8597;</span>letter</span><span class="pnhgroup"><span class="ui-key pad pad-a">a</span>next</span><span class="pnhgroup"><span class="ui-key pad pad-b">b</span>back</span><span class="pnhgroup"><svg class="pnmenu" viewBox="0 0 24 24" role="img" aria-label="menu"><circle cx="12" cy="12" r="10"/><path d="M7 8h10M7 12h10M7 16h10"/></svg>done</span>';
  else hint.textContent=iniHint().toLowerCase();
}
'@ @'
// v28.xx (cw-cx-namefinal), J4 critic 10-20: Menu belongs inside the existing done action, rather than repeating it in the legend.
function padNameDraw(){
  var n=PADNAME,row,i,s;
  if(!n)return;
  row=n.card.querySelector('.pnl');row.textContent='';
  for(i=0;i<n.l.length;i++){s=document.createElement('span');s.textContent=n.l[i]===' '?'\u00a0':n.l[i];if(i===n.pos)s.className='cur';row.appendChild(s);}
  n.dev=padOn();
  var hint=n.card.querySelector('.pnhint'),done=n.card.querySelector('.pndone');
  var menu='<svg class="pnmenu" viewBox="0 0 24 24" role="img" aria-label="menu"><circle cx="12" cy="12" r="10"/><path d="M7 8h10M7 12h10M7 16h10"/></svg>';
  if(n.dev){
    hint.innerHTML='<span class="pnhgroup"><span class="pnaxis" aria-label="up or down">&#8597;</span>letter</span><span class="pnhgroup"><span class="ui-key pad pad-a">a</span>next</span><span class="pnhgroup"><span class="ui-key pad pad-b">b</span>back</span>';
    done.innerHTML=menu+'<span>done</span>';
  }else{hint.textContent=iniHint().toLowerCase();done.textContent='done';}
}
'@

SubRx @'
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
'@ @'
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
    // v28.xx (cw-cx-namefinal): a 56px name, 80px cells and 32px padding keep all sixteen letters readable; this is a dialog, not a window.
    st.textContent+='#root #padnamecard{backdrop-filter:blur(6px)}#root #padnamecard .pnbox{width:min(1152px,92%);padding:32px}'+
      '#root #padnamecard header{margin-bottom:32px}#root #padnamecard .pnl{padding:24px 0}#root #padnamecard .pnl span{height:80px;font:800 var(--fs-hero)/1 var(--f-cond)!important}'+
      '#root #padnamecard .pnl .cur{box-shadow:inset 0 -3px var(--acc)}#root #padnamecard .pnl .cur:before,#root #padnamecard .pnl .cur:after{font-size:16px;line-height:16px}#root #padnamecard .pnl .cur:before{top:-24px}#root #padnamecard .pnl .cur:after{bottom:-24px}'+
      '#root #padnamecard .ui-key{border-color:var(--ui-line-hi);color:var(--tx-1)}#root #padnamecard .pnaxis{color:var(--tx-2)}'+
      '#root #padnamecard footer{border-color:var(--ui-line-hi)}#root #padnamecard .pndone{display:inline-flex;align-items:center;justify-content:center;gap:12px;min-height:56px}#root #padnamecard .pndone .pnmenu{stroke:currentColor}#root #padnamecard .pndone>span{font:inherit;color:inherit}'+
      '@media(max-width:700px){#root #padnamecard .pnbox{padding:16px}#root #padnamecard .pnl span{font-size:32px!important;height:56px}}';
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
  if(!hubWinOn()) ctx.fillText('THE UNDERCROFT',16,28);
'@ @'
  if(!hubWinOn()&&!document.getElementById('hub').classList.contains('on')) ctx.fillText('THE UNDERCROFT',16,28); // v28.xx (cw-cx-namefinal): the stash is a window too; keep the floor heading behind it.
'@

SubRx @'
  if(!hubWinOn()) ctx.fillText((
'@ @'
  if(!hubWinOn()&&!document.getElementById('hub').classList.contains('on')) ctx.fillText(( // v28.xx (cw-cx-namefinal): keep the floor counters behind the stash too.
'@

SubRx @'
  for(var hi=0;hi<hosts.length;hi++){ if(hosts[hi]){ hosts[hi].innerHTML=html; any=true; } }
'@ @'
  for(var hi=0;hi<hosts.length;hi++){if(hosts[hi]){hosts[hi].innerHTML=html;any=true;
    // v28.xx (cw-cx-namefinal): Q8, the stash strip already names the freebie kit; its existing action only needs take. The ascent check keeps its wording.
    if(hosts[hi].id==='hubfreekit'&&!on){var take=hosts[hi].querySelector('.fkbtn');if(take)take.textContent='take';}
  }}
'@

SubRx @'
</style><canvas id="cv"></canvas>
'@ @'
/* v28.xx (cw-cx-namefinal), J4 critic 10-20: the nine belt slots span their pane on one grid. The obsolete guns caption came from the removed group layout, not a separate feature. */
#root #hub #hotplanwrap>div{padding:0!important;}
#root #hub #hotplanwrap>div>div{gap:0!important;}
#root #hub #hotplanwrap>div>div>div{flex:1;min-width:0;padding:0!important;background:transparent!important;}
#root #hub #hotplanwrap>div>div>div>div:first-child{display:grid!important;grid-template-columns:repeat(9,minmax(0,1fr));gap:8px!important;width:100%;}
#root #hub #hotplanwrap>div>div>div>div:last-child{display:none!important;}
#root #hub #hotplanwrap [data-plan]{max-width:none!important;width:auto!important;border-color:var(--ui-line-hi)!important;}
#root #hub #hotplanwrap [data-plan] span{font:600 18px/1.2 var(--f-cond)!important;letter-spacing:.04em;color:var(--tx-2)!important;}
#root #hub .lohead,#root #hub .loslab,#root #hub #stashtabs .invtab{font-size:20px!important;letter-spacing:.04em;color:var(--tx-2);}
#root #hub #kitsetup .kst span,#root #hub #kitsetup .kstc span,#root #hub #kitsetup .ksreset{font-size:20px!important;}
#root #hub #kitsetup .kst{min-height:48px;}
/* v28.xx (cw-cx-namefinal): the old 84px floor-action allowance left an empty band below the freebie action. The stash footer needs 24px. */
#root #hub{padding-bottom:24px!important;}
</style><canvas id="cv"></canvas>
'@

SubRx @'
var VER='32.69';
'@ @'
var VER='32.70';
'@

$pat = "(?m)^  now:'v32\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.70: Larger letters keep all sixteen name positions. Menu shares the done button, the stash hides floor text, and the belt spans its pane. Check 32.70 fails on v32.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
