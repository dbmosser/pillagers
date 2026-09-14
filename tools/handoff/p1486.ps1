$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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
      if(g.bag.indexOf(_hk)<0&&!((g.pouch||{})[_hk]>0)) delete g.hotAssign[_ha];
'@ @'
      if(g.bag.indexOf(_hk)<0&&!((g.pouch||{})[_hk]>0)){ (g.hotPruned=g.hotPruned||{})[_ha]=_hk; delete g.hotAssign[_ha]; }   // v14.86: kept aside for his plan
'@
SubRx @'
          P.hotAssign=JSON.parse(JSON.stringify(_flush)); saveProfile();
'@ @'
          P.hotAssign=JSON.parse(JSON.stringify(hotKeepPruned(_flush))); saveProfile();
'@
SubRx @'
        P.hotAssign=JSON.parse(JSON.stringify(_uf));
'@ @'
        P.hotAssign=JSON.parse(JSON.stringify(hotKeepPruned(_uf)));
'@
SubRx @'
function dropDeadKeys(){
'@ @'
// v14.86, belt audit finding 3: A DRAG ON THE BELT IN A RAID KEEPS THE KEYS FOR WHAT STAYED HOME. The raid's copy of the plan lets
// go of keys on items that did not come up (v13.99), and a drag onto or off a key mid-raid saved that copy over his whole plan,
// so those keys were gone when he got home, against the promise that his Undercroft plan is left as he set it. The keys set
// aside at raid start go back into the saved plan, unless the drag put something on that key or moved that item to another.
function hotKeepPruned(plan){
  var pr=(G&&G.hotPruned)||{};
  for(var s in pr){
    if(plan[s]!==undefined) continue;
    var moved=false; for(var q in plan) if(plan[q]===pr[s]) moved=true;
    if(!moved) plan[s]=pr[s];
  }
  return plan;
}
function dropDeadKeys(){
'@
SubRx @'
var VER='14.85';
'@ @'
var VER='14.86';
'@

$pat = "(?m)^  now:'v14\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v14.86: A DRAG ON THE BELT IN A RAID KEEPS THE KEYS FOR WHAT STAYED HOME. The raid copy of the belt plan drops keys on items that did not come up, and a drag onto or off a key mid-raid saved that copy over the whole plan, so those keys were gone at home. The keys set aside at raid start now go back into the saved plan. Check 14.86 deploys with a key on a Stim left at home and unbinds another key; it fails on v14.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
