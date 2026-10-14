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

if ($s.Contains("  {v:'26.43',what:")) { throw "check 26.43 is in the fixture already" }

SubRx @'
  {v:'26.42',what:
'@ @'
  {v:'26.43',what:'gunkeys4, his order: the controls list (F1) says the 1-9 keys are a gun for each kind, set in the stash, and the what is new card leads with the gun keys (every kind of gun has its own key, 1 pistol to 9 energy), shown whole, stamped within 0.15 of the build',
   run:function(){
     if(typeof LEGEND==='undefined'||typeof WHATSNEW==='undefined'||typeof WHATSNEW_VER==='undefined'||typeof VER==='undefined'||typeof wnShort!=='function') return 'SKIP: this build has no controls list or what is new card';
     var bad=[], gear=null, i, row=null, d=parseFloat(VER)-parseFloat(WHATSNEW_VER), s;
     for(i=0;i<LEGEND.length;i++) if(LEGEND[i][0]==='GEAR') gear=LEGEND[i][1];
     if(!gear) return 'SKIP: the controls list has no GEAR heading';
     for(i=0;i<gear.length;i++) if(gear[i][0]==='1-9') row=gear[i];
     if(!row) bad.push('the controls list has no 1-9 row');
     else if(!/kind/.test(row[1])||!/stash/.test(row[1])) bad.push('the 1-9 row says '+JSON.stringify(row[1])+', not a gun for each kind set in the stash');
     if(parseFloat(WHATSNEW_VER)>26.43+0.001) return bad.length?bad.join('; '):'SKIP: the card has moved on, a later card check covers it';
     if(!(d<=0.15+1e-9)) bad.push('the card is stamped v'+WHATSNEW_VER+', '+d.toFixed(2)+' behind v'+VER);
     if(String(WHATSNEW[1]).indexOf('GUN'+' KEYS')!==0) bad.push('the card does not lead with the gun keys');
     else { s=wnShort(WHATSNEW[1]); if(s.slice(-3)==='...') bad.push('the gun keys line is cut on the card'); if(!/pistol/.test(s)||!/energy/.test(s)||!/stash/.test(s)) bad.push('the card line does not name the kinds and the stash ('+s+')'); }
     if(String(WHATSNEW[0]).indexOf('THIS IS AN'+' ALPHA')!==0) bad.push('the card no longer opens with the alpha line');
     return bad.length?bad.join('; '):null; }},
  {v:'26.42',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
