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

if ($s.Contains("  {v:'19.04',what:")) { throw "check 19.04 is in the fixture already" }

SubRx @'
  {v:'19.03',what:
'@ @'
  {v:'19.04',what:'the KIA card shows what was lost with pictures: every LOST line on the card carries the item or gun picture',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     var bad=[], man, rows, n=0, withPic=0, i;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['bandage','medkit'],safe:null,mapIx:0,seed:4242});
       __endRaid('dead');
       man=document.getElementById('oc_manifest');
       if(!man) return 'SKIP: no run card manifest';
       rows=String(man.innerHTML).split('<br>');
       for(i=0;i<rows.length;i++) if(rows[i].indexOf('LOST')>=0){ n++; if(rows[i].indexOf('<img')>=0) withPic++; }
       if(!n) return 'SKIP: the card listed nothing lost';
       if(withPic<n) bad.push(withPic+' of '+n+' LOST lines carry a picture');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'19.03',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
