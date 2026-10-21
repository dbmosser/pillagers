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

if ($s.Contains("  {v:'33.67',what:")) { throw "check 33.67 is in the fixture already" }

SubRx @'
  {v:'33.66',what:
'@ @'
  {v:'33.67',what:'news has a structured newest row and clear header while the recorder column is centered with readable restore actions and a fading raw preview',
   run:function(){
     var bad=[],probe=null,ta=document.getElementById('exporttext'),oldValue;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080); applyMenuZoom();
       openSettings('rec'); oldValue=ta.value;
       var sm=document.getElementById('settingsmodal'),pane=document.getElementById('spane_rec'),ps=getComputedStyle(pane),pr=pane.getBoundingClientRect(),mr=sm.getBoundingClientRect();
       if(parseFloat(ps.maxWidth)>1100||Math.abs(pr.left+pr.width/2-mr.left-mr.width/2)>2) bad.push('recorder column is not centered within 1100px');
       var block=ta.nextElementSibling.nextElementSibling,title=block.firstElementChild;
       if(parseFloat(getComputedStyle(title).fontSize)<20) bad.push('restore title is below body size');
       if(getComputedStyle(ta).maskImage==='none') bad.push('raw preview has no bottom fade');
       if(ta.getBoundingClientRect().height>240.5) bad.push('raw preview exceeds 240px');
       probe=document.createElement('span');probe.style.color='var(--tx-1)';document.getElementById('root').appendChild(probe);
       var logStyle=getComputedStyle(ta);
       if(logStyle.color!==getComputedStyle(probe).color||logStyle.whiteSpace!=='pre-wrap'||logStyle.overflowWrap!=='anywhere')bad.push('raw preview is not bright and wrapped');
       ['resread','wipelog'].forEach(function(id){var s=getComputedStyle(document.getElementById(id));if(parseFloat(s.fontSize)<20||parseFloat(s.minHeight)<48)bad.push(id+' is not a readable action');});
       if(ta.value!==oldValue) bad.push('layout changed the raw report');
       sm.classList.remove('on'); wnOpen();
       var list=document.getElementById('wnlist'),row=list.firstElementChild,rs=getComputedStyle(row),close=document.getElementById('wnclose').getBoundingClientRect(),hud=document.getElementById('topright'),hs=getComputedStyle(hud),hr=hud.getBoundingClientRect();
       probe.style.color='var(--ui-raised)';
       if(parseFloat(rs.minHeight)<72||rs.backgroundColor!==getComputedStyle(probe).color||rs.boxShadow==='none') bad.push('newest news row has no 72px raised treatment and accent');
       if(hs.visibility!=='hidden'&&hs.display!=='none'&&hr.width>0&&!(hr.bottom+24<=close.top||close.bottom+24<=hr.top||hr.right+24<=close.left||close.right+24<=hr.left)) bad.push('news close button is within 24px of currency');
       var toast=getComputedStyle(document.getElementById('hubtoast'));if(toast.visibility!=='hidden')bad.push('floor toast appears over news');
       return bad.length?bad.join('; '):null;
     }finally{
       if(ta&&oldValue!==undefined)ta.value=oldValue;if(probe)probe.remove();
       ['settingsmodal','wnmodal'].forEach(function(id){document.getElementById(id).classList.remove('on');});
       try{__endRaid('abandon');}catch(_e){} __runPrep();applyMenuZoom();__topClear();
     }}},
  {v:'33.66',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
