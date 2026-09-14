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
  {v:'14.75',what:
'@ @'
  {v:'14.76',what:'the stash hover row offers every key for every item: hovering a Bandage or a gun item in the stash offers keys 1 to 9 (stash and trader audit finding 4)',
   run:function(){
     if(typeof renderHub!=='function'||typeof ITEMS==='undefined'||!ITEMS.bandage||typeof HOTBAR_N==='undefined'||!document.getElementById('stashgrid')) return 'SKIP: no stash hover row in this build';
     var gun=null; for(var gk in ITEMS) if(ITEMS[gk]&&ITEMS[gk].gk){ gun=gk; break; }
     if(!gun) return 'SKIP: no gun item';
     var bad=[], prof=null, keep=null;
     function hoverKeys(key){
       var nm=ITEMS[key].name+'  x';
       var c=[].slice.call(document.querySelectorAll('#stashgrid .cell')).filter(function(d){ return String(d.title||'').indexOf(nm)===0; })[0];
       if(!c) return -1;
       c.dispatchEvent(new MouseEvent('mouseenter'));
       var a=document.getElementById('stashacts'); if(!a) return -2;
       return [].slice.call(a.querySelectorAll('button')).filter(function(b){ return (/^\d$/).test(b.textContent||''); }).length;
     }
     try{
       __topClear(); __cleanProfile(); prof=__P();
       keep={s:(prof.stash||[]).slice(),h:JSON.parse(JSON.stringify(prof.hotAssign||{})),t:prof.stashTab};
       prof.stash=['bandage',gun]; prof.hotAssign={}; prof.stashTab='all';
       renderHub();
       var nb=hoverKeys('bandage');
       // CONTROL: hovering a Bandage draws the key row.
       if(nb<1) return 'SKIP: hovering a Bandage drew no key buttons here ('+nb+')';
       var ng=hoverKeys(gun);
       if(ng<0) return 'SKIP: the stash drew no '+gun+' stack';
       if(nb!==HOTBAR_N) bad.push('hovering a Bandage offers '+nb+' keys, not all '+HOTBAR_N);
       if(ng!==HOTBAR_N) bad.push('hovering the '+ITEMS[gun].name+' offers '+ng+' keys, not all '+HOTBAR_N);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(prof&&keep){ var q=__P(); q.stash=keep.s; q.hotAssign=keep.h; q.stashTab=keep.t; } }catch(_a){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
