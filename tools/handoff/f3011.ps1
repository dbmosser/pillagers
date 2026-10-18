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

if ($s.Contains("  {v:'30.11',what:")) { throw "check 30.11 is in the fixture already" }

SubRx @'
  {v:'30.10',what:
'@ @'
  {v:'30.11',what:'the welcome pack has one frame (no border round the list), a left 32px title, 56px buttons and 16px hints (the critic: double frame, centred title, 15px buttons)',
   run:function(){
     var el=null, lb=null, h3=null, bt=null, hn=null, q, bad=[];
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       el=document.getElementById('welcomemodal'); if(!el) return 'SKIP: no welcome pack';
       lb=document.getElementById('welcomelist'); if(!lb) return 'SKIP: no list';
       if(!lb.querySelector('.row')){ for(q=0;q<7;q++) lb.insertAdjacentHTML('beforeend','<div class="row"><canvas class="wpic" width="56" height="56" style="flex:none;margin-right:14px"></canvas><div style="flex:1"><b>Item '+q+'</b><div class="hint">to your stash</div></div></div>'); }
       openModal('welcomemodal'); cardFrameFit(el);
       h3=el.querySelector('h3'); bt=document.getElementById('welcometake'); hn=lb.querySelector('.hint');
       if(parseFloat(getComputedStyle(lb).borderTopWidth)>0) bad.push('the list has its own border inside the card frame');
       if(getComputedStyle(h3).textAlign!=='left'&&getComputedStyle(h3).textAlign!=='start') bad.push('the title is '+getComputedStyle(h3).textAlign+' aligned over left content');
       if(parseFloat(getComputedStyle(h3).fontSize)<31.5) bad.push('the title is '+getComputedStyle(h3).fontSize);
       if(bt&&parseFloat(getComputedStyle(bt).height)<55.5) bad.push('Take the pack is '+getComputedStyle(bt).height+' high');
       if(hn&&parseFloat(getComputedStyle(hn).fontSize)<15.5) bad.push('the hints are '+getComputedStyle(hn).fontSize);
       return bad.length?bad.join('; '):null;
     } finally {
       try{ if(el) el.classList.remove('on'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
