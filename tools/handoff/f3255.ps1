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

if ($s.Contains("  {v:'32.55',what:")) { throw "check 32.55 is in the fixture already" }

SubRx @'
  {v:'32.54',what:
'@ @'
  {v:'32.55',what:'pad action legend uses real 20px text, 40px rows, preset counts and complete 48px rebind rows',
   run:function(){
     var saved=P, oldSave=saveProfile, oldPad=KEYS.pad, km, bad=[], i;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P=JSON.parse(JSON.stringify(P));saveProfile=function(){};keysOpen(true);km=document.getElementById('keysmodal');
       var legend=km.querySelector('.padlegend');
       if(!legend) return 'no unscaled HTML action legend';
       for(i=0;i<6;i++){
         padPresetApply(i);padListFit();
         if(km.querySelector('.padlayoutcount').textContent!==(i+1)+' / 6') bad.push('preset count '+i);
         var rows=km.querySelectorAll('.padlegendrow');
         if(rows.length!==16) bad.push('legend count');
         for(var j=0;j<16;j++){
           var r=km.querySelector('[data-pad-button="'+j+'"]');
           if(!r||r.children[0].textContent!==PAD_BTN[j].toLowerCase()||r.children[1].textContent!==padPictureLabel(j)) bad.push('legend assignment '+j);
           if(r&&(parseFloat(getComputedStyle(r).fontSize)<20||r.offsetHeight<40)) bad.push('small action legend '+j);
         }
       }
       var sc=km.querySelector('.padactions');
       if(sc.clientHeight<48||sc.clientHeight%48) bad.push('partial scrolling row');
       var actions=sc.querySelectorAll('.row,.keysec');
       for(i=0;i<actions.length;i++) if(actions[i].offsetHeight!==48) bad.push('dense row '+i);
       var listStyle=getComputedStyle(document.getElementById('keyslist'));
       if(parseFloat(listStyle.paddingBottom)!==0||listStyle.maskImage!=='none') bad.push('inherited bottom gap or mask');
       return bad.length?bad.join('; '):null;
     }finally{
       if(km) km.classList.remove('on');PAD.focus=null;PAD.focusMd=null;KEYS.pad=oldPad;
       try{__endRaid('abandon');}catch(e){} __topClear();P=saved;saveProfile=oldSave;
     }
   }},
  {v:'32.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
