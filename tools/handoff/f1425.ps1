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
  {v:'14.24',what:
'@ @'
  {v:'14.25',what:'one item, one key in the Undercroft backpack: a Medkit dragged onto belt key 5 while key 4 holds Medkit leaves it on key 5 alone, and key 4 dragged onto a key 5 holding another item swaps that item back onto key 4 (Undercroft audit finding 4)',
   run:function(){
     if(typeof hubBagOpenSet!=='function'||typeof withHubBag!=='function'||typeof mouse==='undefined') return 'SKIP: no Undercroft backpack in this build';
     var bad=[], prof, other=null;
     for(var k in ITEMS){ if(k!=='medkit'&&k.indexOf('gun_')!==0){ other=k; break; } }
     if(!ITEMS.medkit||!other) return 'SKIP: no Medkit and second item to drag';
     var show=function(o){ return JSON.stringify(o||{}); };
     try{
       __topClear(); __cleanProfile(); prof=__P();
       try{ __hubEnter(); }catch(_h){}
       if(state!=='hub') return 'SKIP: the fixture is not on the Undercroft floor (state '+state+')';
       hubBagOpenSet(true);
       if(!hubBagOpen||!hubBagG) return 'SKIP: the Undercroft backpack did not open';
       var B=hubBagG;
       // Two belt cells where the backpack draws keys 4 and 5, and the release over key 5.
       var stage=function(assign,drag){
         B.bag=['medkit','medkit',other]; B.hotAssign=assign;
         B.hotCells=[{i:3,x:100,y:900,w:40,h:40},{i:4,x:150,y:900,w:40,h:40}];
         B.drag=drag; mouse.x=170; mouse.y=920;
         window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true,cancelable:true}));
       };
       // ARM 1: key 4 holds Medkit; the other Medkit from the backpack goes onto key 5.
       stage({3:'medkit'},{key:'medkit'});
       if(B.drag) return 'SKIP: the release did not reach the Undercroft backpack drop';
       if(B.hotAssign[4]!=='medkit') bad.push('control: the drop did not put Medkit on key 5 ('+show(B.hotAssign)+')');
       if(B.hotAssign[3]==='medkit') bad.push('Medkit dragged onto key 5 stayed on key 4 as well ('+show(B.hotAssign)+')');
       // ARM 2: key 4 holds Medkit and key 5 the other item; key 4 is dragged onto key 5.
       stage({3:'medkit',4:other},{key:'medkit',fromHot:3});
       if(B.hotAssign[4]!=='medkit') bad.push('control: dragging key 4 onto key 5 did not put Medkit on key 5 ('+show(B.hotAssign)+')');
       if(B.hotAssign[3]!==other) bad.push('dragging key 4 onto key 5 did not swap '+other+' back onto key 4 ('+show(B.hotAssign)+')');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(hubBagG) hubBagG.drag=null; hubBagOpenSet(false); }catch(_c0){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
