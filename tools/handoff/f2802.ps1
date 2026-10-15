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

if ($s.Contains("  {v:'28.02',what:")) { throw "check 28.02 is in the fixture already" }

SubRx @'
  {v:'28.01',what:
'@ @'
  {v:'28.02',what:'his 2026-10-14 note (UI cleanup uic4): the answer line stays off the buttons: on the map select screen it does not cover ASCEND TO THIS SECTOR (it sat on it), and on the bare Undercroft floor it rides above the tactical belt (38 px up, on the belt cells)',
   run:function(){
     var t=document.getElementById('hubtoast'), sm=document.getElementById('sectormodal'), go=document.getElementById('sectordeploy');
     if(!t||!sm||!go) return 'SKIP: no answer line or map select screen in this build';
     if(typeof hubToast!=='function'||typeof renderSector!=='function'||typeof openModal!=='function'||!window.__showScreen||!window.__hubEnter) return 'SKIP: this fixture cannot open the map select screen';
     var bad=[], was=sm.classList.contains('on');
     function hit(a,b){ return a.left<b.right&&a.right>b.left&&a.top<b.bottom&&a.bottom>b.top; }
     try{
       __topClear(); __showScreen('hub'); __hubEnter();
       try{ renderSector(); openModal('sectormodal'); }catch(_o){ return 'SKIP: the map select screen did not open here ('+_o+')'; }
       if(!sm.classList.contains('on')||!go.getClientRects().length) return 'SKIP: the map select screen is not on screen here';
       hubToast('QZX TEST LINE');
       var tr=t.getBoundingClientRect(), gr=go.getBoundingClientRect();
       if(hit(tr,gr)) bad.push('the answer line ('+Math.round(tr.left)+','+Math.round(tr.top)+' to '+Math.round(tr.right)+','+Math.round(tr.bottom)+') sits on ASCEND TO THIS SECTOR ('+Math.round(gr.left)+','+Math.round(gr.top)+' to '+Math.round(gr.right)+','+Math.round(gr.bottom)+')');
       __topClear(); __showScreen('hub'); __hubEnter();
       hubToast('QZX TEST LINE');
       var bz=parseFloat(getComputedStyle(t).bottom)||0, z=parseFloat(t.style.zoom)||1;
       if(bz*z<120) bad.push('on the bare floor the answer line is '+Math.round(bz*z)+' px up, on the belt cells (the belt is about 100 px tall)');
       return bad.length?bad.join('; '):null;
     } finally { try{ __topClear(); }catch(_c){} if(!was) sm.classList.remove('on'); t.classList.remove('on'); } }},
  {v:'28.01',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
