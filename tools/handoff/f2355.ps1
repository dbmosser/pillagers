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

if ($s.Contains("  {v:'23.55',what:")) { throw "check 23.55 is in the fixture already" }

SubRx @'
  {v:'23.54',what:
'@ @'
  {v:'23.55',what:'his order: in the arcade a box is looted by holding E, never by walking over it, at the usual speed, and the controls card has a LOOT row',
   run:function(){
     var bad=[], g, p, ct=null, offs=[[20,0],[-20,0],[0,20],[0,-20]], i, f, t0, rows;
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'SKIP: no arcade in this build';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); p=g.player;
       if(typeof arcadeShieldOff==='function') arcadeShieldOff();
       ARCADE.holdT=0; keys={};
       for(i=0;i<offs.length&&!ct;i++) if(losClear(p.x,p.y,p.x+offs[i][0],p.y+offs[i][1],g.vseg)) ct=mkContainer(p.x+offs[i][0],p.y+offs[i][1],'crate');
       if(!ct) return 'SKIP: no clear spot 20 units from the arcade drop';
       ct.loot=['scrap','bandage']; ct.best=bestRarity(ct.loot); ct.pulled=0; ct.prog=0; ct.opened=false;
       g.containers.push(ct);
       t0=performance.now();
       for(f=0;f<120;f++){ ARCADE.ownAt=Date.now(); __loop(t0+f*16.7); }
       if(ct.opened||(+ct.prog||0)>0) bad.push('a crate in reach was searched with no key held (prog '+(+ct.prog||0).toFixed(3)+')');
       keys={KeyE:true};
       for(f=0;f<900&&!ct.opened;f++){ ARCADE.ownAt=Date.now(); __loop(t0+(120+f)*16.7); }
       keys={};
       if(!ct.opened) bad.push('holding E did not loot the crate');
       if(ARCADE_SRCH!==1) bad.push('the arcade search speed is x'+ARCADE_SRCH+', not the usual');
       rows=arcadeCardRows();
       if(!rows.some(function(r){ return r[0]==='LOOT'&&r[1].indexOf('HOLD ')===0&&r[2].indexOf('HOLD ')===0; })) bad.push('the controls card has no LOOT row');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{ keys={}; try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){} try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){} __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'23.54',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
