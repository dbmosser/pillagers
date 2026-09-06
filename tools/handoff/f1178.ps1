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

# v11.78 CHECK, inserted before the v11.77 entry. The readout is measured on
# the floor and in a raid from the page's own computed style, and in a raid
# the CONDITIONS box is measured against it in screen pixels.
SubRx @'
  {v:'11.77',what:'a frag blast reaches further and hits harder: the radius is 190 and the damage at a fixed distance matches the new formula and exceeds the old one (his order of 2026-09-06)',
'@ @'
  {v:'11.78',what:'the credits and XP readout in the corner is twice the size everywhere, on the Undercroft floor and in a raid, and the CONDITIONS box starts below it (his notes of 2026-09-06)',
   run:function(){
     if(!(window.__deploy&&window.__frame&&window.__hubEnter&&window.__runPrep)) return 'SKIP: this fixture cannot walk the floor and a raid';
     var el=document.getElementById('topright'); if(!el) return 'SKIP: no corner readout in this build';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[];
     function sz(){ var cs=getComputedStyle(el), r=el.getBoundingClientRect(); return {f:parseFloat(cs.fontSize)||0,h:r.height||0,b:r.bottom||0}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter(); saveProfile();
       var hub=sz();
       if(hub.f<28) bad.push('on the floor the readout is '+hub.f+'px and not 28px or more');
       if(hub.h<40) bad.push('on the floor the readout is '+hub.h.toFixed(0)+'px tall and not 40px or more');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       __frame(0.016); __frame(0.016); saveProfile();
       var raid=sz();
       if(raid.f<28) bad.push('in a raid the readout is '+raid.f+'px and not 28px or more');
       if(raid.h<40) bad.push('in a raid the readout is '+raid.h.toFixed(0)+'px tall and not 40px or more');
       if(!HUDBOX.cond) bad.push('control: the raid drew no CONDITIONS box to measure against');
       else if(HUDBOX.cond.y<raid.b) bad.push('the CONDITIONS box starts at '+HUDBOX.cond.y.toFixed(0)+'px, above the readout bottom at '+raid.b.toFixed(0)+'px, so the two overlap');
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
