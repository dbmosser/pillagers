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

if ($s.Contains("  {v:'24.45',what:")) { throw "check 24.45 is in the fixture already" }

SubRx @'
  {v:'24.44',what:
'@ @'
  {v:'24.45',what:'his #50 (UI redesign ui5q1g, from the AAA judge of the Settings shot): the settings list starts on the left edge of the tabs, every row label is drawn in caps at 17px or more, THE RAID head is at full strength, and a game option value shows stepper arrows',
   run:function(){
     if(typeof renderSettings!=='function'||typeof openModal!=='function') return 'SKIP: no settings here';
     var bad=[], m=document.getElementById('settingsmodal'), was, tp, tb, b, s, hd, bt;
     if(!m) return 'SKIP: no settings window';
     was=m.classList.contains('on');
     try{
       __topClear(); openModal('settingsmodal'); renderSettings();
       tp=document.getElementById('spane_display'); tb=document.getElementById('settabs');
       if(tp&&tb&&tp.getClientRects().length&&Math.abs(tp.getBoundingClientRect().left-tb.getBoundingClientRect().left)>6) bad.push('the settings list starts '+Math.round(tp.getBoundingClientRect().left-tb.getBoundingClientRect().left)+'px right of the tabs');
       b=document.querySelector('#setlist .row button[id^="go_"]');
       b=b&&b.parentNode.querySelector('div > b');
       if(!b) bad.push('no game option row label found');
       else { s=getComputedStyle(b); if(s.textTransform!=='uppercase') bad.push('the row labels are not drawn in caps'); if(!(parseFloat(s.fontSize)>=17)) bad.push('a row label is '+s.fontSize); }
       hd=document.querySelector('#setlist .row[style*="opacity:.7"]');
       if(hd&&parseFloat(getComputedStyle(hd).opacity)<0.99) bad.push('THE RAID head is faded to '+getComputedStyle(hd).opacity);
       bt=document.querySelector('#setlist .row button[id^="go_"]');
       if(bt&&getComputedStyle(bt,'::after').content.indexOf('\u203a')<0) bad.push('a game option value has no stepper arrow');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); }catch(_c){} if(was) try{ openModal('settingsmodal'); }catch(_o){} }
     return bad.length?bad.join('; '):null; }},
  {v:'24.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
