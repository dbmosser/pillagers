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

# No all-caps text outside the menus (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(cur!==v){ tn.__txo=o; tn.nodeValue=v; hit++; }
  }
  return hit;
}
function txWatch(){
  if(TXOBS||typeof MutationObserver!=='function') return;
  var root=document.getElementById('root'); if(!root) return;

'@ @'
    if(cur!==v){ tn.__txo=o; tn.nodeValue=v; hit++; }
  }
  // v28.xx (cw-nocaps-dom), HIS HARD RULE (2026-10-18): "all text shown to the player, should never ever ever be in all caps". The words in a
  // tooltip, a placeholder or an aria label are shown too, so they go through the case fix as well (ncFix only: not his P.txt map).
  var _ae=[root], _aq=root.querySelectorAll?root.querySelectorAll('[title],[placeholder],[aria-label]'):[], _ai, _an, _aa=['title','placeholder','aria-label'], _av, _nv;
  for(_ai=0;_ai<_aq.length;_ai++) _ae.push(_aq[_ai]);
  for(_ai=0;_ai<_ae.length;_ai++) if(_ae[_ai].getAttribute) for(_an=0;_an<3;_an++){ _av=_ae[_ai].getAttribute(_aa[_an]); if(_av){ _nv=ncFix(_av); if(_nv!==_av){ _ae[_ai].setAttribute(_aa[_an],_nv); hit++; } } }
  return hit;
}
function txWatch(){
  if(TXOBS||typeof MutationObserver!=='function') return;
  var root=document.body||document.getElementById('root'); if(!root) return;   // v28.xx (cw-nocaps-dom): the whole page, not only #root (the attract card, the REC mark, the fps box sit outside it)

'@

SubRx @'
TXOBS.observe(root,{childList:true,subtree:true,characterData:true});
'@ @'
TXOBS.observe(root,{childList:true,subtree:true,characterData:true,attributes:true,attributeFilter:['title','placeholder','aria-label']});   // v28.xx (cw-nocaps-dom)
'@

SubRx @'
  TXOBS=new MutationObserver(function(){
    if(TXBUSY) return;
    TXBUSY=1;
    try{ txDom(root); } finally { TXBUSY=0; }
  });

'@ @'
  TXOBS=new MutationObserver(function(recs){
    if(TXBUSY) return;
    TXBUSY=1;
    // v28.xx (cw-nocaps-dom): what changed inside #root is swept as before; what changed elsewhere on the page is swept where it changed, so a
    // counter that moves every frame outside #root does not cost a walk of the whole page
    try{
      var rt=document.getElementById('root'), inR=!recs||!recs.length, outs=[], k, t;
      for(k=0;recs&&k<recs.length;k++){ t=recs[k].target; if(t&&t.nodeType===3) t=t.parentNode;
        if(!t||(rt&&rt.contains(t))) inR=true; else if(outs.indexOf(t)<0) outs.push(t); }
      if(inR&&rt) txDom(rt); else if(inR) txDom(root);
      for(k=0;k<outs.length;k++) if(outs[k].nodeType===1) txDom(outs[k]);
    } finally { TXBUSY=0; }
  });

'@

SubRx @'
content:'TAKEN';
'@ @'
content:'Taken';
'@

SubRx @'
('NEED $'+(GAMBLE_PRICE-P.credits).toLocaleString()+' MORE')
'@ @'
('Need \u0024'+(GAMBLE_PRICE-P.credits).toLocaleString()+' more')/* v28.xx (cw-nocaps-dom): never all caps */
'@

SubRx @'
('NEED $'+(WIRT_LOT_PRICE-P.credits).toLocaleString()+' MORE')
'@ @'
('Need \u0024'+(WIRT_LOT_PRICE-P.credits).toLocaleString()+' more')/* v28.xx (cw-nocaps-dom): never all caps */
'@

SubRx @'
document.title='PILLAGERS, PLAYER 2';
'@ @'
document.title='Pillagers, player 2';   /* v28.xx (cw-nocaps-dom): never all caps */
'@

SubRx @'
var VER='29.13';
'@ @'
var VER='29.14';
'@

$pat = "(?m)^  now:'v29\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.14: Tooltips, placeholders and text outside the menus show in sentence case too. Check 29.14 fails on v29.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
