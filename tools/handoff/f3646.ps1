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

if ($s.Contains("  {v:'36.46',what:")) { throw "check 36.46 is in the fixture already" }

SubRx @'
  {v:'36.45',what:
'@ @'
  {v:'36.46',what:'the stash item key row names the tenth hotbar key 0, as the hotbar does (v36.37 gave the hotbar a 9 key and the row printed 10 on its last button, so hovering a Bandage offered 9 one digit keys, not all 10)',
   run:function(){
     if(typeof renderHub!=='function'||typeof ITEMS==='undefined'||!ITEMS.bandage||typeof HOTBAR_N==='undefined'||typeof slotKeyName!=='function') return 'SKIP: no stash key row here';
     var bad=[], prof=null, keep=null, c, a, L, want=[], i;
     try{
       __topClear(); __cleanProfile(); prof=__P();
       keep={s:(prof.stash||[]).slice(),h:JSON.parse(JSON.stringify(prof.hotAssign||{})),t:prof.stashTab};
       prof.stash=['bandage']; prof.hotAssign={}; prof.stashTab='all';
       renderHub();
       c=[].slice.call(document.querySelectorAll('#stashgrid .cell')).filter(function(d){ return String(d.title||'').indexOf(ITEMS.bandage.name+'  x')===0; })[0];
       if(!c) return 'no Bandage cell in the stash';
       c.dispatchEvent(new MouseEvent('mouseenter'));
       a=document.getElementById('stashacts'); if(!a) return 'no key row on the hover';
       L=[].slice.call(a.querySelectorAll('button')).map(function(b){ return String(b.textContent||'').trim(); }).filter(function(t){ return /^\d+$/.test(t); });
       for(i=0;i<HOTBAR_N;i++) want.push(slotKeyName(i));
       if(L.join(',')!==want.join(',')) bad.push('the key row reads '+L.join(',')+', not '+want.join(','));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(prof&&keep){ var q=__P(); q.stash=keep.s; q.hotAssign=keep.h; q.stashTab=keep.t; } }catch(_a){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'36.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
