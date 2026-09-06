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

# v11.78 CHECK, inserted before the v11.77 entry. The writer runs on every
# save, so saveProfile() is the deterministic way to make it look at the state.
SubRx @'
  {v:'11.77',what:'a frag blast reaches further and hits harder: the radius is 190 and the damage at a fixed distance matches the new formula and exceeds the old one (his order of 2026-09-06)',
'@ @'
  {v:'11.78',what:'the credits and XP readout is twice the size on the Undercroft floor, and keeps its compact size and its clearance from the CONDITIONS box in a raid (his note of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__P&&window.__hubEnter)) return 'SKIP: this fixture cannot deploy and read the screen';
     var el=document.getElementById('topright');
     if(!el) return 'SKIP: there is no corner readout in this build';
     var bad=[];
     function px(v){ return parseFloat(v)||0; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ if(G){ G=null; } }catch(_g){}
       __hubEnter();
       saveProfile();   // the writer runs here
       var cs=getComputedStyle(el), r=el.getBoundingClientRect();
       // THE FIX: big on the floor.
       if(!el.classList.contains('hub')) bad.push('on the floor the readout does not carry its floor size (no hub class)');
       if(px(cs.fontSize)<26) bad.push('on the floor the readout type is '+Math.round(px(cs.fontSize))+'px, which is the size he called useless');
       if(r.height<40) bad.push('on the floor the readout is only '+Math.round(r.height)+'px tall');
       // AND STILL COMPACT IN A RAID, clear of the CONDITIONS box.
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       __frame(); __frame();
       saveProfile();
       cs=getComputedStyle(el); r=el.getBoundingClientRect();
       if(el.classList.contains('hub')) bad.push('in a raid the readout still carries its floor size');
       if(r.height>28) bad.push('in a raid the readout is '+Math.round(r.height)+'px tall, too tall for the band above the CONDITIONS box');
       var HB=(typeof HUDBOX!=='undefined')?HUDBOX.cond:null;
       if(HB){
         var cz=1; try{ cz=(HUDZ.cond||1)*hudRes()*hudUserZ('cond'); }catch(_z){ cz=1; }
         if(r.bottom>HB.y*cz+1) bad.push('in a raid the readout reaches '+Math.round(r.bottom)+' while the CONDITIONS box starts at '+Math.round(HB.y*cz));
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'11.77',what:'a frag blast reaches further and hits harder: the radius is 190 and the damage at a fixed distance matches the new formula and exceeds the old one (his order of 2026-09-06)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
