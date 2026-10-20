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

# PAD LAYOUT TEXT AT COUCH SIZE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  #root #keysmodal.padlayouts .padpicture svg{width:100%;height:100%;max-width:1040px;}
'@ @'
  #root #keysmodal.padlayouts .padpicture svg{width:100%;height:100%;max-width:1040px;}
  /* v28.xx (cw-cx-padscale): critic 74, 10-20: the SVG legend rendered too small. HTML keeps actions at 20px; a wider drawing, 48px rows and no inherited list padding use the available height. */
  #root #keysmodal.padlayouts #keyslist{padding-bottom:0;-webkit-mask-image:none;mask-image:none;gap:16px;}
  #root #keysmodal.padlayouts .padlayoutrow{padding-bottom:16px;}
  #root #keysmodal.padlayouts .padlayoutrow > b{font:600 16px var(--f-body);letter-spacing:.04em;color:var(--tx-2);}
  #root #keysmodal.padlayouts .padlayoutpick button{font-family:var(--f-body);}
  #root #keysmodal.padlayouts #padlayoutprev,#root #keysmodal.padlayouts #padlayoutnext{font-size:32px;}
  #root #keysmodal.padlayouts .padlayoutpick:has(.padfocus){border:2px solid var(--acc);}
  #root #keysmodal.padlayouts .padlayoutpick .padfocus{outline:0!important;}
  #root #keysmodal.padlayouts .padlayoutcount{min-width:56px;padding-right:16px;font:600 16px var(--f-body);color:var(--tx-2);}
  #root #keysmodal.padlayouts #keyslist .row,#root #keysmodal.padlayouts #keyslist .keysec{height:48px;min-height:48px;padding:4px 8px;}
  #root #keysmodal.padlayouts #keyslist .keysec{font-size:20px;}
  #root #keysmodal.padlayouts .padpicture{padding:16px 24px;flex-direction:column;gap:12px;}
  #root #keysmodal.padlayouts .padpicture svg{flex:1;min-height:0;width:100%;max-width:900px;max-height:360px;}
  #root #keysmodal.padlayouts .padlegend{flex:none;display:grid;grid-template-columns:repeat(2,minmax(0,1fr));width:100%;column-gap:32px;border-top:1px solid var(--ui-line-hi);padding-top:8px;}
  #root #keysmodal.padlayouts .padlegendrow{display:grid;grid-template-columns:88px minmax(0,1fr);align-items:center;min-height:40px;font:600 20px var(--f-body);color:var(--tx-1);}
  #root #keysmodal.padlayouts .padlegendkey{color:var(--tx-2);font-weight:500;}
'@

SubRx @'
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
'@ @'
function padPictureHtml(){
  // v28.xx (cw-cx-padscale): physical controls stay on the drawing; the HTML action legend never shrinks with the SVG.
  var swap=P.padSticks==='swap', h, i;
  var left=[6,4,8,10,12,14,15,13],right=[7,5,3,2,1,0,9,11];
  h='<figure class="padpicture"><svg viewBox="175 0 650 310" role="img" aria-label="controller layout">'+
    '<g transform="translate(-125 0) scale(1.25 1)"><path d="M346 99 Q321 85 302 133 L263 242 Q253 282 285 290 Q309 296 331 272 L388 238 H612 L669 272 Q691 296 715 290 Q747 282 737 242 L698 133 Q679 85 654 99 L606 79 H394 Z" fill="var(--ui-raised,#1e2225)" stroke="var(--ui-line-hi,#4a5257)" stroke-width="2"/>'+
    '<g fill="var(--ui-panel,#16191b)" stroke="var(--ui-line-hi,#4a5257)" stroke-width="2">'+
    '<rect x="328" y="18" width="64" height="30" rx="4"/><rect x="608" y="18" width="64" height="30" rx="4"/>'+
    '<rect x="316" y="56" width="88" height="28" rx="4"/><rect x="596" y="56" width="88" height="28" rx="4"/>'+
    '<circle cx="360" cy="139" r="40"/><circle cx="564" cy="219" r="40"/>'+
    '<rect x="439" y="104" width="50" height="28" rx="4"/><rect x="511" y="104" width="50" height="28" rx="4"/>'+
    '<path d="M395 175 H441 V205 H471 V243 H441 V273 H395 V243 H365 V205 H395 Z"/>'+
    '<circle cx="648" cy="116" r="17"/><circle cx="616" cy="148" r="17"/><circle cx="680" cy="148" r="17"/><circle cx="648" cy="180" r="17"/></g></g>';
  function nx(x){return x*1.25-125;}
  function node(b,x,y){return '<text data-pad-node="'+b+'" x="'+nx(x)+'" y="'+y+'" text-anchor="middle">'+PAD_BTN[b].toLowerCase()+'</text>';}
  h+='<g font-family="Barlow,Bahnschrift,Arial,sans-serif" font-size="20" font-weight="600" fill="var(--tx-1,#efe9dc)">';
  h+=node(6,360,40)+node(7,640,40)+node(4,360,77)+node(5,640,77)+node(8,464,125)+node(9,536,125);
  h+=node(3,648,123)+node(2,616,155)+node(1,680,155)+node(0,648,187);
  h+=node(12,418,197)+node(14,388,231)+node(15,448,231)+node(13,418,266);
  h+=node(10,360,167)+node(11,564,247)+'</g>';
  h+='<g font-family="Barlow,Bahnschrift,Arial,sans-serif" font-size="24" font-weight="600" fill="var(--tx-1,#efe9dc)">';
  h+='<text x="'+nx(360)+'" y="140" text-anchor="middle" data-pad-stick="left">'+(swap?'aim':'move')+'</text>'+
    '<text x="'+nx(564)+'" y="220" text-anchor="middle" data-pad-stick="right">'+(swap?'move':'aim')+'</text></g></svg><div class="padlegend">';
  function tag(b){return '<div class="padlegendrow" data-pad-button="'+b+'"><span class="padlegendkey">'+PAD_BTN[b].toLowerCase()+'</span><span>'+padPictureLabel(b)+'</span></div>';}
  for(i=0;i<8;i++){h+=tag(left[i])+tag(right[i]);}
  return h+'</div></figure>';
}
'@

SubRx @'
function padListFit(){
  // v28.xx (cw-cx-padlegend): section headers and actions share one pitch, including after a resize or a rebind refresh.
  var m=document.getElementById('keysmodal'), grid=m&&m.querySelector('.padeditgrid'), sc=grid&&grid.querySelector('.padactions');
  if(!sc||!m.classList.contains('on')) return;
  var h=Math.floor(grid.clientHeight/56)*56;
  if(h<56) return;
  sc.style.height=h+'px'; grid.querySelector('.padpicture').style.height=h+'px';
}
'@ @'
function padListFit(){
  // v28.xx (cw-cx-padscale): match complete 48px list rows and the picture after opening, rebinding or resizing.
  var m=document.getElementById('keysmodal'), grid=m&&m.querySelector('.padeditgrid'), sc=grid&&grid.querySelector('.padactions');
  if(!sc||!m.classList.contains('on')) return;
  var h=Math.floor(grid.clientHeight/48)*48;
  if(h<48) return;
  sc.style.height=h+'px'; grid.querySelector('.padpicture').style.height=h+'px';
}
'@

SubRx @'
function padLayoutHtml(){
  return '<div class="padlayoutrow"><b>layout</b><div class="padlayoutpick"><button id="padlayoutprev" aria-label="previous layout">&lt;</button>'+
    '<button id="padlayout" aria-label="layout" aria-valuetext="'+padPresetName()+'">'+padPresetName()+'</button>'+
    '<button id="padlayoutnext" aria-label="next layout">&gt;</button></div></div>';
}
'@ @'
function padLayoutHtml(){
  // v28.xx (cw-cx-padscale): count belongs to the existing picker, with no extra selection control.
  var name=padPresetName(), n='-', i;
  for(i=0;i<PAD_PRESETS.length;i++) if(PAD_PRESETS[i].name===name) n=i+1;
  return '<div class="padlayoutrow"><b>layout</b><div class="padlayoutpick"><button id="padlayoutprev" aria-label="previous layout">&#8249;</button>'+
    '<button id="padlayout" aria-label="layout" aria-valuetext="'+name+'">'+name+'</button><span class="padlayoutcount">'+n+' / '+PAD_PRESETS.length+'</span>'+
    '<button id="padlayoutnext" aria-label="next layout">&#8250;</button></div></div>';
}
'@

SubRx @'
var VER='32.54';
'@ @'
var VER='32.55';
'@

$pat = "(?m)^  now:'v32\.54:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.55: A larger controller, an unscaled 20px action legend, 48px rebind rows and a preset count. Check 32.55 fails on v32.54',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
