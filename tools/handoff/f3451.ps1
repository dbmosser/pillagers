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

if ($s.Contains("  {v:'34.51',what:")) { throw "check 34.51 is in the fixture already" }

SubRx @'
  {v:'34.50',what:
'@ @'
  {v:'34.51',what:'cw-playdata (job 113): the SEND PLAY DATA page opens with the export text folded away, show data opens the same text buildExport() returns, the one line summary names the runs, and copy still copies exactly that text (folded again after)',
   run:function(){
     var bad=[], ta, sb, ex=document.execCommand, sel=null, want, sum;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080); applyMenuZoom(); openSettings('rec');
       ta=document.getElementById('exporttext'); sb=document.getElementById('showdata');
       if(!sb) return 'the play data page has no show data button';
       want=buildExport();
       if(getComputedStyle(ta).display!=='none') bad.push('the export text is open on arrival, a raw dump under the hero');
       if(ta.value!==want) bad.push('the folded export text is not what buildExport returns');
       sum=document.getElementById('expsum'); if(!sum||!/\d+ runs?/.test(sum.textContent)) bad.push('no one line summary of what will be sent ['+(sum&&sum.textContent)+']');
       sb.click();
       if(getComputedStyle(ta).display==='none') bad.push('show data does not show the text');
       if(ta.value!==want) bad.push('shown export text differs from buildExport');
       sb.click();
       if(getComputedStyle(ta).display!=='none') bad.push('a second press does not fold the text away again');
       document.execCommand=function(c){ if(c!=='copy') return false; var e=document.activeElement; sel=(e&&typeof e.value==='string'&&e.selectionStart!=null)?e.value.substring(e.selectionStart,e.selectionEnd):null; return true; };
       document.getElementById('copybtn').onclick();
       if(sel!==want) bad.push('copy while folded does not copy the whole export text ['+(sel===null?'nothing selected':sel.length+' of '+want.length+' chars')+']');
       if(getComputedStyle(ta).display!=='none') bad.push('a copy that worked leaves the text open');
       return bad.length?bad.join('; '):null;
     } finally {
       document.execCommand=ex;
       try{ expShow(0); }catch(_e){}
       document.getElementById('settingsmodal').classList.remove('on');
       try{ __endRaid('abandon'); }catch(_e){} __runPrep(); applyMenuZoom(); __topClear();
     } }},
  {v:'34.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
