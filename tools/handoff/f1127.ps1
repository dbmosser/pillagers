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
  {v:'11.26',what:'the pause screen key line prints no literal entity and names the keys the way the H list does: F strikes, TAB is the backpack, 1 to 9 is the tactical belt',
'@ @'
  {v:'11.27',what:'F is one thing: a press while hurt with a Bandage in the backpack swings the strike and keeps the Bandage; the belt still spends it; down, F still revives',
   run:function(){
     if(!(window.__deploy&&window.__loop&&window.__state)) return 'SKIP: this fixture cannot press keys in a raid';
     var bad=[];
     function press(code, key){ var d=new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true}); window.dispatchEvent(d); document.dispatchEvent(d); }
     function release(code, key){ var u=new KeyboardEvent('keyup',{code:code,key:key,bubbles:true,cancelable:true}); window.dispatchEvent(u); document.dispatchEvent(u); }
     function frames(n){ var t0=performance.now(); for(var i=0;i<n;i++) __loop(t0+i*16.7); }
     // THE FINDING. Hurt, one Bandage in the backpack, nothing on the belt, press F.
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player;
     p.hp=50; g.bag=['bandage']; g.hotAssign={}; p.healLock=false; p.healQ=0;
     var melee0=(g.tel&&g.tel.melee)||0;
     press('KeyF','f'); frames(6); release('KeyF','f'); frames(2);
     var melee1=(g.tel&&g.tel.melee)||0;
     if(!(melee1>melee0)) bad.push('F did not swing: melee count '+melee0+' to '+melee1);
     if(g.bag.length!==1||g.bag[0]!=='bandage') bad.push('F spent the Bandage as well as swinging: backpack is now ['+g.bag.join(',')+']');
     if(p.healQ>0) bad.push('F started a heal (healQ '+p.healQ+') on a punch');
     // CONTROL ONE: the belt still spends it. Put the Bandage on key 5, select it, use it.
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     g=__state(); p=g.player;
     p.hp=50; g.bag=['bandage']; g.hotAssign={4:'bandage'}; p.healLock=false; p.healQ=0;
     g.hot=4; frames(1);
     press('KeyG','g'); frames(6); release('KeyG','g'); frames(2);
     if(g.bag.length!==0&&!(p.healQ>0)) bad.push('control: using the belt slot spent nothing and started no heal, so the belt path is broken and the finding above proves nothing');
     // CONTROL TWO: down, F still revives (the other F, a different state).
     {
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; p.hp=0; p.downed=true; p.downT=17; p.revived=false; p.healLock=false; frames(2);
       if(!p.downed) bad.push('control: the raid would not keep him down');
       else { press('KeyF','f'); frames(6); release('KeyF','f'); frames(2);
         if(p.downed||!p.revived) bad.push('control: down, F no longer revives (downed '+p.downed+', revived '+p.revived+')'); }
     }
     __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.26',what:'the pause screen key line prints no literal entity and names the keys the way the H list does: F strikes, TAB is the backpack, 1 to 9 is the tactical belt',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
