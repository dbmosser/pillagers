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

if ($s.Contains("  {v:'36.57',what:")) { throw "check 36.57 is in the fixture already" }

SubRx @'
  {v:'36.56',what:
'@ @'
  {v:'36.57',what:'condition bonuses stay on one line, Terms total shares the footer and belt cells are 48px',
   run:function(){
     var bad=[],sm=document.getElementById('sectormodal'),tm=document.getElementById('termsmodal'),oldKitPick=P.kitPick;
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();__hubEnter();
       // v28.xx (cw-cx-condition-ui2): only the own-kit choice creates belt cells; cleanProfile leaves that saved choice alone.
       P.kitPick='mine';P.cond='night';P.wxPick='fog';renderSector();openModal('sectormodal');syncSectorCond();syncSectorWx();
       var em=sm.querySelector('[data-wx="blackout"] em'),cells=sm.querySelectorAll('#sectorplan [data-plan]');
       if(!em||getComputedStyle(em).whiteSpace!=='nowrap')bad.push('blackout bonus can wrap');
       if(cells.length!==HOTBAR_N)bad.push('own-kit belt missing cells: '+cells.length+'/'+HOTBAR_N);
       for(var ci=0;ci<cells.length;ci++){
         var cs=getComputedStyle(cells[ci]);
         // v28.xx (cw-cx-condition-ui2): computed CSS dimensions can round 48px down under the game UI zoom.
         if(!(parseFloat(cs.width)>=47.95&&parseFloat(cs.height)>=47.95))bad.push('belt cell '+ci+' size '+cs.width+' x '+cs.height+' (want 48px, tolerance 0.05px)');
       }
       sm.classList.remove('on');P.terms=['known'];renderTerms();openModal('termsmodal');
       var total=document.getElementById('termstotal'),foot=tm.querySelector('.ui-foot');
       if(!foot||total.parentElement!==foot)bad.push('Terms total is outside the action footer');
       var number=total.querySelector('b');if(!number||parseFloat(getComputedStyle(number).fontSize)!==56)bad.push('Terms total is not the 56px hero');
       return bad.length?bad.join('; '):null;
     }finally{
       sm.classList.remove('on');tm.classList.remove('on');try{var g=__state();if(g&&!g.over&&g.player){g.player.downed=false;__endRaid('abandon');}}catch(e){}
       if(oldKitPick===undefined)delete P.kitPick;else P.kitPick=oldKitPick;
       __topClear();__resetCfg();__cleanProfile();
     }
   }},
  {v:'36.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
