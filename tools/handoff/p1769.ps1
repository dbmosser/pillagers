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

# THE REMAINING PLAYER PICKS UP THE RAID WHEN THE HOST IS GONE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  G.netLeft=(why==='out')?'HOST LEFT THE RAID. RUN ABANDONED.'
                         :'CONNECTION TO HOST LOST. RUN ABANDONED.';
  NET.status=(why==='out')?'Host left the raid. Run abandoned.'
                          :'Connection to host lost. Run abandoned.';
  try{ endRaid('abandon'); }catch(_eg){}
'@ @'
  // v17.69, HIS RULING 2026-10-02: THE REMAINING PLAYER PICKS UP THE RAID. Before, a host gone (its window closed, the link
  // lost, the party ended, or its raid let go) ended this raid as abandon (his ruling of 2026-09-25, now replaced). This window
  // built the whole surface itself and holds the bodies where the host last placed them, so it runs them from here: the raid
  // stops being shared (upSeed 0, so the frame loop runs updateEnts and the solo loot path), bodies known only from host words
  // (no AI numbers of their own) are let go, THE OVERSEER among them is made again at the health it had, and a search held
  // through the host is dropped. The run card never says abandoned for a host that left.
  var _i, _e, _boss=null, _b;
  NET.upSeed=0; NET.upFp=null; NET.upWord=null; NET.hostSeed=0; NET.srch=null; NET.holds={}; NET.srchOwn=-1;
  if(G.searching){ G.searching=null; G.searchT=0; }
  for(_i=G.ents.length-1;_i>=0;_i--){ _e=G.ents[_i]; if(_e&&_e.net){ if(_e.name===BOSS_NAME) _boss=_e; G.ents.splice(_i,1); } }
  if(_boss){ G.bossDone=0; _b=bossTick(true); if(_b&&_boss.maxhp>0&&_boss.hp>0) _b.hp=Math.max(1,Math.round(_b.maxhp*Math.min(1,_boss.hp/_boss.maxhp))); }
  else if((G.t||0)>=2) G.bossDone=1;
  G.netLeft='';
  NET.status=(why==='out')?'Your host is out of the raid. You are running it now.':'Connection to your host was lost. You are running the raid now.';
  try{ sayWhenFree(NET.status); }catch(_hs){}
'@

SubRx @'
function bossTick(){
'@ @'
function bossTick(force){   // v17.69: force, for a teammate taking the raid over
'@

SubRx @'
  if(typeof NET!=='undefined'&&NET&&NET.on&&NET.role==='join') return null;
'@ @'
  if(!force&&typeof NET!=='undefined'&&NET&&NET.on&&NET.role==='join') return null;
'@

SubRx @'
var VER='17.68';
'@ @'
var VER='17.69';
'@

$pat = "(?m)^  now:'v17\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.69: If your host window is gone mid-raid (closed, crashed or the link lost), you keep the raid and run it yourself instead of being sent down as abandoned. Check 17.69 fails on v17.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
