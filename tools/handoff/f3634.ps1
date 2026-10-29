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

if ($s.Contains("  {v:'36.34',what:")) { throw "check 36.34 is in the fixture already" }

SubRx @'
  {v:'36.33',what:
'@ @'
  {v:'36.34',what:'run goal cache item names wrap below their label with a 16px value gap, and the score and money totals sit at the same bottom edge',
   run:function(){
     var saved=JSON.stringify(P),g,sc,money,rows,i,label,value,b1,b2,cs,scale;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state(); careerPostBuild(g);
       g.ents=[];g.bag=[];g.cs.s=0;g.cs.b={};g.mercId=null;g.pedCarry=0;P.merc=null;P.racks=0;P.arrays=0;
       g.goalRewards={cash:2500,items:['reactor','ledger','blackbox']};
       __endRaid('extract');haulRevealSkip();
       rows=document.querySelectorAll('#oc_manifest .gri');
       if(rows.length!==3) return 'goal item names are not on separate wrapping sublines';
       for(i=0;i<rows.length;i++){
         label=rows[i].querySelector('.lgl');value=rows[i].querySelector('b');
         if(!label.querySelector('.gritem'))return 'goal item has no name subline';
         cs=getComputedStyle(label.querySelector('.gritem'));
         if(parseFloat(cs.fontSize)<16||cs.whiteSpace==='nowrap')return 'goal name is small or cannot wrap';
         b1=label.getBoundingClientRect();b2=value.getBoundingClientRect();
         scale=rows[i].getBoundingClientRect().width/Math.max(1,rows[i].offsetWidth);
         if(b2.left-b1.right<15.5*scale)return 'goal name/value gap is smaller than 16 layout pixels';
         if(label.scrollWidth>label.clientWidth+1)return 'goal item label overflows';
       }
       sc=document.querySelector('#oc_manifest .sc b');money=document.querySelector('#oc_manifest .tot b');
       if(!sc||!money)return 'totals missing';
       if(Math.abs(sc.getBoundingClientRect().bottom-money.getBoundingClientRect().bottom)>2)return 'score and money totals have different bottom edges';
       return null;
     } finally {
       try{if(g&&!g.over)__endRaid('abandon');}catch(_e){}
       __topClear();P=JSON.parse(saved);saveProfile();
     }
   }},
  {v:'36.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
