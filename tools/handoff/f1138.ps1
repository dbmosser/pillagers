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
  {v:'11.37',what:'a machine hit on a pillager you have won over does not turn him against you or write a grudge (provokeReal 1); a hit you land does; the old hitT reading (provokeReal 0) turns him on the machine hit',
'@ @'
  {v:'11.38',what:'a melee swing next to your own merc does not hurt him; a swing next to a hostile pillager still does',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__loop)) return 'SKIP: this fixture cannot swing a melee';
     var bad=[];
     function swingAt(makeMerc){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, T=null, i;
       for(i=0;i<g.ents.length;i++){ var e=g.ents[i]; if(e.kind==='raider'&&!e.downed&&!e.finished){ T=e; break; } }
       if(!T) return null;
       T.merc=makeMerc?1:0; T.downed=false; T.finished=false; T.hostile=!makeMerc; T.hp=T.maxhp||80;
       p.x=2020; p.y=3300; p.face=0; T.x=p.x+28; T.y=p.y;
       var hp0=T.hp;
       // hold the target in place across the swing frame
       var d=new KeyboardEvent('keydown',{code:'KeyF',key:'f',bubbles:true,cancelable:true}); window.dispatchEvent(d);
       T.x=p.x+28; T.y=p.y;
       __loop(performance.now());
       var u=new KeyboardEvent('keyup',{code:'KeyF',key:'f',bubbles:true}); window.dispatchEvent(u);
       return {hp0:hp0, hp1:T.hp, merc:T.merc, hostile:T.hostile};
     }
     // THE FINDING: your merc takes no melee damage.
     var m=swingAt(true);
     if(!m) return 'SKIP: no pillager to make a merc';
     if(m.hp1<m.hp0) bad.push('a melee swing next to your merc dropped his health from '+Math.round(m.hp0)+' to '+Math.round(m.hp1));
     // CONTROL: a hostile pillager in the same spot DOES take the swing, so the
     // exclusion did not disarm melee.
     var h=swingAt(false);
     if(h){ if(!(h.hp1<h.hp0)) bad.push('control: a melee swing next to a hostile pillager left his health at '+Math.round(h.hp1)+', so the strike no longer lands and the merc result proves nothing'); }
     __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.37',what:'a machine hit on a pillager you have won over does not turn him against you or write a grudge (provokeReal 1); a hit you land does; the old hitT reading (provokeReal 0) turns him on the machine hit',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
