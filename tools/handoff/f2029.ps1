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

if ($s.Contains("  {v:'20.29',what:")) { throw "check 20.29 is in the fixture already" }

SubRx @'
  {v:'20.28',what:
'@ @'
  {v:'20.29',what:'a key opens the door for the whole party: a door message from the party opens that locked room in this window, its door walls come down, and a repeat changes nothing',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof netDoorTake!=='function') return 'control: there is no door message in this build';
     var bad=[], g, Lk, i, room=null, n0, n1, r;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over) return 'SKIP: no live raid';
       Lk=g.map.locked||[]; for(i=0;i<Lk.length;i++) if(!Lk[i].open){ room=Lk[i]; break; }
       if(!room) return 'SKIP: no locked room on this map';
       n0=g.map.walls.filter(function(w){ return w.door===room.id; }).length;
       if(!n0) return 'SKIP: the room has no door wall';
       r=netDoorTake({state:'in'},{t:'door',sd:g.seed>>>0,id:room.id});
       n1=g.map.walls.filter(function(w){ return w.door===room.id; }).length;
       if(!room.open) bad.push('the room is not marked open ('+r+')');
       if(n1) bad.push(n1+' door walls still stand');
       if(netDoorTake({state:'in'},{t:'door',sd:g.seed>>>0,id:room.id})!=='door') bad.push('a repeat was not taken quietly');
     }catch(ex){ bad.push('threw: '+(ex&&ex.message||ex)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'20.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
