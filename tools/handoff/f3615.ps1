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

if ($s.Contains("  {v:'36.15',what:")) { throw "check 36.15 is in the fixture already" }

SubRx @'
  {v:'36.14',what:
'@ @'
  {v:'36.15',what:'the breach gate names the local search key: default e, rebound k and the active pad search button; progress keeps its percentage',
   run:function(){
     var g=null, text=hudText, pad=padOn, map, ownMap=false, vx=VX, vy=VY, role=NET.role, seat=NET.seat, on=NET.on, button=PADLABEL.KeyE, brand=PAD.brand, out=[], usePad=false, ss, s, gp, i, got;
     function label(){ out=[]; shDraw(ctx); return out.join(' | ').toLowerCase().replace(/\s+/g,' '); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:['gun_carbine'],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'no raid for breach label check';
       map=P.keymap; ownMap=true; NET.on=false; g.t=4; keys={}; shTick(0);
       ss=shS(); if(!ss.sites||!ss.sites.length) return 'no stronghold for breach label check';
       s=ss.sites[0]; ss.sites=[s]; gp=shGatePt(s);
       g.player.x=gp.x+s.nx*55; g.player.y=gp.y+s.ny*55;
       VX=gp.x-W/(2*ZOOM()); VY=gp.y-H/(2*ZOOM());
       hudText=function(t){ out.push(String(t)); }; padOn=function(){ return usePad; }; PAD.brand='xbox';
       for(i=0;i<2;i++){
         NET.on=true; NET.role=i?'join':'host'; NET.seat=i; s.open=0; s.prog=0; usePad=false;
         P.keymap={}; got=label();
         if(got!=='hold e to breach') return NET.role+' default gate label: '+got;
         P.keymap={KeyE:'KeyK'}; got=label();
         if(got!=='hold k to breach') return NET.role+' rebound gate label: '+got;
         usePad=true; PADLABEL.KeyE='X'; got=label();
         if(got!=='hold x to breach') return NET.role+' pad gate label: '+got;
         PADLABEL.KeyE='Y'; got=label();
         if(got!=='hold y to breach') return NET.role+' rebound pad gate label: '+got;
         s.prog=0.42; got=label();
         if(got!=='breaching 42%') return NET.role+' breach progress label: '+got;
       }
       return null;
     }finally{
       hudText=text; padOn=pad; PADLABEL.KeyE=button; PAD.brand=brand;
       NET.role=role; NET.seat=seat; NET.on=on;
       VX=vx; VY=vy; if(ownMap){ if(map===undefined) delete P.keymap; else P.keymap=map; }
       keys={}; try{ __endRaid('abandon'); }catch(e){} __topClear();
     }
   }},
  {v:'36.14',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
