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

if ($s.Contains("  {v:'29.26',what:")) { throw "check 29.26 is in the fixture already" }

SubRx @'
  {v:'29.25',what:
'@ @'
  {v:'29.26',what:'the pre-raid pack row puts PACK ALL and CLEAR right after the PACK label, not beside the cash chip',
   run:function(){
     if(typeof syncSectorPack!=='function') return 'SKIP: no pack row';
     var host, b, bs, i, last;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.stash=['bandage','bandage','smoke','core']; P.kit=[]; P.freeKit=0; P.kitPick='mine'; P.intel=0; P.credits=1000; P.takeCash=null;
       renderSector();
       host=document.getElementById('sectorpack');
       if(!host||host.style.display==='none') return 'the pack row is not shown';
       bs=host.querySelectorAll('button');
       if(!bs.length||bs[0].getAttribute('data-pa')!=='all') return 'the first pack button is not the pack all button';
       if(!bs[1]||bs[1].getAttribute('data-pa')!=='none') return 'the second pack button is not the clear button';
       if(!/pack all/i.test(bs[0].textContent)||!/clear/i.test(bs[1].textContent)) return 'the whole-pack buttons are not named pack all and clear ('+bs[0].textContent+', '+bs[1].textContent+')';
       last=bs[bs.length-1];
       if(last.getAttribute('data-pa')) return 'a whole-pack button still ends the row, beside the cash chip';
       bs[0].click();
       if(P.takeCash!==null||packedCount('bandage')!==2) return 'pack all did not pack the bandages';
       host=document.getElementById('sectorpack'); host.querySelector('[data-pa="none"]').click();
       if(P.takeCash!==0||packedCount('bandage')!==0) return 'clear did not empty the pack';
       return null;
     } finally {
       try{ __cleanProfile(); }catch(_e){}
       __topClear();
     } }},
  {v:'29.25',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
