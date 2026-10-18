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

if ($s.Contains("  {v:'30.85',what:")) { throw "check 30.85 is in the fixture already" }

SubRx @'
  {v:'30.84',what:
'@ @'
  {v:'30.85',what:'menu motion has bounce (his Q47): a window rises 24 px and runs 6 to 10 percent past home before it settles, opacity never goes over 1, the confirm pulse peaks at 1.08, and a press mid-open still starts at once',
   run:function(){
     if(typeof UIM!=='object'||!UIM||typeof UIM.step!=='function') return 'no motion layer (no UIM)';
     var m=document.getElementById('partymodal'), was, bad=[], mn=0, mx=0, i, s, btn, k;
     if(!m) return 'SKIP: no party window';
     was=m.classList.contains('on');
     try{
       __topClear(); __runPrep();
       UIM.manual=true;
       m.classList.remove('on'); UIM.chg(m); UIM.clearAll(); m.classList.add('on'); UIM.chg(m);
       for(i=0;i<60;i++){ UIM.step(8); s=m.__uim; if(!s) break; if(s.y<mn) mn=s.y; if(s.a>mx) mx=s.a; }
       if(!(mn<=-1.44&&mn>=-2.4)) bad.push('the open rise runs '+(-mn).toFixed(2)+' px past home, '+(-mn/24*100).toFixed(1)+' percent of 24 px, want 6 to 10');
       if(mx>1.0001) bad.push('the opacity went to '+mx.toFixed(3));
       UIM.step(600);
       if(m.__uim||m.style.translate!=='') bad.push('the open leaves its values on the window');
       btn=document.getElementById('closeparty');
       if(!btn) bad.push('SKIP pulse: no close button');
       else { UIM.press(btn,'ok'); UIM.step(60); k=parseFloat(btn.style.scale)||1; if(Math.abs(k-1.08)>0.006) bad.push('the confirm pulse peaks at '+k.toFixed(3)+', want 1.08'); UIM.step(80); }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ UIM.manual=false; if(!was){ m.classList.remove('on'); UIM.chg(m); } UIM.clearAll(); if(was&&!m.classList.contains('on')) m.classList.add('on'); }catch(_f){}
       try{ __topClear(); }catch(_t){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.84',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
