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

if ($s.Contains("  {v:'36.06',what:")) { throw "check 36.06 is in the fixture already" }

SubRx @'
  {v:'36.05',what:
'@ @'
  {v:'36.06',what:'the pre-raid pack reserves visible scrolling rows above the belt, with readable unaffordable prices and a dash for unsold items',
   run:function(){
     var snap=null,bad=[],sm=document.getElementById('sectormodal'),q,list,b,sp;
     function shut(){var ms=document.querySelectorAll('.modal.on');for(var j=0;j<ms.length;j++)ms[j].classList.remove('on');}
     try{
       snap=JSON.parse(JSON.stringify(__P()));
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       q=__P();q.freeKit=0;q.kitPick='mine';q.stash=['medkit','bandage','smoke','frag','plate','gun_carbine','gun_smg'];q.kit=[];q.equipped='fists';q.credits=0;
       __hubEnter();shut();renderSector();openModal('sectormodal');
       var zoom=parseFloat(sm.style.zoom)||1,pad=parseFloat(getComputedStyle(sm).paddingLeft)*zoom;
       if(Math.abs(pad-(innerWidth*0.05+22*zoom))>2)bad.push('pre-raid card margin grows twice under zoom');
       list=sm.querySelector('#sectorpack .srplist');
       if(!list||list.clientHeight<119)bad.push('pack rows have less than 120 px of scrolling space');
       b=sm.querySelector('#sectorpack .srbuy.dis');
       if(!b||+getComputedStyle(b).opacity<0.99)bad.push('unaffordable price is dimmed');
       if(b){var probe=document.createElement('span');probe.style.color='var(--tx-1)';sm.appendChild(probe);var expected=getComputedStyle(probe).color;probe.remove();if(getComputedStyle(b).color!==expected)bad.push('price does not use readable primary text');}
       sp=sm.querySelector('#sectorpack [data-pk="gun_carbine"] .srbuy.sp');
       if(!sp||getComputedStyle(sp,'::after').content.replace(/["']/g,'')!=='-')bad.push('unsold item has no dash');
       return bad.length?bad.join('; '):null;
     }finally{try{shut();if(snap)__applyLoaded(snap);}catch(e){}__topClear();}
   }},
  {v:'36.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
