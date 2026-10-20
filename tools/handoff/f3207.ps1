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

if ($s.Contains("  {v:'32.07',what:")) { throw "check 32.07 is in the fixture already" }

SubRx @'
  {v:'32.06',what:
'@ @'
  {v:'32.07',what:'saying yes to easy mode gives a free medkit; saying no gives nothing (his 3.16 b: 30 percent less damage, plus a free medkit)',
   run:function(){
     if(typeof easyAnswer!=='function') return 'no easyAnswer';
     var g=null, rs=say, e0=ARCADE.easy, a0=ARCADE.easyAsk, n0, n1, n2;
     function kits(){ var i, n=0; for(i=0;i<g.bag.length;i++) if(g.bag[i]==='medkit') n++; return n; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||!Array.isArray(g.bag)) return 'SKIP: no raid';
       say=function(){};
       n0=kits();
       ARCADE.easy=0; ARCADE.easyAsk={at:Date.now()}; easyAnswer(false); n1=kits();
       ARCADE.easy=0; ARCADE.easyAsk={at:Date.now()}; easyAnswer(true); n2=kits();
       if(n1!==n0) return 'no gave a medkit ('+n0+' to '+n1+')';
       if(n2!==n0+1) return 'yes did not give exactly one free medkit ('+n0+' to '+n2+')';
       return null;
     } finally {
       say=rs; ARCADE.easy=e0; ARCADE.easyAsk=a0;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
