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

# v11.58 CHECK, inserted before the v11.57 entry. The fancy name is built from
# code points so this file stays ASCII.
SubRx @'
  {v:'11.57',what:'the restore code carries the armoury (guns owned, the one in hand, the second slot, the wear on each) and applying it brings them back; a gun this build does not know is dropped',
'@ @'
  {v:'11.58',what:'a name with a character above U+00FF (a curly quote, an emoji) still gets a restore code and the code reads back the same name; a plain code written before this build still reads',
   run:function(){
     if(!window.__P) return 'SKIP: this fixture cannot reach the profile';
     if(typeof restoreCode!=='function'||typeof restoreRead!=='function') return 'SKIP: this build has no restore code';
     var bad=[], prof=__P(), keepN=prof.pname;
     try{
       var fancy='ZQX'+String.fromCharCode(0x2019)+'S '+String.fromCharCode(0xD83D,0xDD25);
       prof.pname=fancy;
       var code=restoreCode();
       if(!code) bad.push('a name with a curly quote and an emoji produced no restore code at all, so the friend it belongs to cannot be restored');
       else {
         var o=restoreRead(code);
         if(!o) bad.push('the code for that name cannot be read back');
         else if(o.n!==fancy) bad.push('the name came back as '+JSON.stringify(o.n)+' and not '+JSON.stringify(fancy));
       }
       // CONTROL: a code written the old way, plain btoa of ASCII JSON, still reads.
       var old='PIL1'+btoa(JSON.stringify({v:1,n:'OLDCODE',c:4471,x:1})).replace(/=+$/,'');
       var o2=restoreRead(old);
       if(!o2||o2.n!=='OLDCODE'||o2.c!==4471) bad.push('control: a code written before this build no longer reads ('+(o2?JSON.stringify(o2.n):'null')+')');
       // CONTROL: the plain-ASCII case is unchanged.
       prof.pname='PLAINNAME';
       var o3=restoreRead(restoreCode());
       if(!o3||o3.n!=='PLAINNAME') bad.push('control: a plain name no longer round-trips ('+(o3?JSON.stringify(o3.n):'null')+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ prof.pname=keepN; try{ saveProfile(); }catch(_s){} }
     return bad.length?bad.join('; '):null; }},
  {v:'11.57',what:'the restore code carries the armoury (guns owned, the one in hand, the second slot, the wear on each) and applying it brings them back; a gun this build does not know is dropped',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
