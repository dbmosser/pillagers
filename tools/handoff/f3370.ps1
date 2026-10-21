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

if ($s.Contains("  {v:'33.70',what:")) { throw "check 33.70 is in the fixture already" }

SubRx @'
  {v:'33.69',what:
'@ @'
  {v:'33.70',what:'news frame clears currency and pairs a large existing version with the notes; recorder keeps a bounded six-line preview and a 32px restore gap',
   run:function(){
     var bad=[],ta=document.getElementById('exporttext'),oldValue;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080);applyMenuZoom();openSettings('rec');oldValue=ta.value;
       var ts=getComputedStyle(ta),actions=ta.nextElementSibling,restore=actions.nextElementSibling;
       if(parseFloat(ts.height)<183||ta.getBoundingClientRect().height>240.5)bad.push('preview is not the bounded six-line height');
       if(parseFloat(ts.lineHeight)!==24||parseFloat(ts.paddingBottom)<22)bad.push('preview lines have no padding before fade');
       if(Math.abs(parseFloat(getComputedStyle(restore).marginTop)-32)>1)bad.push('restore is still pinned apart from the log');
       var help=restore.querySelector('.msub');if(parseFloat(getComputedStyle(help).fontSize)<16)bad.push('restore helper is below 16px');
       if(ta.value!==oldValue)bad.push('report data changed');
       document.getElementById('settingsmodal').classList.remove('on');wnOpen();
       var news=document.getElementById('wnmodal'),ns=getComputedStyle(news),frame=getComputedStyle(news,'::before'),sub=document.getElementById('wnsub'),list=document.getElementById('wnlist'),row=list.firstElementChild;
       if(ns.display!=='grid'||parseFloat(getComputedStyle(sub).fontSize)<56||parseFloat(getComputedStyle(row).minHeight)<112)bad.push('news lacks the version and notes composition');
       if(frame.backgroundImage!=='none')bad.push('news still has the stray accent tab');
       var hud=document.getElementById('topright'),hs=getComputedStyle(hud),hr=hud.getBoundingClientRect(),nr=news.getBoundingClientRect(),zoom=parseFloat(news.style.zoom)||1,frameTop=nr.top+parseFloat(frame.top)*zoom;
       if(hs.visibility!=='hidden'&&hs.display!=='none'&&hr.width>0&&frameTop<hr.bottom+24)bad.push('news frame overlaps the currency strip');
       return bad.length?bad.join('; '):null;
     }finally{
       if(ta&&oldValue!==undefined)ta.value=oldValue;
       ['settingsmodal','wnmodal'].forEach(function(id){document.getElementById(id).classList.remove('on');});
       try{__endRaid('abandon');}catch(_e){}__runPrep();applyMenuZoom();__topClear();
     }}},
  {v:'33.69',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
