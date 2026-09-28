$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'17.01',what:")) { throw "check 17.01 is in the fixture already" }

SubRx @'
  {v:'17.00',what:
'@ @'
  {v:'17.01',what:'on one PC a focus change in either window leaves that window backpack open and a controller drag in hand; a mouse drag is still dropped, and a window played alone and the cursor reset still shut the backpack',
   run:function(){
     if(typeof releaseAllKeys!=='function'||typeof NET!=='object'||!NET||!window.__deploy||!window.__endRaid) return 'SKIP: this build has no same machine pair';
     var keep={same:NET.same,pair:NET.pair}, k0=keys, md0=mouse.down, bad=[];
     function blur(){ window.dispatchEvent(new Event('blur')); }
     function focus(){ window.dispatchEvent(new Event('focus')); }
     try{
       __runPrep(); __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over) return 'SKIP: staging: no raid to open a backpack in';
       NET.same='p2'; NET.pair='zqxbag'; keys={};
       G.bagOpen=true; G.drag={pad:1};
       blur();
       if(!G.bagOpen) bad.push('the player 2 window lost focus and its backpack, opened by its controller, shut');
       if(!(G.drag&&G.drag.pad)) bad.push('the player 2 window lost focus and the item its controller was moving was dropped');
       G.bagOpen=true; G.drag=null;
       focus();
       if(!G.bagOpen) bad.push('the player 2 window took focus and its backpack shut');
       G.bagOpen=true; G.drag={};
       blur();
       if(G.drag) bad.push('control: a mouse drag survived a focus change');
       NET.same='host'; G.bagOpen=true; G.drag=null;
       blur();
       if(!G.bagOpen) bad.push('the player 1 window lost focus and its backpack, opened by keys handed over from the player 2 window, shut');
       NET.same=null; G.bagOpen=true; G.drag={pad:1};
       blur();
       if(G.bagOpen||G.drag) bad.push('control: a window played alone kept its backpack open through a focus change');
       NET.same='p2'; G.bagOpen=true; G.drag={pad:1};
       releaseAllKeys();
       if(G.bagOpen||G.drag) bad.push('control: the cursor reset no longer shuts the backpack in the player 2 window');
     } finally {
       NET.same=keep.same; NET.pair=keep.pair; keys=k0||{}; mouse.down=md0;
       try{ if(G){ G.bagOpen=false; G.drag=null; } }catch(e){}
       try{ __endRaid('abandon'); __topClear(); }catch(e){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'17.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
