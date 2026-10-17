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

if ($s.Contains("  {v:'28.86',what:")) { throw "check 28.86 is in the fixture already" }

SubRx @'
  {v:'28.85',what:
'@ @'
  {v:'28.86',what:'the corner readout also shows the STASH value and the BAG value, in the Undercroft and in a raid (his order: stash value and bag value always shown in the top right corner, everywhere, with credits and XP)',
   run:function(){
     if(typeof trStash!=='function'||typeof trBag!=='function') return 'the corner readout has no stash or bag value (no trStash, no trBag)';
     var el=document.getElementById('topright'); if(!el) return 'SKIP: no corner readout';
     var bad=[], k=null, kk, t, ev, eb, g, p=__P(), keep=p.stash;
     for(kk in ITEMS){ if(ITEMS[kk]&&ITEMS[kk].val>=10&&ival(kk)>=10){ k=kk; break; } }
     if(!k) return 'SKIP: no valued item';
     function txt(){ _trLast=''; syncTopRight(); return String(el.textContent||'').replace(/\s+/g,' '); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       G=null; keys={}; __showScreen('hub'); __hubEnter();
       p.stash=[k,k,k]; ev=3*ival(k);
       t=txt();
       if(t.indexOf('STASH '+ev.toLocaleString())<0) bad.push('on the floor the readout does not show STASH '+ev.toLocaleString()+' ("'+t+'")');
       if(!/BAG 0\b/.test(t)) bad.push('on the floor the readout does not show BAG 0 ("'+t+'")');
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over) return 'SKIP: no live raid';
       p=__P(); p.stash=[k,k,k]; g.bag.push(k,k); eb=bagValue(); if(!(eb>=20)) return 'SKIP: the bag has no value';
       t=txt();
       if(t.indexOf('BAG '+eb.toLocaleString())<0) bad.push('in a raid the readout does not show BAG '+eb.toLocaleString()+' ("'+t+'")');
       if(t.indexOf('STASH '+ev.toLocaleString())<0) bad.push('in a raid the readout does not show STASH '+ev.toLocaleString()+' ("'+t+'")');
       if(!(topRightBottom()>el.getBoundingClientRect().bottom+8)) bad.push('the lines under the readout are not cleared by topRightBottom');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var g2=__state(); if(g2&&!g2.over) __endRaid('abandon'); }catch(_e){} try{ p.stash=keep; }catch(_k){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'28.85',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
