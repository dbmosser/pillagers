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

if ($s.Contains("  {v:'19.84',what:")) { throw "check 19.84 is in the fixture already" }

SubRx @'
  {v:'19.83',what:
'@ @'
  {v:'19.84',what:'menu paragraphs never end on one word: a paragraph that plain wrapping leaves with a single last word gets at least two words on its last line',
   run:function(){
     var d=document.createElement('div'), bad=[], k, txt=null, words='Selling salvage here pays credits and the same in XP for every piece you carry home from the surface tonight'.split(' ');
     function lastLineWords(){ var r=document.createRange(), sp=d.firstChild, rects, i, top=-1e9, lines={}, n; r.selectNodeContents(d); rects=[].slice.call(r.getClientRects()); if(!rects.length) return -1; for(i=0;i<rects.length;i++) top=Math.max(top,rects[i].top); var cnt=0; for(i=0;i<d.childNodes.length;i++){ var c=d.childNodes[i]; if(c.nodeType===1){ var b=c.getBoundingClientRect(); if(Math.abs(b.top-top)<2) cnt++; } } return cnt; }
     try{
       d.style.cssText='position:fixed;left:0;top:0;z-index:-5;font:16px sans-serif;visibility:hidden;width:200px';
       document.body.appendChild(d);
       if(d.getBoundingClientRect().width<=0) return 'SKIP: nothing lays out here';
       for(k=6;k<=words.length&&!txt;k++){
         d.innerHTML=words.slice(0,k).map(function(w){ return '<span>'+w+'</span>'; }).join(' ');
         d.style.textWrap='wrap';
         if(d.getClientRects().length&&lastLineWords()===1&&d.getBoundingClientRect().height>20*1.1) txt=k;
       }
       if(!txt) return 'SKIP: no test paragraph ends on one word here';
       d.style.textWrap='';
       if(lastLineWords()<2) bad.push('a paragraph still ends on a single word ('+txt+' words in 200px)');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ document.body.removeChild(d); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'19.83',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
