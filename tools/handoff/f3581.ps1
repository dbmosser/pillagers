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

if ($s.Contains("  {v:'35.81',what:")) { throw "check 35.81 is in the fixture already" }

SubRx @'
  {v:'35.80',what:
'@ @'
  {v:'35.81',what:'condition reward screens use readable typography, explicit selection and one SP result hero',
   run:function(){
     var g, tm=document.getElementById('termsmodal'), bad=[];
     try{
       __runPrep();__topClear();__resetCfg();__pinDefaults(0);__cleanProfile();
       P.terms=['known'];renderTerms();
       var bonus=tm.querySelector('.vl'), signed=tm.querySelector('button[aria-pressed="true"]');
       if(!bonus||parseFloat(getComputedStyle(bonus).fontSize)!==20)bad.push('Terms bonuses are not 20px');
       if(!signed||!/signed/i.test(signed.textContent))bad.push('signed condition has no selected state');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});g=__state();g.career=1;g.cs={s:1000,k:4,b:{kill:1000}};g.bag=['core'];g.carriedIn=0;g.player.downed=false;
       __endRaid('extract');
       var lg=document.querySelector('#oc_manifest .lg'), hero=lg&&lg.querySelector('.lgps .sc b'), label=lg&&lg.querySelector('.lgitemlabel');
       if(!hero||parseFloat(getComputedStyle(hero).fontSize)!==56)bad.push('SP total is not the 56px hero');
       if(!label||!label.textContent.length)bad.push('secured tile has no item name');
       if(!lg||lg.querySelectorAll('.lgti').length!==4)bad.push('result does not have four secondary stats');
       var small=lg&&lg.querySelectorAll('.lgti span,.lgeb i,.lgh');
       for(var i=0;small&&i<small.length;i++)if(parseFloat(getComputedStyle(small[i]).fontSize)<16)bad.push('a result label is under 16px');
       return bad.length?bad.join('; '):null;
     }finally{try{if(g&&!g.over){g.player.downed=false;__endRaid('abandon');}}catch(e){}__topClear();__resetCfg();__cleanProfile();}
   }},
  {v:'35.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
