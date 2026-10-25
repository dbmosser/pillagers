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

if ($s.Contains("  {v:'34.55',what:")) { throw "check 34.55 is in the fixture already" }

SubRx @'
  {v:'34.54',what:
'@ @'
  {v:'34.55',what:'cw-setrevert (job 113): the settings detail pane does not repeat the row value and runs the full list height, a jump chip taking the pad focus never scrolls the list, and the expmode list rule has no raw hex colour',
   run:function(){
     var bad=[], l, d, v, c, s0, i, oS=(typeof sndUi==='function')?sndUi:null, f0=PAD.focus, css;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(oS) sndUi=function(){};
       openSettings('display'); try{ window.__setDetailSync(); }catch(_s){}
       l=document.getElementById('setlist'); d=document.getElementById('setdetail');
       v=d&&d.querySelector('.sdv'); if(v&&getComputedStyle(v).display!=='none') bad.push('the detail pane repeats the row value');
       if(l&&d&&d.getBoundingClientRect().height<l.getBoundingClientRect().height-4) bad.push('detail pane is '+Math.round(d.getBoundingClientRect().height)+' tall against the list '+Math.round(l.getBoundingClientRect().height));
       c=l.querySelectorAll('.setjump button[data-sec]');
       if(c.length){ l.scrollTop=2000; s0=Math.round(l.scrollTop); for(i=0;i<c.length;i++) padSetFocus(c[i]); if(Math.abs(Math.round(l.scrollTop)-s0)>1) bad.push('focusing the jump chips moved the list from '+s0+' to '+Math.round(l.scrollTop)); }
       css=(document.getElementById('ui-shared')||{textContent:''}).textContent;
       if(/settingsmodal\.expmode #setlist\{[^}]*#[0-9a-fA-F]{3,8}\b/.test(css)) bad.push('the expmode list rule has a raw hex colour');
       return bad.length?bad.join('; '):null;
     } finally {
       try{ var o=document.querySelector('.padfocus'); if(o) o.classList.remove('padfocus'); PAD.focus=f0; }catch(_f){}
       if(oS) sndUi=oS;
       document.getElementById('settingsmodal').classList.remove('on');
       try{ __endRaid('abandon'); }catch(_e){} __runPrep(); applyMenuZoom(); __topClear();
     } }},
  {v:'34.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
