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
  {v:'14.47',what:
'@ @'
  {v:'14.48',what:'a floor backpack drag does not survive losing focus: with a drag held in the open Undercroft backpack, releasing all keys drops the drag and leaves the backpack open (floor audit finding 4)',
   run:function(){
     if(typeof showScreen!=='function'||typeof hubBagOpenSet!=='function'||typeof releaseAllKeys!=='function') return 'SKIP: no floor backpack in this build';
     if(typeof G!=='undefined'&&G) return 'SKIP: a raid is live, so the floor backpack cannot be driven';
     var bad=[];
     try{
       __topClear(); __cleanProfile();
       showScreen('hub'); __topClear();
       hubBagOpenSet(true);
       if(!hubBagOpen||!hubBagG) return 'SKIP: the floor backpack did not open';
       hubBagG.drag={key:'medkit'};
       var K=__keysRef(); K['KeyW']=true;
       releaseAllKeys();
       // CONTROL: the keys were let go, so the release ran.
       if(__keysRef()['KeyW']) return 'SKIP: releaseAllKeys did not let go of a held key here';
       if(!hubBagG) bad.push('releasing the keys closed the floor backpack');
       else if(hubBagG.drag) bad.push('losing focus mid-drag left the floor backpack drag held, so the next click binds or removes a belt key and saves it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(hubBagG) hubBagG.drag=null; if(hubBagOpen) hubBagOpenSet(false); }catch(_b){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.47',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
