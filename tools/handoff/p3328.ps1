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

# EXPERIMENTAL SETTINGS GROUPS AND ALIGNMENT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
</style><canvas id="cv"></canvas>
'@ @'
/* v28.xx (cw-cx-expui): critic job 61 round 1: empty category gutter, detached description, back in the value column, ungrouped switches and tiny idle arrows. Keep the existing Settings list/detail layout. */
#root #settingsmodal.expmode #setlist{ --rail:0px; padding-left:0; padding-right:8px; padding-bottom:var(--sp-5); scroll-padding-top:64px; -webkit-mask-image:linear-gradient(to bottom,#000 calc(100% - 48px),transparent); mask-image:linear-gradient(to bottom,#000 calc(100% - 48px),transparent); }
#root #settingsmodal.expmode #setlist .exphead{ position:sticky; top:0; z-index:4; width:100%; box-sizing:border-box; height:64px; min-height:64px; margin:0; padding:0 var(--sp-3); display:flex; align-items:center; gap:var(--sp-3); background:var(--ui-panel); border:0; border-bottom:1px solid var(--ui-line-hi); }
#root #settingsmodal.expmode #setlist .exphead button{ width:auto; min-width:0 !important; min-height:48px; padding:0 var(--sp-2); margin:0; border:1px solid var(--ui-line-hi) !important; border-radius:var(--rad); background:transparent; color:var(--tx-1); font:600 var(--fs-body)/1 var(--f-cond); }
#root #settingsmodal.expmode #setlist .expcount{ margin-left:auto; color:var(--tx-2); font:400 var(--fs-label)/1 var(--f-body); }
#root #settingsmodal.expmode #setlist .expgroup{ height:48px; min-height:48px; margin:0; padding:16px var(--sp-3) 8px; border:0; background:transparent; box-shadow:none; opacity:1 !important; }
#root #settingsmodal.expmode #setlist .expgroup > div:first-child > b{ padding:0; box-shadow:none; font:600 var(--fs-label)/1.2 var(--f-cond); color:var(--tx-2); letter-spacing:var(--track); }
#root #settingsmodal.expmode #setlist .exprow{ padding-inline:var(--sp-3); scroll-margin-top:64px; }
#root #settingsmodal.expmode #setlist .exprow > div:first-child{ flex:1 1 0 !important; min-width:0; }
#root #settingsmodal.expmode #setlist .exprow > div:first-child > b{ font:600 var(--fs-body)/1.2 var(--f-cond); color:var(--tx-1); opacity:1; }
#root #settingsmodal.expmode #setlist .exprow > button{ flex:0 0 144px; width:144px; min-width:144px !important; min-height:48px; padding:0 8px !important; gap:8px; color:var(--tx-1); }
#root #settingsmodal.expmode #setlist .exprow .expvalue{ display:inline-flex; align-items:center; justify-content:center; min-width:56px; min-height:32px; border:1px solid var(--ui-line-hi); border-radius:var(--rad); background:var(--ui-raised); font:600 var(--fs-body)/1 var(--f-cond); color:var(--tx-1); }
#root #settingsmodal.expmode #setlist .exprow.expoff .expvalue{ background:transparent; color:var(--tx-2); border-color:var(--ui-line); }
#root #settingsmodal.expmode #setlist .exprow > button::before, #root #settingsmodal.expmode #setlist .exprow > button::after{ visibility:hidden; font:400 40px/1 var(--f-body); color:var(--tx-2) !important; }
#root #settingsmodal.expmode #setlist .exprow:hover > button::before, #root #settingsmodal.expmode #setlist .exprow:hover > button::after, #root #settingsmodal.expmode #setlist .exprow.dshow > button::before, #root #settingsmodal.expmode #setlist .exprow.dshow > button::after, #root #settingsmodal.expmode #setlist .exprow > button.padfocus::before, #root #settingsmodal.expmode #setlist .exprow > button.padfocus::after{ visibility:visible; color:var(--acc) !important; }
#root #settingsmodal.expmode #setlist .exprow.dshow .expvalue, #root #settingsmodal.expmode #setlist .exprow:hover .expvalue, #root #settingsmodal.expmode #setlist .exprow > button.padfocus .expvalue{ border-color:var(--acc); color:var(--acc); }
#root #settingsmodal.expmode #setlist::-webkit-scrollbar{ width:8px; }
#root #settingsmodal.expmode #setlist::-webkit-scrollbar-track{ background:var(--ui-line); }
#root #settingsmodal.expmode #setlist::-webkit-scrollbar-thumb{ background:var(--ui-line-hi); border-radius:var(--rad); }
#root #settingsmodal.expmode #setwrap > #setdetail{ display:flex; flex-direction:column; flex-wrap:nowrap; align-items:flex-start; align-content:flex-start; justify-content:flex-start; gap:var(--sp-2); padding:var(--sp-3); }
#root #settingsmodal.expmode #setdetail > *{ flex:0 0 auto; margin:0; }
#root #settingsmodal.expmode #setdetail .sdk{ font:700 var(--fs-title)/1.2 var(--f-cond); color:var(--tx-1); }
#root #settingsmodal.expmode #setdetail .sdv{ display:inline-block; padding:8px 16px; border:1px solid var(--ui-line-hi); border-radius:var(--rad); background:var(--ui-raised); font:600 var(--fs-body)/1 var(--f-cond); color:var(--tx-1); }
#root #settingsmodal.expmode #setdetail .sdh{ max-width:48ch; font:400 var(--fs-body)/1.4 var(--f-body); color:var(--tx-1); }
#root #settingsmodal.expmode #setdetail .expnote{ font:400 var(--fs-label)/1.4 var(--f-body); color:var(--tx-2); }
#root #settingsmodal.expmode::after{ content:'enter change    esc back'; font-size:var(--fs-label); }
body.padon #root #settingsmodal.expmode::after{ content:'a change    b back'; }
</style><canvas id="cv"></canvas>
'@

SubRx @'
function expPage(host,S){
  var i, eb;
  host.innerHTML='<div class="row"><div style="flex:1"><b>experimental</b><div class="hint">starts next raid</div></div><button id="exp_back" style="padding:6px 12px;min-width:92px">back</button></div>'+(S.EXPERIMENTAL||'');
  eb=document.getElementById('exp_back'); if(eb) eb.onclick=function(){ SETSUB=''; renderSettings(); };
  for(i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].sec==='EXPERIMENTAL') (function(k){ var b=document.getElementById('go_'+k); if(b) b.onclick=function(){ cycleGameOpt(k); renderSettings(); }; })(GAMEOPTS[i].k);
}
'@ @'
// v28.xx (cw-cx-expui): same Settings rows and detail pane, grouped for scanning. Back is a sticky page action, never a toggle row.
function expPage(host,S){
  var i,j,b,r,label,state,src=document.createElement('div'),out='',groups=[
    ['raid',['xfGoals','xfHold','xfPwr','xfFire','xfBarrel','xfRamp','xfDir','xfAir']],
    ['combat',['xfGold','xfRoles','xfSupp','xfFeud','xfAffix','xfOvPh','xfStyle','xfTeam','xfWarden','xfTell','xfSearch']],
    ['events',['xfEvDebris','xfEvConvoy','xfEvBounty','xfEvCool','xfEvRamp']],
    ['extras',['xfNeed','xfHaul','xfShop','xfSeed']]
  ];
  src.innerHTML=S.EXPERIMENTAL||'';
  for(i=0;i<groups.length;i++){
    out+='<div class="row expgroup" style="opacity:.7" data-exp-group="'+groups[i][0]+'"><div><b>'+groups[i][0]+'</b></div></div>';
    for(j=0;j<groups[i][1].length;j++){
      b=src.querySelector('#go_'+groups[i][1][j]); if(!b) continue;
      r=b.parentNode; r.classList.add('exprow');
      label=r.querySelector('b');
      if(label){ label.textContent=label.textContent.replace(/^event: /i,'').replace(/^pillager roles$/i,'pillager bot roles').replace(/^machines vs pillagers$/i,'machines vs pillager bots'); }
      state=String(b.textContent).toLowerCase();
      r.classList.toggle('expoff',state==='off'); b.setAttribute('aria-pressed',state==='on'?'true':'false');
      b.setAttribute('aria-label',(label?label.textContent:groups[i][1][j])+': '+state);
      b.innerHTML='<span class="expvalue">'+escHtml(state)+'</span>';
      out+=r.outerHTML;
    }
  }
  host.innerHTML='<div class="setjump exphead"><button id="exp_back" type="button">&#8249; back</button><span class="expcount">'+XF_KEYS.length+' features</span></div>'+out;
  document.getElementById('exp_back').onclick=function(){ SETSUB=''; renderSettings(); };
  for(i=0;i<GAMEOPTS.length;i++) if(GAMEOPTS[i].sec==='EXPERIMENTAL') (function(k){ var e=document.getElementById('go_'+k); if(e) e.onclick=function(){ cycleGameOpt(k); renderSettings(); }; })(GAMEOPTS[i].k);
}
'@

SubRx @'
  var host=document.getElementById('setlist'), _keep=setKeep(host);
'@ @'
  var host=document.getElementById('setlist'), _keep=setKeep(host);
  // v28.xx (cw-cx-expui): the sub-page has no category rail. Clear the scoped styles and breadcrumb on return to main Settings.
  var modal=document.getElementById('settingsmodal');
  if(modal){ modal.classList.toggle('expmode',SETSUB==='exp'); var title=modal.querySelector('h3'); if(title) title.textContent=SETSUB==='exp'?'settings / experimental':'settings'; }
'@

SubRx @'
    if(v&&v.id==='go_superhot') html+='<div class="sdh">key: left of 1</div>';   // cw-shkey2: in words, the tick alone was hard to see
'@ @'
    if(v&&v.id==='go_superhot') html+='<div class="sdh">key: left of 1</div>';   // cw-shkey2: in words, the tick alone was hard to see
    // v28.xx (cw-cx-expui): group the effect, next-raid timing and fixed host choice under the focused experimental setting.
    if(SETSUB==='exp'&&v&&/^go_xf/.test(v.id||'')){
      html+='<div class="expnote">starts next raid</div>';
      if(G&&!G.sim&&!G.over) html+='<div class="expnote">this raid: '+(xf(v.id.slice(3))?'on':'off')+((NET&&NET.on&&NET.role==='join')?' / host choice':'')+'</div>';
    }
'@

SubRx @'
  if(_eo) _eo.onclick=function(){ SETSUB='exp'; renderSettings(); try{ document.getElementById('setlist').scrollTop=0; }catch(_es){} };
'@ @'
  // v28.xx (cw-cx-expui): entering the page starts at its first feature; Back stays a separate page action.
  if(_eo) _eo.onclick=function(){ SETSUB='exp'; renderSettings(); try{ var list=document.getElementById('setlist'), first=document.getElementById('go_xfGoals'); list.scrollTop=0; if(first){ if(PAD.on) padSetFocus(first); first.focus({preventScroll:true}); } }catch(_es){} };
'@

SubRx @'
var VER='33.27';
'@ @'
var VER='33.28';
'@

$pat = "(?m)^  now:'v33\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.28: Experimental settings have four groups, a separate Back action, clearer on and off values, and the effect directly below the focused setting. Check 33.28 fails on v33.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
