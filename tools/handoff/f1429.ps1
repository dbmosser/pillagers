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

SubRx @'
  {v:'14.28',what:
'@ @'
  {v:'14.29',what:'a reward gun claimed with nothing in hand becomes gun 1: a gun reward claimed with gun 1 on fists and an empty armoury goes into the armoury and into hand, and the next gun reward leaves that gun in hand (progression audit finding 2)',
   run:function(){
     if(typeof claimTier!=='function'||typeof SEASON_TIERS==='undefined'||typeof WEAPONS==='undefined') return 'SKIP: no reward tiers in this build';
     var bad=[], prof, ixs=[];
     for(var i=0;i<SEASON_TIERS.length;i++) if(SEASON_TIERS[i].kind==='wep'&&WEAPONS[SEASON_TIERS[i].v]) ixs.push(i);
     if(!ixs.length) return 'SKIP: no gun rewards';
     var gA=SEASON_TIERS[ixs[0]].v, gB=null, ixB=-1;
     for(var j=1;j<ixs.length;j++) if(SEASON_TIERS[ixs[j]].v!==gA){ gB=SEASON_TIERS[ixs[j]].v; ixB=ixs[j]; break; }
     try{
       __topClear(); __cleanProfile(); prof=__P();
       // THE FIX: every armoury gun lost, gun 1 on fists, and a gun reward claimed.
       prof.weapons=[]; prof.equipped='fists'; prof.spClaimed=[]; prof.xp=1e9;
       claimTier(ixs[0]);
       if(prof.weapons.indexOf(gA)<0) bad.push('control: claiming reward '+ixs[0]+' did not put the '+gA+' in the armoury');
       if(prof.equipped!==gA) bad.push('with gun 1 on fists, the claimed '+gA+' went to the armoury and gun 1 stayed '+prof.equipped+', so the next raid issues a loaner');
       // And a gun already in hand is not replaced by the next gun reward.
       else if(gB){
         claimTier(ixB);
         if(prof.weapons.indexOf(gB)<0) bad.push('control: claiming reward '+ixB+' did not put the '+gB+' in the armoury');
         if(prof.equipped!==gA) bad.push('claiming the '+gB+' took gun 1 away from the '+gA+' already in hand');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
