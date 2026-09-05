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
  {v:'11.30',what:'a belt key for a gun still in the backpack names the key that equips it, ENTER, and not TAB alone; a belt key for the gun in hand says nothing of the sort',
'@ @'
  {v:'11.31',what:'the stash on a fresh profile draws the one owned gun under ALL and does not say the stash is empty under it; with no guns and nothing stashed it does say so',
   run:function(){
     if(!(window.__hubEnter&&window.__station&&window.__P)) return 'SKIP: this fixture cannot walk the Undercroft';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, so nothing renders';
     var bad=[], prof=__P(), keep={}, k;
     for(k in prof) keep[k]=prof[k];
     function fresh(){ prof.runs=0; prof.ext=0; prof.died=0; prof.credits=600; prof.xp=0; prof.stash=[]; prof.kit=[]; prof.log=[]; prof.contracts=[]; prof.weapons=['pistol']; prof.equipped='pistol'; prof.stashTab='all'; }
     var emptyMsg=['Nothing in ','the stash'].join('');
     try{
       __runPrep(); __resetCfg(); __pinDefaults(0);
       fresh(); __hubEnter(); __station('term');
       var grid=document.getElementById('stashgrid');
       if(!grid) return 'SKIP: no stash grid on the floor';
       var cells=grid.querySelectorAll('.cell').length, empties=Array.prototype.slice.call(grid.querySelectorAll('.cellempty')).map(function(e){return (e.textContent||'').trim();});
       // THE FINDING: one gun cell under ALL, and no "nothing" under it.
       if(cells<1) bad.push('control: the ALL tab drew no cell for the one owned gun');
       for(var i=0;i<empties.length;i++) if(empties[i].indexOf(emptyMsg)>=0) bad.push('the ALL tab still says "'+empties[i]+'" under the gun cell');
       // CONTROL: with no guns and nothing stashed, the message must appear.
       prof.weapons=[]; prof.equipped=null; __hubEnter(); __station('term');
       grid=document.getElementById('stashgrid');
       var empties2=Array.prototype.slice.call(grid.querySelectorAll('.cellempty')).map(function(e){return (e.textContent||'').trim();});
       var said=false; for(i=0;i<empties2.length;i++) if(empties2[i].indexOf(emptyMsg)>=0) said=true;
       if(!said) bad.push('control: with no guns and nothing stashed the ALL tab does not say the stash is empty, so the guard is gone rather than fixed');
       // CONTROL TWO: GUNS with the pistol back still draws the cell and no message.
       prof.weapons=['pistol']; prof.equipped='pistol'; prof.stashTab='gun'; __hubEnter(); __station('term');
       grid=document.getElementById('stashgrid');
       var cells3=grid.querySelectorAll('.cell').length, empties3=grid.querySelectorAll('.cellempty').length;
       if(cells3<1||empties3>0) bad.push('control: the GUNS tab drew '+cells3+' cells and '+empties3+' empty messages with one owned gun');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ for(k in keep) prof[k]=keep[k]; for(k in prof) if(!(k in keep)) delete prof[k]; var sc=document.getElementById('stashscreen')||document.querySelector('.screen.on'); if(window.__topClear) __topClear(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.30',what:'a belt key for a gun still in the backpack names the key that equips it, ENTER, and not TAB alone; a belt key for the gun in hand says nothing of the sort',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
