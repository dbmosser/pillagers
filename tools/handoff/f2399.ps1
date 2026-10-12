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

if ($s.Contains("  {v:'23.99',what:")) { throw "check 23.99 is in the fixture already" }

SubRx @'
  {v:'23.98',what:
'@ @'
  {v:'23.99',what:'his #39 (keyboard first): RETRY on the title, while it shows, is one of the rows the arrows walk, and ENTER on it presses RETRY and not the 1 PLAYER start',
   run:function(){
     if(typeof netTitleRows!=='function'||typeof netTitleMove!=='function'||typeof netTitleEnter!=='function'||typeof padSetFocus!=='function') return 'SKIP: no title rows here';
     var rt=document.getElementById('moderetry'), bad=[], d0, oc, f0=(typeof PAD!=='undefined'&&PAD)?PAD.focus:null, hits=0, starts=0, rows, i, seen=false, r;
     if(!rt) return 'SKIP: no RETRY on this title';
     d0=rt.style.display; oc=rt.onclick;
     try{
       rt.style.display='';
       rows=netTitleRows();
       if(rows.indexOf(rt)<0) bad.push('RETRY shows but is not one of the rows the arrows walk ('+rows.length+' rows)');
       padSetFocus(null); PAD.focus=null;
       for(i=0;i<rows.length+2;i++){ netTitleMove(1); if(PAD.focus===rt) seen=true; }
       if(!seen) bad.push('the down arrow never lands on RETRY');
       rt.onclick=function(){ hits++; };
       padSetFocus(rt);
       r=netTitleEnter(function(){ starts++; });
       if(hits!==1) bad.push('ENTER on RETRY did not press it ('+hits+' presses, returned '+r+')');
       if(starts) bad.push('ENTER on RETRY ran the 1 PLAYER start');
       rt.style.display='none';
       if(netTitleRows().indexOf(rt)>=0) bad.push('a hidden RETRY is still a row');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       rt.style.display=d0; rt.onclick=oc;
       try{ padSetFocus(null); PAD.focus=null; if(f0) padSetFocus(f0); }catch(_f){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
