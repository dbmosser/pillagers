$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# CAREER RAIDS: THE VAULTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  g.cs={s:0,k:0,streak:null,waveT:0,waveN:0};
  return true;
'@ @'
  try{ arcadeVaults(g); }catch(_cv){}   // v24.xx (careervault): the two DEMO vaults (side stream)
  try{ arcadeKeycards(g); }catch(_ck){}   // v24.xx (careervault): a keycard per vault in a box outside (side stream)
  g.cs={s:0,k:0,streak:null,waveT:0,waveN:0};
  return true;
'@

SubRx @'
  if(!G||!G.arcade||G.sim||G.over||!e||!ITEMS.keycard||!ARCADE.on) return null;
  if((ARCADE.role==='p2'&&!G.netWasJoin)||
'@ @'
  if(!G||!((G.arcade&&ARCADE.on)||G.career)||G.sim||G.over||!e||!ITEMS.keycard) return null;   // v24.xx (careervault): and a CAREER raid
  if((G.arcade&&ARCADE.role==='p2'&&!G.netWasJoin)||
'@

SubRx @'
if(G.arcade&&!G.sim&&(e.byPlayer||e.bySeat>0)){ try{ arcadeKeycardDrop(e); }
'@ @'
if((G.arcade||G.career)&&!G.sim&&(e.byPlayer||e.bySeat>0)){ try{ arcadeKeycardDrop(e); }
'@

SubRx @'
var _vop=(G.arcade&&doorNear.arc)?arcadeVaultPay(doorNear):undefined;
'@ @'
var _vop=((G.arcade||G.career)&&doorNear.arc)?arcadeVaultPay(doorNear):undefined;
'@

SubRx @'
function arcadeVaultPay(R){
  if(!ARCADE.on||!G||!G.arcade||!R) return undefined;
'@ @'
// v24.xx (careervault), HIS RULE (2026-10-12): "GAMEPLAY ELEMENTS LIKE YOU ARE ASKING ABOUT HERE SHOULD BE EXACTLY THE SAME IN DEMO AND
// CAREER". THE VAULTS IN A CAREER RAID. A CAREER raid is built with the same two vaults as the DEMO (two strongrooms sealed behind a
// keycard door, a vault gun in one box, on their own side stream so the seeded raid is unchanged), the same Vault Keycard in an
// ordinary box outside each, and the same keycard drops from the fight (an elite or the boss while a vault is shut, or every 12th
// kill with no keycard left in the world, the host only). Opening a vault pays VAULT OPEN +$500 into the CAREER score of the opener.
function arcadeVaultPay(R){
  if(G&&G.career&&G.cs&&R){
    G.cs.s=(G.cs.s|0)+ARCADE_VAULT_PAY;
    try{ label(R.doorX,R.doorY-30,'+'+arcadeCr(ARCADE_VAULT_PAY),'#ffc04a',0,true); }catch(_cl){}
    return {sub:'+'+arcadeCr(ARCADE_VAULT_PAY)};
  }
  if(!ARCADE.on||!G||!G.arcade||!R) return undefined;
'@

SubRx @'
var VER='25.53';
'@ @'
var VER='25.54';
'@

$pat = "(?m)^  now:'v25\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.54: CAREER raids have the DEMO vaults and keycards, and a vault pays +500 to your score. Check 25.54 fails on v25.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
