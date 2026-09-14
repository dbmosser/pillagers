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
  {v:'14.86',what:
'@ @'
  {v:'14.87',what:'the Undercroft belt counts what goes up: with three Frags packed and a key on them, the belt drawn in the Undercroft counts three on that key (belt audit finding 4)',
   run:function(){
     if(typeof hubBagState!=='function'||typeof hotbarSlots!=='function'||!window.__applyLoaded||!ITEMS.frag) return 'SKIP: no Undercroft belt in this build';
     var bad=[], snap=null, oldG=G, cell=null;
     try{
       __topClear(); __cleanProfile();
       snap=JSON.parse(JSON.stringify(__P()));
       var q=__P(); q.kit=['frag','frag','frag']; q.hotAssign={6:'frag'};
       G=hubBagState();
       var sl=hotbarSlots(); cell=sl&&sl[6];
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ G=oldG; try{ if(snap) __applyLoaded(snap); }catch(_r){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     if(bad.length) return bad.join('; ');
     // CONTROL: key 7 is his Frag key.
     if(!cell||!cell.assigned||cell.itemKey!=='frag') return 'SKIP: key 7 on the Undercroft belt is not his Frag key here';
     if(cell.count!==3) bad.push('the Undercroft belt draws his Frag key with '+cell.count+' over three packed Frags');
     return bad.length?bad.join('; '):null; }},
  {v:'14.86',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
