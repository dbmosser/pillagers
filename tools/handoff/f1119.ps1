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
  {v:'11.18',what:'no interior wall ends inside a doorway, so every front door opens onto floor a body can stand on',
'@ @'
  {v:'11.19',what:'the seven building rules since v11.12 ship switched on, and switching all seven off builds a different world for the same seed, so the paired measurement has two real arms',
   run:function(){
     if(!(window.__deploy&&window.__state)) return 'SKIP: this fixture cannot build a map';
     var bad=[];
     // THE DEFAULTS, by name. A rule that ships off is a rule nobody gets.
     __runPrep(); __resetCfg(); __pinDefaults(0);
     var C=__cfg(), want={winWalk:1,furnDoor:1,navBody:15,doorClear:1,furnIDoor:1,furnGap:1,partDoor:1}, k;
     for(k in want) if(C[k]!==want[k]) bad.push('the '+k+' rule ships as '+C[k]+' rather than '+want[k]);
     // THE TWO ARMS. Every rule off must build a world that differs in its walls
     // and its route grid, and agrees in its entities and containers, which is
     // what makes a paired seed a fair comparison.
     function arm(off){
       __runPrep(); __resetCfg(); __pinDefaults(0);
       if(off) __cfg({winWalk:0,furnDoor:0,navBody:0,doorClear:0,furnIDoor:0,furnGap:0,partDoor:0});
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(),W=g.map.walls,furn=0,i; for(i=0;i<W.length;i++) if(W[i].furn) furn++;
       var blk=0; if(g.map.navD&&g.map.navD.blk){ var b=g.map.navD.blk; for(i=0;i<b.length;i++) if(b[i]) blk++; }
       return {walls:W.length,furn:furn,blocked:blk,ents:g.ents.length,cont:(g.containers||[]).length,wsegs:g.map.wsegs?g.map.wsegs.length:0};
     }
     var on=arm(false), off=arm(true);
     if(on.walls===off.walls&&on.furn===off.furn) bad.push('control: the seven rules off build the same walls and furniture as the rules on, '+on.walls+' and '+on.furn+', so the old arm is not the old world');
     if(on.blocked===off.blocked) bad.push('control: the route grid blocks '+on.blocked+' cells with the rules on and off alike, so the body sized grid is not in the old arm');
     if(on.ents!==off.ents||on.cont!==off.cont) bad.push('the two arms differ in entities or containers, '+off.ents+'/'+off.cont+' against '+on.ents+'/'+on.cont+', so a paired seed is not the same raid on two rule sets');
     // MEASURED: 85 entities and 165 containers on COLD STORAGE at seed 4242.
     if(on.ents!==85||on.cont!==165) bad.push('COLD STORAGE at seed 4242 holds '+on.ents+' entities and '+on.cont+' containers rather than 85 and 165');
     return bad.length?bad.join('; '):null; }},
  {v:'11.18',what:'no interior wall ends inside a doorway, so every front door opens onto floor a body can stand on',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
