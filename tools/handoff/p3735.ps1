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

# THE BIRTH CARD FILLS ITS FRAME AND THE MAP PAGE NAMES THE KIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  '#root #birthmodal #birthwrap{width:100%;max-width:1200px;display:flex;flex-direction:column;gap:16px;margin:0 auto}'+
'@ @'
  // v37.xx (cw-m2birth2), seen on the first pictures: a third of the frame stood empty and the hat was cut off. Wrap 1200 to 1480px and centred, heir names 32 to 40px, traits 20 to 24px, rows 56 to 72px, figure 200 to 280px.
  '#root #birthmodal #birthwrap{width:100%;max-width:1480px;flex:1;min-height:0;display:flex;flex-direction:column;justify-content:center;gap:24px;margin:0 auto}'+
  '#root #birthmodal #birthhints{display:flex;align-items:center;gap:24px;font:500 var(--fs-body)/1 var(--f-cond);color:var(--tx-2)}'+
  '#root #birthmodal #birthhints span{display:inline-flex;align-items:center;gap:8px;white-space:nowrap}'+
  '#root #birthmodal #birthhints i{display:inline-flex;align-items:center;justify-content:center;min-width:34px;height:30px;padding:0 10px;border:1px solid var(--ui-line-hi);border-radius:4px;font:600 16px var(--f-cond);font-style:normal;color:var(--tx-1)}'+
  'body:not(.padon) #birthmodal #birthhints .bp,body.padon #birthmodal #birthhints .bk{display:none!important}'+
  'body:has(#birthmodal.on) #hubtoast{bottom:auto!important;top:12px}'+
'@

SubRx @'
gap:4px;min-height:136px;padding:16px 24px;background:var(--ui-panel)
'@ @'
gap:8px;min-height:176px;padding:24px 32px;background:var(--ui-panel)
'@

SubRx @'
  '#root #birthmodal .bhcard b{font:700 var(--fs-title)/1.15 var(--f-cond);color:var(--tx-1)}'+
'@ @'
  '#root #birthmodal .bhcard b{font:700 40px/1.15 var(--f-cond);color:var(--tx-1)}'+
'@

SubRx @'
  '#root #birthmodal .bhcard i{font:600 var(--fs-body)/1.3 var(--f-cond);font-style:normal}'+
'@ @'
  '#root #birthmodal .bhcard i{font:600 24px/1.3 var(--f-cond);font-style:normal}'+
'@

SubRx @'
#birthmid{display:grid;grid-template-columns:232px minmax(0,1fr);gap:16px}
'@ @'
#birthmid{display:grid;grid-template-columns:320px minmax(0,1fr);gap:24px}
'@

SubRx @'
  '#root #birthmodal #birthcv{width:200px;height:236px;flex:none}'+
'@ @'
  '#root #birthmodal #birthcv{width:280px;height:330px;flex:none}'+
'@

SubRx @'
<canvas id="birthcv" width="200" height="236"></canvas>
'@ @'
<canvas id="birthcv" width="280" height="330"></canvas>
'@

SubRx @'
  var S=pixOn()?4:Math.max(5.2,c.height/62);
'@ @'
  var S=pixOn()?4:Math.max(5.2,c.height/(cv?52:62));
'@

SubRx @'
  '#root #birthmodal #birthlook{width:100%;min-height:48px;font:600 var(--fs-body)/1 var(--f-cond)}'+
'@ @'
  '#root #birthmodal #birthlook{width:100%;min-height:56px;font:600 24px/1 var(--f-cond)}'+
'@

SubRx @'
  '#root #birthmodal .bhlab{font:600 var(--fs-label)/1.2 var(--f-cond);color:var(--tx-2)}'+
'@ @'
  '#root #birthmodal .bhlab{font:600 var(--fs-body)/1.2 var(--f-cond);color:var(--tx-2)}'+
'@

SubRx @'
width:100%;height:56px;padding:0 16px;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-radius:var(--rad);color:var(--tx-1);font:700 var(--fs-title)/1 var(--f-cond);text-transform:none}
'@ @'
width:100%;height:72px;padding:0 24px;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-radius:var(--rad);color:var(--tx-1);font:700 40px/1 var(--f-cond);text-transform:none}
'@

SubRx @'
grid-template-columns:160px minmax(0,1fr) auto;align-items:center;gap:16px;min-height:56px;padding:8px 16px;
'@ @'
grid-template-columns:200px minmax(0,1fr) auto;align-items:center;gap:24px;min-height:72px;padding:8px 24px;
'@

SubRx @'
  '#root #birthmodal .bkit b{font:700 var(--fs-body)/1.2 var(--f-cond);color:inherit}'+
'@ @'
  '#root #birthmodal .bkit b{font:700 28px/1.2 var(--f-cond);color:inherit}'+
'@

SubRx @'
  '#root #birthmodal .bkit span{font:500 var(--fs-body)/1.2 var(--f-cond);color:var(--tx-2);
'@ @'
  '#root #birthmodal .bkit span{font:500 24px/1.2 var(--f-cond);color:var(--tx-2);
'@

SubRx @'
  '#root #birthmodal #birthgo{min-height:56px;font:700 var(--fs-body)/1 var(--f-cond)}');
'@ @'
  '#root #birthmodal #birthgo{min-height:72px;min-width:480px;margin-left:auto;font:700 var(--fs-title)/1 var(--f-cond)}');
'@

SubRx @'
    <button id="birthgo" class="deploy" style="padding:8px 22px">ascend</button>
'@ @'
    <div id="birthhints"></div>
    <button id="birthgo" class="deploy" style="padding:8px 22px">ascend</button>
'@

SubRx @'
  document.getElementById('birthgo').textContent='ascend as '+birthShown();
'@ @'
  document.getElementById('birthgo').textContent='ascend as '+birthShown();
  document.getElementById('birthhints').innerHTML='<span class="bk"><i>enter</i>ascend</span><span class="bk"><i>esc</i>close</span><span class="bk"><i>arrows</i>pick</span>'+
    '<span class="bp"><i>'+escHtml(padB('A'))+'</i>pick</span><span class="bp"><i>'+escHtml(padB('B'))+'</i>close</span>';
'@

SubRx @'
function kitGunNow(){ return (G&&G.freeKitK&&G.freeKitK.gun)||FREEKIT_GUN; }
'@ @'
function kitGunNow(){ return (G&&G.freeKitK&&G.freeKitK.gun)||FREEKIT_GUN; }
function kitInfoOf(k){ var K=(k==='free')?freeKitNow():null; return K?[K.n+' kit',K.s]:KIT_INFO[k]; }   // v37.xx (cw-m2birth2): one source for the tile and the line under the row
'@

SubRx @'
s:'compact smg \u00b7 3 bandages'
'@ @'
s:'smg \u00b7 3 bandages'
'@

SubRx @'
s:'burst carbine \u00b7 2 items'
'@ @'
s:'carbine \u00b7 2 items'
'@

SubRx @'
  (function(){ var K=freeKitNow(), b=host.querySelector('.kitb[data-kit="free"]'), sp=b?b.querySelectorAll('span'):[]; KIT_INFO.free=K?[K.n+' kit',K.s]:['FREEBIE KIT','SCAV PISTOL \u00b7 4 ITEMS']; if(sp.length>1){ sp[0].textContent=KIT_INFO.free[0]; sp[1].textContent=KIT_INFO.free[1]; } })();
'@ @'
  (function(){ var Q=kitInfoOf('free'), b=host.querySelector('.kitb[data-kit="free"]'), sp=b?b.querySelectorAll('span'):[]; if(sp.length>1){ sp[0].textContent=Q[0]; sp[1].textContent=Q[1]; } })();
'@

SubRx @'
<b>'+KIT_INFO[_kp][0]+'</b><i>'+KIT_INFO[_kp][1]+'</i>
'@ @'
<b>'+kitInfoOf(_kp)[0]+'</b><i>'+kitInfoOf(_kp)[1]+'</i>
'@

SubRx @'
var VER='37.34';
'@ @'
var VER='37.35';
'@

$pat = "(?m)^  now:'v37\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.35: birth card: wrap 1200 to 1480px and centred, heir names 40px, traits 24px, rows 72px, the whole figure at 280px, the default button 72px high at the right end of the footer, key and pad hints that switch live, the floor line above the frame. Map page: the kit tile and the line under the row both name the paid kit, in words short enough not to wrap. The pad letter picker works on the name box Check 37.35 fails on v37.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
