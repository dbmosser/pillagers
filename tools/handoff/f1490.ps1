$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.89',what:
'@ @'
  {v:'14.90',what:'his words show on the item menu: a row of the Bandage menu reworded in his profile opens with his words (words audit finding 2)',
   run:function(){
     if(typeof openItemMenu!=='function'||typeof closeItemMenu!=='function'||!ITEMS.bandage) return 'SKIP: no item menu in this build';
     var bad=[], P0=__P(), keepTxt=null, label=null;
     function firstText(root){
       var w=document.createTreeWalker(root,NodeFilter.SHOW_TEXT,null,false), t;
       while((t=w.nextNode())){ if(t.nodeValue&&t.nodeValue.replace(/\s+/g,'').length>2&&!(/\d/).test(t.nodeValue)) return t.nodeValue; }
       return null;
     }
     try{
       __topClear();
       keepTxt=JSON.stringify(P0.txt||null);
       closeItemMenu(); openItemMenu(120,120,'bandage','stash',2);
       var m=document.querySelector('.imenu');
       // CONTROL: the menu opened with a row of words to reword.
       label=m?firstText(m):null;
       if(!label) return 'SKIP: the Bandage menu opened with no row of words here';
       closeItemMenu();
       P0.txt=P0.txt||{}; P0.txt[label]='ZQXW '+label;
       openItemMenu(120,120,'bandage','stash',2);
       m=document.querySelector('.imenu');
       if(!m||String(m.textContent).indexOf('ZQXW ')<0) bad.push('the row '+label+' was reworded in his profile and the menu still opened with the original words');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ closeItemMenu(); }catch(_m){} try{ P0.txt=JSON.parse(keepTxt); if(P0.txt===null) delete P0.txt; }catch(_r){} try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
