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

if ($s.Contains("  {v:'30.05',what:")) { throw "check 30.05 is in the fixture already" }

SubRx @'
  {v:'30.04',what:
'@ @'
  {v:'30.05',what:'the rebind callout is one short line without "ten seconds", and the Settings detail pane hides its repeated title and value',
   run:function(){
     var bad=[], el, t, d, k, h, padWas=document.body.classList.contains('padon');
     __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     try{
       el=document.createElement('div'); document.body.appendChild(el);
       PADB.waiting=0; padNoteShow(el); t=el.textContent; PADB.waiting=null;
       if(/ten seconds/i.test(t)) bad.push('the pad rebind callout still explains: '+t);
       if(/\.\s/.test(t)||/\.$/.test(t)) bad.push('the pad rebind callout is a sentence: '+t);
       KEYS.waiting=KEYS_ACTS[0][0]; keysNoteShow.call(null); KEYS.waiting=null;
       el.remove();
       document.body.classList.remove('padon');
       openSettings('display');
       if(typeof window.__setDetailSync==='function') window.__setDetailSync();
       d=document.getElementById('setdetail'); k=d&&d.querySelector('.sdk'); h=d&&d.querySelector('.sdh');
       if(k&&getComputedStyle(k).display!=='none') bad.push('the detail pane still repeats the row title');
       if(!d) bad.push('no detail pane');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ PADB.waiting=null; KEYS.waiting=null; var q=document.getElementById('settingsmodal'); if(q) q.classList.remove('on'); }catch(_k){} try{ __topClear(); }catch(_c){} document.body.classList.toggle('padon',padWas); }
     return bad.length?bad.join('; '):null; }},
  {v:'30.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
