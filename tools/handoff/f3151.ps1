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

if ($s.Contains("  {v:'31.51',what:")) { throw "check 31.51 is in the fixture already" }

SubRx @'
  {v:'31.50',what:
'@ @'
  {v:'31.51',what:'a new codex gun is one feed line at the bottom left, not also a second callout top centre (the critic: it showed twice)',
   run:function(){
     var g=null, rs=say, said=[], i, n, found=false, p;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no raid';
       if(state!=='raid') return 'not in a raid after deploy';
       say=function(m){ said.push(String(m)); };
       P.codex={};
       n=codexScan();
       if(!n) return 'the scan found no new gun to note';
       if(said.indexOf('CODEX ENTRY')>=0) return 'a new codex gun still says CODEX ENTRY through the top lane as well as the feed';
       p=feedS().lines;
       for(i=0;i<p.length;i++) if(String(p[i].txt).indexOf('CODEX ENTRY')===0) found=true;
       if(!found) return 'a new codex gun is not in the feed at all';
       return null;
     } finally {
       say=rs;
       try{ __endRaid('abandon'); }catch(_e){}
       __topClear();
     } }},
  {v:'31.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
