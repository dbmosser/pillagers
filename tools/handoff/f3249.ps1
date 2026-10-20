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

if ($s.Contains("  {v:'32.49',what:")) { throw "check 32.49 is in the fixture already" }

SubRx @'
  {v:'32.48',what:
'@ @'
  {v:'32.49',what:'pad controls match their legend, 20px keycaps, complete list rows and lefty labels',
   run:function(){
     var saved=P, oldSave=saveProfile, oldPad=KEYS.pad, km, bad=[], i, j;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P=JSON.parse(JSON.stringify(P)); saveProfile=function(){};
       keysOpen(true); km=document.getElementById('keysmodal'); padListFit();
       for(j=0;j<3;j++){
         padPresetApply([0,1,5][j]); padListFit();
         for(i=0;i<16;i++){
           var node=km.querySelector('[data-pad-node="'+i+'"]'), label=km.querySelector('[data-pad-button="'+i+'"]');
           if(!node||node.textContent!==PAD_BTN[i].toLowerCase()) bad.push('unnamed controller node '+i);
           if(!label||label.textContent.indexOf(padPictureLabel(i))<0) bad.push('wrong legend '+i);
         }
         if(km.querySelector('[data-pad-stick="left"]').textContent!==([0,1,5][j]===5?'aim':'move')) bad.push('stick label');
       }
       var sc=km.querySelector('.padactions'), rows=sc.querySelectorAll('.row,.keysec'), cap=sc.querySelector('.keybtn');
       if(sc.clientHeight<56||sc.clientHeight%56!==0) bad.push('viewport cuts a row');
       for(i=0;i<rows.length;i++) if(rows[i].offsetHeight!==56) bad.push('row pitch '+i);
       if(parseFloat(getComputedStyle(cap).fontSize)<20) bad.push('keycap under 20px');
       if(parseFloat(getComputedStyle(sc.querySelector('.keysec')).fontSize)<16) bad.push('section under 16px');
       padSetFocus(cap);
       if(getComputedStyle(cap.parentNode).boxShadow==='none') bad.push('focused row has no marker');
       return bad.length?bad.join('; '):null;
     }finally{
       if(km) km.classList.remove('on'); PAD.focus=null; PAD.focusMd=null; KEYS.pad=oldPad;
       try{__endRaid('abandon');}catch(e){} __topClear(); P=saved; saveProfile=oldSave;
     }
   }},
  {v:'32.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
