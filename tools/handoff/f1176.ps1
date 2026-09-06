$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.76 CHECK, inserted before the v11.75 entry.
SubRx @'
  {v:'11.75',what:'the craft button is a hold: it fills as you hold it, nothing is spent until it is full, and letting go early spends nothing',
'@ @'
  {v:'11.76',what:'the Scav Pistol costs 1800 in the shop, down from 3600, and is still the cheapest gun on the shelf (his order of 2026-09-06)',
   run:function(){
     if(typeof SHOP==='undefined') return 'SKIP: no shop in this build';
     var bad=[], pistol=null, smg=null;
     for(var i=0;i<SHOP.length;i++){
       if(SHOP[i].kind==='wep'&&SHOP[i].k==='pistol') pistol=SHOP[i];
       if(SHOP[i].kind==='wep'&&SHOP[i].k==='smg') smg=SHOP[i];
     }
     if(!pistol) return 'SKIP: the shop has no Scav Pistol row';
     if(pistol.price!==1800) bad.push('the Scav Pistol costs '+pistol.price+' in the shop and not the 1800 he asked for');
     // CONTROL: it is still the cheapest gun there, so the ladder did not inv    ert.
     for(var j=0;j<SHOP.length;j++){
       var r=SHOP[j];
       if(r.kind==='wep'&&r.k!=='pistol'&&r.price<=pistol.price)
         bad.push('control: '+r.k+' now costs '+r.price+', at or under the pistol, so the pistol is no longer the cheapest gun');
     }
     if(smg&&smg.price!==13200) bad.push('control: the Compact SMG moved to '+smg.price+', so more than the one dial changed');
     return bad.length?bad.join('; '):null; }},
  {v:'11.75',what:'the craft button is a hold: it fills as you hold it, nothing is spent until it is full, and letting go early spends nothing',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
