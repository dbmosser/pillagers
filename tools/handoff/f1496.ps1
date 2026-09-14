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
  {v:'14.95',what:
'@ @'
  {v:'14.96',what:'the gun hover prints its real rate of fire: the gun with the shortest gap between shots reads more rounds per minute than the gun with the longest, and its rate is the gap turned into shots a minute (unit audit finding 1)',
   run:function(){
     if(typeof itemRows!=='function'||typeof WEAPONS==='undefined'||typeof ITEMS==='undefined') return 'SKIP: no gun hover in this build';
     var guns=[];
     for(var k in ITEMS){ var it=ITEMS[k]; if(it&&it.use==='gun'&&it.gk&&WEAPONS[it.gk]&&WEAPONS[it.gk].rof>0) guns.push(k); }
     if(guns.length<2) return 'SKIP: fewer than two gun items';
     guns.sort(function(a,b){ return WEAPONS[ITEMS[a].gk].rof-WEAPONS[ITEMS[b].gk].rof; });
     var fast=guns[0], slow=guns[guns.length-1], gf=WEAPONS[ITEMS[fast].gk], gs=WEAPONS[ITEMS[slow].gk];
     if(!(gf.rof<gs.rof)) return 'SKIP: every gun has the same gap between shots';
     function rate(key){ var R=itemRows(key); for(var i=0;i<R.length;i++) if(R[i][0]==='RATE'){ var m=String(R[i][1]).match(/(\d+) rpm/); return m?+m[1]:-1; } return -1; }
     var rf=rate(fast), rs=rate(slow), bad=[];
     // CONTROL: both hovers print a RATE in rpm.
     if(rf<0||rs<0) return 'SKIP: a gun hover printed no rate in rpm here';
     if(!(rf>rs)) bad.push('the '+ITEMS[fast].name+', '+gf.rof+' ms between shots, reads '+rf+' rpm against '+rs+' rpm for the '+ITEMS[slow].name+' at '+gs.rof+' ms');
     if(rf!==Math.round(60000/gf.rof)) bad.push('the '+ITEMS[fast].name+' reads '+rf+' rpm, not the '+Math.round(60000/gf.rof)+' its '+gf.rof+' ms gap fires');
     return bad.length?bad.join('; '):null; }},
  {v:'14.95',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
