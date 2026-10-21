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

if ($s.Contains("  {v:'33.56',what:")) { throw "check 33.56 is in the fixture already" }

SubRx @'
  {v:'33.55',what:
'@ @'
  {v:'33.56',what:'public recorder has a bounded lowercase preview and primary copy action while preserving raw data, and pause news uses body size',
   run:function(){
     var ta=document.getElementById('exporttext'), oldValue, probe=null, bad=[];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080); applyMenuZoom();
       openSettings('rec'); oldValue=ta.value; ta.value='REPORT Case Probe';
       var ts=getComputedStyle(ta), copy=document.getElementById('copybtn'), cs=getComputedStyle(copy), root=document.getElementById('root');
       if(ta.getBoundingClientRect().height<1||ta.getBoundingClientRect().height>240.5) bad.push('raw preview exceeds 240px: height '+ta.getBoundingClientRect().height+', zoom '+document.getElementById('settingsmodal').style.zoom);
       if(parseFloat(ts.fontSize)<16||parseFloat(ts.lineHeight)<24||ts.textTransform!=='lowercase') bad.push('preview does not use readable lowercase text: '+ts.fontSize+'/'+ts.lineHeight+', transform '+ts.textTransform);
       if(ta.value!=='REPORT Case Probe') bad.push('display styling changed the raw report');
       probe=document.createElement('span'); probe.style.color='var(--acc)'; root.appendChild(probe);
       if(cs.backgroundColor!==getComputedStyle(probe).color||copy.getBoundingClientRect().height<56) bad.push('copy is not the primary 56px action');
       var res=document.getElementById('rescode'); if(res.getBoundingClientRect().height<56) bad.push('restore field is under 56px');
       document.getElementById('settingsmodal').classList.remove('on');
       wnOpen(); var list=document.getElementById('wnlist'); probe.style.fontSize='var(--fs-body)';
       if(list.getBoundingClientRect().height<1||getComputedStyle(list).fontSize!==getComputedStyle(probe).fontSize) bad.push('news notes do not use the shared body size');
       return bad.length?bad.join('; '):null;
     } finally {
       if(ta&&oldValue!==undefined) ta.value=oldValue; if(probe) probe.remove();
       ['settingsmodal','wnmodal'].forEach(function(id){var el=document.getElementById(id);if(el)el.classList.remove('on');});
       try{__endRaid('abandon');}catch(_e){} __runPrep(); applyMenuZoom(); __topClear();
     } }},
  {v:'33.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
