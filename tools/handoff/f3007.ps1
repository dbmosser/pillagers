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

if ($s.Contains("  {v:'30.07',what:")) { throw "check 30.07 is in the fixture already" }

SubRx @'
  {v:'30.06',what:
'@ @'
  {v:'30.07',what:'the welcome pack intro, list and footer all sit inside the card frame (the critic: the intro was struck through by the card edge, the footer floated outside)',
   run:function(){
     var el=null, ms=null, ft=null, w=0, h=0, r=null, cy=0, cb=0, ct=0;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       el=document.getElementById('welcomemodal'); if(!el) return 'SKIP: no welcome pack';
       try{ P.welcomed=0; if(typeof maybeWelcome==='function') maybeWelcome(); }catch(_m){}
       var lb=document.getElementById('welcomelist'), q; if(lb&&!lb.querySelector('.row')){ for(q=0;q<7;q++) lb.insertAdjacentHTML('beforeend','<div class="row"><canvas class="wpic" width="56" height="56" style="flex:none;margin-right:14px"></canvas><div style="flex:1"><b>Item '+q+'</b><div class="hint">to your stash</div></div></div>'); }
       openModal('welcomemodal'); cardFrameFit(el);
       ms=el.querySelector('.msub'); ft=el.querySelector('.ui-foot')||el.querySelector('#welcometake');
       h=parseFloat(getComputedStyle(el,'::before').height)||0; r=el.getBoundingClientRect(); cy=r.top+r.height/2; ct=cy-h/2; cb=cy+h/2;
       if(ms&&ms.getBoundingClientRect().width>881) return 'the welcome pack intro is '+Math.round(ms.getBoundingClientRect().width)+'px wide in a 960px card';
       if(ms&&ms.getBoundingClientRect().top<ct-1) return 'the welcome pack intro starts at '+Math.round(ms.getBoundingClientRect().top)+' above the card top '+Math.round(ct);
       if(ft&&ft.getBoundingClientRect().bottom>cb+1) return 'the welcome pack footer ends at '+Math.round(ft.getBoundingClientRect().bottom)+' below the card bottom '+Math.round(cb);
       return null;
     } finally {
       try{ if(el) el.classList.remove('on'); }catch(_e){}
       __topClear();
     } }},
  {v:'30.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
