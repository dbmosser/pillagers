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

# PAD LAYOUT READABILITY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  /* v28.xx (cw-cx-padpresets): 48px layout controls, a scrollable rebind column and a live controller at 1080p. */
  #root #keysmodal.padlayouts #keyslist{display:flex;flex-direction:column;max-width:none;overflow:hidden!important;gap:24px;}
  #root #keysmodal.padlayouts #keysnote:not(.wait):not(.set):not(.clash){display:none;}
  #root #keysmodal.padlayouts .padlayoutrow{display:flex;align-items:center;justify-content:space-between;flex:none;border-bottom:1px solid var(--ui-line);padding:8px 16px 24px;font:600 20px var(--f-cond);}
  #root #keysmodal.padlayouts .padlayoutpick{display:flex;gap:8px;align-items:center;}
  #root #keysmodal.padlayouts .padlayoutpick button{height:48px;min-width:48px;font:600 20px var(--f-cond);}
  #root #keysmodal.padlayouts #padlayout{min-width:240px;color:var(--acc);}
  #root #keysmodal.padlayouts .padeditgrid{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1.3fr);gap:32px;min-height:0;flex:1;}
  #root #keysmodal.padlayouts .padactions{overflow-y:auto;min-height:0;padding-right:16px;}
  #root #keysmodal.padlayouts .row{min-height:48px;padding:4px 8px;}
  #root #keysmodal.padlayouts .row b{font-size:20px;letter-spacing:0;}
  #root #keysmodal.padlayouts .keybtn{min-width:88px!important;font-size:16px;}
  #root #keysmodal.padlayouts .rebind{min-width:88px;font-size:16px;letter-spacing:0;}
  #root #keysmodal.padlayouts .padpicture{margin:0;min-width:0;display:flex;align-items:center;justify-content:center;background:var(--ui-panel,#16191b);border:1px solid var(--ui-line);border-radius:4px;}
  #root #keysmodal.padlayouts .padpicture svg{width:100%;max-height:100%;}
'@ @'
  /* v28.xx (cw-cx-padlegend): critic 74, 10-20: crossed leaders, small keycaps and a clipped row. Named controls match a fixed-column legend; list viewports end on complete 56px rows. */
  #root #keysmodal.padlayouts #keyslist{display:flex;flex-direction:column;max-width:none;overflow:hidden!important;gap:24px;}
  #root #keysmodal.padlayouts #keysnote:not(.wait):not(.set):not(.clash){display:none;}
  #root #keysmodal.padlayouts .padlayoutrow{display:flex;align-items:center;gap:24px;flex:none;border-bottom:1px solid var(--ui-line);padding:8px 0 24px;font:600 20px var(--f-cond);}
  #root #keysmodal.padlayouts .padlayoutpick{display:flex;gap:0;align-items:center;border:1px solid var(--ui-line-hi);border-radius:4px;}
  #root #keysmodal.padlayouts .padlayoutpick button{height:48px;min-width:56px;font:600 24px var(--f-cond);border:0;}
  #root #keysmodal.padlayouts #padlayout{min-width:240px;color:var(--tx-1);font-size:20px;}
  #root #keysmodal.padlayouts #padlayout.padfocus{color:var(--acc);}
  #root #keysmodal.padlayouts .padeditgrid{display:grid;grid-template-columns:minmax(360px,520px) minmax(0,1fr);gap:32px;min-height:0;flex:1;align-items:start;}
  #root #keysmodal.padlayouts .padactions{overflow-y:auto;min-height:0;padding-right:16px;box-sizing:border-box;scroll-snap-type:y mandatory;scrollbar-width:auto;scrollbar-color:var(--ui-line-hi) var(--ui-panel);}
  #root #keysmodal.padlayouts .padactions::-webkit-scrollbar{width:8px;}
  #root #keysmodal.padlayouts .padactions::-webkit-scrollbar-thumb{background:var(--ui-line-hi);border-radius:4px;}
  #root #keysmodal.padlayouts #keyslist .row,#root #keysmodal.padlayouts #keyslist .keysec{height:56px;min-height:56px;box-sizing:border-box;margin:0;padding:8px;scroll-snap-align:start;scroll-snap-stop:always;}
  #root #keysmodal.padlayouts #keyslist .row{border-bottom:1px solid var(--ui-line);}
  #root #keysmodal.padlayouts #keyslist .keysec{display:flex;align-items:center;font:600 16px var(--f-cond);letter-spacing:.04em;color:var(--tx-2);box-shadow:none;border:0;}
  #root #keysmodal.padlayouts #keyslist .row b{font-size:20px;letter-spacing:0;}
  #root #keysmodal.padlayouts #keyslist .keybtn{min-width:88px!important;min-height:40px;height:40px;font:700 20px var(--f-cond);color:var(--tx-1)!important;border:1px solid var(--ui-line-hi);box-shadow:none;letter-spacing:0;}
  #root #keysmodal.padlayouts #keyslist .row:has(.padfocus){background:var(--ui-raised);box-shadow:inset 3px 0 var(--acc);}
  #root #keysmodal.padlayouts #keyslist .keybtn.padfocus{color:var(--acc)!important;outline:0!important;}
  #root #keysmodal.padlayouts #keyslist .keybtn.wait{color:var(--acc-ink)!important;}
  #root #keysmodal.padlayouts .padpicture{margin:0;min-width:0;box-sizing:border-box;display:flex;align-items:center;justify-content:center;background:var(--ui-panel,#16191b);border:1px solid var(--ui-line);border-radius:4px;}
  #root #keysmodal.padlayouts .padpicture svg{width:100%;height:100%;max-width:1040px;}
'@

SubRx @'
function padPictureHtml(){
  var m=padMapArr(), swap=P.padSticks==='swap', h, i, b, label;
  var left=[[6,64,342,222],[4,120,334,254],[8,232,440,302],[10,288,354,332],[12,400,408,385],[14,456,386,408],[15,512,430,408],[13,568,408,431]];   // v28.xx (cw-padpic) critic on Pad buttons 74 (2): "leader lines cross each other". The left labels now run in the same top to bottom order as their controls, so those leaders no longer cross.
  var right=[[7,64,618,222],[5,120,626,254],[3,176,624,310],[2,232,600,334],[1,288,648,334],[0,344,624,358],[9,400,520,302],[11,568,526,422]];
  h='<figure class="padpicture"><svg viewBox="0 0 960 640" role="img" aria-label="controller layout">'+
    '<path d="M332 238 Q308 228 288 290 L244 464 Q236 516 280 524 Q300 528 324 494 L376 444 L584 444 L636 494 Q660 528 680 524 Q724 516 716 464 L672 290 Q652 228 628 238 L570 216 L390 216 Z" fill="var(--ui-panel,#16191b)" stroke="var(--ui-line-hi,#4a5257)" stroke-width="4"/>'+
    '<g fill="var(--ui-raised,#1e2225)" stroke="var(--ui-line-hi,#4a5257)" stroke-width="3">'+
    '<rect x="312" y="206" width="60" height="24" rx="8"/><rect x="588" y="206" width="60" height="24" rx="8"/>'+
    '<path d="M310 246 L374 236 M586 236 L650 246"/><circle cx="354" cy="332" r="34"/><circle cx="526" cy="422" r="34"/>'+
    '<path d="M398 375 H418 V398 H440 V418 H418 V440 H398 V418 H376 V398 H398 Z"/>'+
    '<circle cx="624" cy="310" r="15"/><circle cx="600" cy="334" r="15"/><circle cx="648" cy="334" r="15"/><circle cx="624" cy="358" r="15"/>'+
    '<rect x="429" y="294" width="22" height="16" rx="4"/><rect x="509" y="294" width="22" height="16" rx="4"/></g>';
  function tag(button,y,x,py,isRight){
    var tx=isRight?944:16, edge=isRight?714:246, end=isRight?728:232;
    return '<path d="M'+x+' '+py+' L'+edge+' '+(y-8)+' H'+end+'" fill="none" stroke="var(--ui-line-hi,#4a5257)" stroke-width="2"/>'+
      '<circle cx="'+x+'" cy="'+py+'" r="5" fill="var(--ui-line-hi,#4a5257)"/>'+
      '<text data-pad-button="'+button+'" x="'+tx+'" y="'+y+'" text-anchor="'+(isRight?'end':'start')+'">'+
      '<tspan fill="var(--tx-2,#aaa498)">'+PAD_BTN[button].toLowerCase()+'</tspan><tspan dx="10">'+padPictureLabel(button)+'</tspan></text>';
  }
  h+='<g font-family="Barlow Condensed,Bahnschrift,Arial,sans-serif" font-size="26" font-weight="600" fill="var(--tx-1,#efe9dc)">';
  for(i=0;i<left.length;i++){ b=left[i]; h+=tag(b[0],b[1],b[2],b[3],false); }
  for(i=0;i<right.length;i++){ b=right[i]; h+=tag(b[0],b[1],b[2],b[3],true); }
  h+='<text x="354" y="340" text-anchor="middle" data-pad-stick="left">'+(swap?'aim':'move')+'</text>'+
    '<text x="526" y="430" text-anchor="middle" data-pad-stick="right">'+(swap?'move':'aim')+'</text></g></svg></figure>';
  return h;
}
'@ @'
function padPictureHtml(){
  // v28.xx (cw-cx-padlegend): every physical control is named on the outline and in the action legend. No ambiguous leader lines.
  var swap=P.padSticks==='swap', h, i;
  var left=[6,4,8,10,12,14,15,13],right=[7,5,3,2,1,0,9,11];
  h='<figure class="padpicture"><svg viewBox="0 0 1000 640" role="img" aria-label="controller layout">'+
    '<path d="M346 99 Q321 85 302 133 L263 242 Q253 282 285 290 Q309 296 331 272 L388 238 H612 L669 272 Q691 296 715 290 Q747 282 737 242 L698 133 Q679 85 654 99 L606 79 H394 Z" fill="var(--ui-raised,#1e2225)" stroke="var(--ui-line-hi,#4a5257)" stroke-width="2"/>'+
    '<g fill="var(--ui-panel,#16191b)" stroke="var(--ui-line-hi,#4a5257)" stroke-width="2">'+
    '<rect x="328" y="18" width="64" height="30" rx="4"/><rect x="608" y="18" width="64" height="30" rx="4"/>'+
    '<rect x="316" y="56" width="88" height="28" rx="4"/><rect x="596" y="56" width="88" height="28" rx="4"/>'+
    '<circle cx="360" cy="139" r="40"/><circle cx="564" cy="219" r="40"/>'+
    '<rect x="439" y="104" width="50" height="28" rx="4"/><rect x="511" y="104" width="50" height="28" rx="4"/>'+
    '<path d="M395 175 H441 V205 H471 V243 H441 V273 H395 V243 H365 V205 H395 Z"/>'+
    '<circle cx="648" cy="116" r="17"/><circle cx="616" cy="148" r="17"/><circle cx="680" cy="148" r="17"/><circle cx="648" cy="180" r="17"/></g>';
  function node(b,x,y){return '<text data-pad-node="'+b+'" x="'+x+'" y="'+y+'" text-anchor="middle">'+PAD_BTN[b].toLowerCase()+'</text>';}
  h+='<g font-family="Barlow Condensed,Bahnschrift,Arial,sans-serif" font-size="16" font-weight="600" fill="var(--tx-1,#efe9dc)">';
  h+=node(6,360,39)+node(7,640,39)+node(4,360,76)+node(5,640,76)+node(8,464,124)+node(9,536,124);
  h+=node(3,648,122)+node(2,616,154)+node(1,680,154)+node(0,648,186);
  h+=node(12,418,196)+node(14,388,231)+node(15,448,231)+node(13,418,265);
  h+=node(10,360,165)+node(11,564,245)+'</g>';
  h+='<g font-family="Barlow Condensed,Bahnschrift,Arial,sans-serif" font-size="20" font-weight="600" fill="var(--tx-1,#efe9dc)">';
  h+='<text x="360" y="140" text-anchor="middle" data-pad-stick="left">'+(swap?'aim':'move')+'</text>'+
    '<text x="564" y="220" text-anchor="middle" data-pad-stick="right">'+(swap?'move':'aim')+'</text></g>';
  h+='<path d="M24 315 H976" stroke="var(--ui-line-hi,#4a5257)"/>';
  function tag(b,x,y){return '<g data-pad-button="'+b+'"><text x="'+x+'" y="'+y+'" font-size="16" fill="var(--tx-2,#aaa498)">'+PAD_BTN[b].toLowerCase()+'</text>'+
    '<text x="'+(x+72)+'" y="'+y+'" font-size="20" fill="var(--tx-1,#efe9dc)">'+padPictureLabel(b)+'</text></g>';}
  h+='<g font-family="Barlow Condensed,Bahnschrift,Arial,sans-serif" font-weight="600">';
  for(i=0;i<8;i++){ h+=tag(left[i],40,352+i*36)+tag(right[i],532,352+i*36); }
  return h+'</g></svg></figure>';
}
function padListFit(){
  // v28.xx (cw-cx-padlegend): section headers and actions share one pitch, including after a resize or a rebind refresh.
  var m=document.getElementById('keysmodal'), grid=m&&m.querySelector('.padeditgrid'), sc=grid&&grid.querySelector('.padactions');
  if(!sc||!m.classList.contains('on')) return;
  var h=Math.floor(grid.clientHeight/56)*56;
  if(h<56) return;
  sc.style.height=h+'px'; grid.querySelector('.padpicture').style.height=h+'px';
}
window.addEventListener('resize',function(){if(KEYS.pad) padListFit();});
'@

SubRx @'
  bs=list.querySelectorAll('.keybtn, .rebind');
'@ @'
  if(KEYS.pad) requestAnimationFrame(padListFit); // v28.xx (cw-cx-padlegend): fit after opening and after rebuilding.
  bs=list.querySelectorAll('.keybtn, .rebind');
'@

SubRx @'
var VER='32.48';
'@ @'
var VER='32.49';
'@

$pat = "(?m)^  now:'v32\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.49: Named controller controls, aligned action legends, larger keycaps and complete scrolling rows. Check 32.49 fails on v32.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
