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

# v11.68 CHECK, inserted before the v11.67 entry. The drop handler is reached
# the way the real mouseup reaches it: the zone's __grabDrop, with the belt
# cell as the source. The stale phrase is assembled so the check never matches
# its own text.
SubRx @'
  {v:'11.67',what:'the in-raid notoriety banner at two or more names what notoriety costs rather than claiming the Peddler has shut his stall, which never shuts',
'@ @'
  {v:'11.68',what:'dropping a tactical belt item on the stash says it went to the stash, and it did: it left the backpack and its belt key',
   run:function(){
     if(!(window.__P&&window.__hubEnter&&window.__station)) return 'SKIP: this fixture cannot walk the Undercroft';
     if(typeof say2!=='function') return 'SKIP: no say2 in this build';
     var zone=document.getElementById('stashgrid');
     if(!zone) return 'SKIP: no stash grid in this document';
     var bad=[], prof, got=[], _s2=say2, stale=['back in the ','backpack'].join('');
     try{
       __topClear(); __cleanProfile(); prof=__P();
       try{ __hubEnter(); __station('stash'); }catch(_h){}
       try{ renderHub(); }catch(_r){}
       if(typeof zone.__grabDrop!=='function') return 'SKIP: the stash grid is not a drop zone here (no __grabDrop), so the drop cannot be driven';
       // A medkit in the backpack, on belt key 1.
       prof.kit=['medkit']; prof.hotAssign={0:'medkit'}; prof.stash=[];
       say2=function(t){ got.push(String(t)); };
       zone.__grabDrop('medkit','plan:0');
       say2=_s2;
       var line=got.join(' | ');
       // CONTROL: the item really left the backpack and its key, or the words are not about this drop.
       if((prof.kit||[]).indexOf('medkit')>=0) bad.push('control: the medkit is still in the backpack after the drop');
       if(prof.hotAssign&&prof.hotAssign[0]!==undefined) bad.push('control: the belt key still holds the medkit after the drop');
       if(!got.length) bad.push('control: the drop said nothing at all');
       // THE FIX: the line names where it went.
       if(line.indexOf(stale)>=0) bad.push('the drop said "'+line+'" while taking the item out of the backpack');
       if(line.indexOf('stash')<0) bad.push('the drop does not say the item went to the stash: "'+line+'"');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ say2=_s2; __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.67',what:'the in-raid notoriety banner at two or more names what notoriety costs rather than claiming the Peddler has shut his stall, which never shuts',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
