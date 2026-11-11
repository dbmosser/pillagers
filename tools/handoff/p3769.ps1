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

# READABLE STASH BREAK DOWN MENU (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .imenukeys button.mine{ color:#111315; background:var(--amber); border-color:var(--amber); }
'@ @'
  .imenukeys button.mine{ color:#111315; background:var(--amber); border-color:var(--amber); }
  /* v28.xx (cw-cx-breakgunmenu): the break down hint inherits the menu font, with readable rows and two equal key rows. */
  .imenu.stash-actions{box-sizing:border-box;width:400px;min-width:0;max-width:calc(100vw - 16px);padding:0;overflow:auto;overscroll-behavior:contain;background:var(--ui-panel);border:1px solid var(--ui-line-hi);border-radius:var(--rad);box-shadow:none;font:600 21.8px/1.25 var(--f-cond);color:var(--tx-1);}
  .stash-actions .imenuhead{min-height:48px;box-sizing:border-box;padding:12px 16px;border-color:var(--ui-line);}
  .stash-actions .imenuhead b{font:600 21.8px/1.2 var(--f-cond);letter-spacing:0;color:var(--tx-1);}
  .stash-actions .imenuhead em,.stash-actions .imenurow em{font:400 17.4px/1.35 var(--f-body);letter-spacing:0;color:var(--tx-2);}
  .stash-actions .imenurow{min-height:48px;box-sizing:border-box;padding:10px 16px;gap:16px;}
  .stash-actions .imenurow>span{flex:0 0 auto;white-space:nowrap;}
  .stash-actions .imenurow em{min-width:0;text-align:right;}
  .stash-actions .imenurow:hover{background:var(--ui-raised);color:var(--tx-1);}
  .stash-actions .imenusep{margin:0;background:var(--ui-line);}
  .stash-actions .imenukeys{display:grid;grid-template-columns:repeat(5,minmax(0,1fr));gap:8px;padding:12px 16px;}
  .stash-actions .imenukeys>span{grid-column:1/-1;margin:0;font:600 17.4px/1.3 var(--f-cond);color:var(--tx-2);}
  .stash-actions .imenukeys button{box-sizing:border-box;width:100%;height:32px;min-height:32px;padding:0;border:1px solid var(--ui-line-hi);border-radius:var(--rad);font:600 17.4px/1 var(--f-cond);color:var(--tx-1);background:var(--ui-raised);}
  .stash-actions .imenukeys button.mine{color:var(--tx-1);border-color:var(--tx-2);background:var(--ui-raised);}
  .stash-actions .imenurow.padfocus,.stash-actions button.padfocus{outline:2px solid var(--acc)!important;outline-offset:-2px;background:var(--ui-raised)!important;}
  /* v28.xx (cw-cx-breakgunmenu): rarity is the guide's 3px foot bar; quantity is neutral and the pad focus keeps its own outline. */
  html #root #hub #stashgrid .cell{border-color:var(--ui-line)!important;background:var(--ui-raised)!important;box-shadow:inset 0 -3px 0 var(--bar,transparent)!important;}
  html #root #hub #stashgrid .cell:hover{background:var(--ui-hover)!important;}
  html #root #hub #stashgrid .cell .cnt{color:var(--tx-1)!important;background:var(--ui-panel)!important;}
  /* v28.xx (cw-cx-breakgunmenu): a reserved wanted row keeps the grid height stable, including when the strip is hidden. */
  html #root #hub .stash-title{display:grid;grid-template-columns:1fr auto;grid-template-rows:24px 32px;column-gap:16px;row-gap:8px;align-items:center;}
  html #root #hub .stash-title>em{grid-column:2;grid-row:1;}
  html #root #hub .stash-title #wanted{grid-column:1/-1;grid-row:2;gap:24px!important;margin:0!important;padding-top:8px;border-top:1px solid var(--ui-line);}
  html #root #hub #wanted [data-want] b{font-weight:400!important;}
  html #root #hub #wanted [data-want] img{filter:grayscale(1);}
  /* v28.xx (cw-cx-breakgunmenu): the bag value already appears in the header. */
  html #root #hub #kitcol>.lohead>em:has(#kitval){display:none;}
'@

SubRx @'
function openItemMenu(x,y,key,ctx,count){
'@ @'
// v28.xx (cw-cx-breakgunmenu): keep stash actions clear of occupied tiles and the floating stat card, in screen pixels before zoom conversion.
function stashMenuPlace(m,x,y,z){
  var grid=document.getElementById('stashgrid'), cols=document.getElementById('invcols');
  if(!grid||!cols) return;
  var gr=grid.getBoundingClientRect(), cr=cols.getBoundingClientRect(), gap=8*Math.max(1,z);
  var left=Math.max(4,cr.left), top=Math.max(4,gr.top), right=Math.min(window.innerWidth-4,cr.right), bottom=Math.min(window.innerHeight-4,cr.bottom);
  m.style.maxWidth=Math.max(120,(right-left)/z)+'px';
  m.style.maxHeight=Math.max(48,(bottom-top)/z)+'px';
  var w=m.offsetWidth*z,h=m.offsetHeight*z, blocks=[], cells=grid.querySelectorAll('.cell'), source=null, last=gr.top;
  for(var i=0;i<cells.length;i++){
    var b=cells[i].getBoundingClientRect(); if(!b.width||!b.height||b.bottom<=gr.top||b.top>=gr.bottom) continue;
    blocks.push(b); last=Math.max(last,Math.min(b.bottom,gr.bottom));
    if(x>=b.left&&x<=b.right&&y>=b.top&&y<=b.bottom) source=b;
  }
  var packed=document.querySelectorAll('#kitgrid .cell:not(.slotempty)'), d=document.getElementById('stashdetail');
  for(var j=0;j<packed.length;j++){ var p=packed[j].getBoundingClientRect(); if(p.width&&p.height) blocks.push(p); }
  if(d&&d.classList.contains('sdon')){ var dr=d.getBoundingClientRect(); if(dr.width&&dr.height) blocks.push(dr); }
  source=source||{left:gr.left,right:gr.left,top:gr.top,bottom:gr.top};
  var choices=[[source.left,source.bottom+gap],[source.left,last+gap],[gr.right+gap,source.top],[gr.left-w-gap,source.top],[source.left,source.top-h-gap],[right-w,top]], best=null, least=Infinity;
  for(var q=0;q<choices.length;q++){
    var cx=Math.max(left,Math.min(choices[q][0],right-w)), cy=Math.max(top,Math.min(choices[q][1],bottom-h)), score=0;
    for(var k=0;k<blocks.length;k++){ var r=blocks[k]; score+=Math.max(0,Math.min(cx+w,r.right+gap)-Math.max(cx,r.left-gap))*Math.max(0,Math.min(cy+h,r.bottom+gap)-Math.max(cy,r.top-gap)); }
    if(score<least){ best=[cx,cy]; least=score; } if(!score) break;
  }
  if(best){ m.style.left=(best[0]/z)+'px'; m.style.top=(best[1]/z)+'px'; }
}
function openItemMenu(x,y,key,ctx,count){
'@

SubRx @'
  var it=ITEMS[key]; if(!it) return;
  var m=document.createElement('div'); m.className='imenu';
  // v8.19, audit: the menu itself swallows a right-click, or the browser stacks
'@ @'
  var it=ITEMS[key]; if(!it) return;
  var m=document.createElement('div'); m.className='imenu';
  // v28.xx (cw-cx-breakgunmenu): only the career stash menu uses the wider part-hint layout.
  if(ctx==='stash'&&document.getElementById('hub').classList.contains('on')) m.classList.add('stash-actions');
  // v8.19, audit: the menu itself swallows a right-click, or the browser stacks
'@

SubRx @'
  m.style.top=Math.max(4,Math.min(y,window.innerHeight/_mz-h-8))+'px';
  IMENU=m;
}
// Closing. Anywhere outside, Escape, or the next right-click.
'@ @'
  m.style.top=Math.max(4,Math.min(y,window.innerHeight/_mz-h-8))+'px';
  if(m.classList.contains('stash-actions')) stashMenuPlace(m,x*_mz,y*_mz,_mz);
  IMENU=m;
}
// Closing. Anywhere outside, Escape, or the next right-click.
'@

SubRx @'
<div class="lohead">STASH<span id="wanted"
'@ @'
<div class="lohead stash-title">STASH<span id="wanted"
'@

SubRx @'
gearOpen('stash'); }; r3.appendChild(gb); }
'@ @'
gearOpen('stash'); }; r2.appendChild(gb); }
'@

SubRx @'
r3.appendChild(cxb); r3.appendChild(trb); tb.appendChild(r3);
'@ @'
r2.appendChild(cxb); r2.appendChild(trb); tb.appendChild(r3);
'@

SubRx @'
var VER='37.68';
'@ @'
var VER='37.69';
'@

$pat = "(?m)^  now:'v37\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.69: Stash actions use 20px painted labels and 16px hints at 1080p, a five by two key grid, and placement clear of occupied stash tiles and the stat card when space allows. Rarity stays in the 3px foot bar, quantities are neutral, wanted prices use a reserved sub-row, and gear, armory and trophy shortcuts sit together with the tabs. The repeated bag value is hidden. Check 37.69 fails on v37.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
