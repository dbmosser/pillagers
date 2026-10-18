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

if ($s.Contains("  {v:'29.92',what:")) { throw "check 29.92 is in the fixture already" }

SubRx @'
  {v:'29.91',what:
'@ @'
  {v:'29.92',what:'the abandoned card title is the plain title colour, not the dim ash that reads as disabled (critic: screen 60)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: cannot deploy here';
     var g=null, t, want, probe, got;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player) return 'SKIP: no live raid';
       var pb=document.getElementById('pausebox'), ab=document.getElementById('abandonbtn'), cb=document.getElementById('confirmabandon');
       if(!pb||!ab||!cb||typeof ab.onclick!=='function'||typeof cb.onclick!=='function') return 'SKIP: no abandon buttons in this build';
       g.t=Math.max(g.t,60); if(g.tel) g.tel.shots=3;   // an instant quit (under 1.5 s, no shot) goes straight back with no card
       togglePauseBox(true); ab.onclick.call(ab); cb.onclick.call(cb);
       t=document.getElementById('oc_title'); if(!t) return 'SKIP: no card title';
       probe=document.createElement('i'); probe.style.color='var(--tx-1)'; document.body.appendChild(probe);
       want=getComputedStyle(probe).color; probe.remove();
       got=getComputedStyle(t).color;
       if(!/abandon/i.test(t.textContent)) return 'SKIP: the card is not the abandon card: "'+t.textContent+'" over='+(g&&g.over);
       return (got===want)?null:('the abandoned title is '+got+', not the title colour '+want);
     } finally {
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     } }},
  {v:'29.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
