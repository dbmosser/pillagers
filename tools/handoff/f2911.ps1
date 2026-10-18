$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'29.11',what:")) { throw "check 29.11 is in the fixture already" }

SubRx @'
  {v:'29.10',what:
'@ @'
  {v:'29.11',what:'no all-caps text: canvas text, menu text and the tab title come out in sentence case (his hard rule 2026-10-18)',
   run:function(){
     if(typeof txRecord!=='function'||typeof txDom!=='function') return 'SKIP: no text door';
     var i, j, t, w, tw, root, els, el, nd, hits, cv, bad=[];
     function capsWord(x){ var m, re=/(^|[^A-Za-z0-9'])([A-Z]{3,})(?![A-Za-z0-9'])/g; while((m=re.exec(x))){ w=m[2]; if(!NCKEEP[w]&&!/^[IVX]+$/.test(w)) return w; } return null; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(document.title!==document.title.replace(/[A-Z]{3,}/g,'x')) return 'the tab title is in capitals: '+document.title;
       cv=document.createElement('canvas').getContext('2d');
       hits=txRecord(function(){ cv.fillText('MACHINE ALERT',0,0); cv.fillText('HE NEEDS AN ARMOUR PLATE',0,0); cv.fillText('+50 SP  \u00b7  2P LMG  \u00b7  AK-47',0,0); });
       if(!hits.length||hits[0].t!=='Machine alert') return 'MACHINE ALERT is drawn as '+(hits.length?hits[0].t:'nothing');
       if(hits[1].t!=='He needs an armour plate') return 'a caps line is drawn as '+hits[1].t;
       if(hits[2].t!=='+50 SP  \u00b7  2P LMG  \u00b7  AK-47') return 'acronyms were changed: '+hits[2].t;
       root=document.getElementById('root'); if(!root) return 'SKIP: no root';
       els=root.querySelectorAll('*');
       for(i=0;i<els.length;i++){ el=els[i];
         for(j=0;j<el.childNodes.length;j++){ nd=el.childNodes[j]; if(nd.nodeType===3&&/[A-Za-z]/.test(nd.nodeValue)){ if(getComputedStyle(el).textTransform==='uppercase') return 'menu text is forced to capitals by CSS: '+(el.id||el.className||el.tagName)+' "'+nd.nodeValue.slice(0,30)+'"'; break; } } }
       txDom(root);
       tw=document.createTreeWalker(root,NodeFilter.SHOW_TEXT,{acceptNode:function(n){ var p=n.parentNode&&n.parentNode.nodeName; return (p==='SCRIPT'||p==='STYLE')?NodeFilter.FILTER_REJECT:NodeFilter.FILTER_ACCEPT; }},false);
       while((nd=tw.nextNode())){ t=capsWord(nd.nodeValue||''); if(t) bad.push(t+' in "'+nd.nodeValue.slice(0,40)+'"'); }
       if(bad.length) return 'menu text still has capitals: '+bad.slice(0,3).join(' | ');
       if(typeof __frame==='function'){
         __deploy({kit:[],safe:null,mapIx:0,seed:4242});
         if(!__state()||!__state().player) return 'SKIP: no raid';
         hits=txRecord(function(){ __frame(); __frame(); });
         for(i=0;i<hits.length;i++){ t=capsWord(String(hits[i].t)); if(t) bad.push(t+' in "'+String(hits[i].t).slice(0,40)+'"'); }
         if(bad.length) return 'a raid frame draws capitals: '+bad.slice(0,3).join(' | ');
       }
       return null;
     } finally {
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'29.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
