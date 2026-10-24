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

if ($s.Contains("  {v:'34.52',what:")) { throw "check 34.52 is in the fixture already" }

SubRx @'
  {v:'34.51',what:
'@ @'
  {v:'34.52',what:'cw-playdata2 (job 113): the play data summary is the page headline (32px), the restore helper is one short line without the word above, and the superhot pane packs to its content (not stretched to the full list height)',
   run:function(){
     var bad=[], sum, help, det, list;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080); applyMenuZoom(); openSettings('rec');
       sum=document.getElementById('expsum'); help=document.querySelector('#spane_rec > div:has(> #rescode) > .msub');
       if(!sum||!help) return 'play data page parts missing';
       if(parseFloat(getComputedStyle(sum).fontSize)<32) bad.push('the summary is not the 32px headline ['+getComputedStyle(sum).fontSize+']');
       if(help.textContent.length>60||/above/i.test(help.textContent)) bad.push('the restore helper is still an explaining sentence ['+help.textContent+']');
       openSettings(); det=document.getElementById('setdetail'); list=document.getElementById('setlist');
       if(window.__setDetailSync) window.__setDetailSync();
       if(det&&det.innerHTML&&list&&det.getBoundingClientRect().height>list.getBoundingClientRect().height*0.7) bad.push('the detail pane is a tall empty box ['+Math.round(det.getBoundingClientRect().height)+' of '+Math.round(list.getBoundingClientRect().height)+']');
       return bad.length?bad.join('; '):null;
     } finally {
       document.getElementById('settingsmodal').classList.remove('on');
       try{ __endRaid('abandon'); }catch(_e){} __runPrep(); applyMenuZoom(); __topClear();
     } }},
  {v:'34.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
