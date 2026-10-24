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

if ($s.Contains("  {v:'34.53',what:")) { throw "check 34.53 is in the fixture already" }

SubRx @'
  {v:'34.52',what:
'@ @'
  {v:'34.53',what:'cw-playdata3 (job 113): the settings detail pane shows an on value in the accent colour and an off value muted, and the restore warning on the play data page is body size',
   run:function(){
     var bad=[], det, v, help, c0, c1;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __forceSize(1920,1080); applyMenuZoom(); openSettings('rec');
       help=document.querySelector('#spane_rec > div:has(> #rescode) > .msub');
       if(!help) return 'restore helper missing';
       if(parseFloat(getComputedStyle(help).fontSize)<20) bad.push('the restore warning is below body size ['+getComputedStyle(help).fontSize+']');
       openSettings(); det=document.getElementById('setdetail');
       if(window.__setDetailSync) window.__setDetailSync();
       v=det&&det.querySelector('.sdv'); if(!v) return 'SKIP: no value in the detail pane';
       c0=getComputedStyle(v).color;
       v.classList.add('on'); c1=getComputedStyle(v).color; v.classList.remove('on');
       if(c0===c1) bad.push('an on value is not lit differently from an off value ['+c0+']');
       if(/230, 255, 61/.test(c0)) bad.push('an off value is drawn in the accent colour');
       return bad.length?bad.join('; '):null;
     } finally {
       document.getElementById('settingsmodal').classList.remove('on');
       try{ __endRaid('abandon'); }catch(_e){} __runPrep(); applyMenuZoom(); __topClear();
     } }},
  {v:'34.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
