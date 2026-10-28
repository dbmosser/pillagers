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

if ($s.Contains("  {v:'36.11',what:")) { throw "check 36.11 is in the fixture already" }

SubRx @'
  {v:'36.10',what:
'@ @'
  {v:'36.11',what:'the rack refusal is a short answer; costs remain on the mainframe instead of being repeated in the toast',
   run:function(){
     var realSay=say, said=[], bad=[], g;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||!g.player||g.over) return 'staging: no live raid';
       P.racks=0; P.freeKit=0; P.kitSaved=null; P.stash=[]; P.kit=[];
       say=function(m){said.push(String(m));};
       buildRack();
       if(said.length!==1||said[0]!=='not enough parts') bad.push('rack refusal still repeats costs: '+said.join(' | '));
       if(P.racks!==0) bad.push('an unaffordable rack was built');
       renderMainframe();
       var hint=document.getElementById('mfhint');
       if(!hint||hint.textContent.toLowerCase().indexOf(rackCostLine().toLowerCase())<0) bad.push('mainframe cost row lost the required parts');
     }catch(e){bad.push('threw: '+(e&&e.message||e));}
     finally{say=realSay; try{__endRaid('abandon');}catch(e){} __topClear(); __cleanProfile();}
     return bad.length?bad.join('; '):null;
   }},
  {v:'36.10',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
