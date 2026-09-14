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
  {v:'14.74',what:
'@ @'
  {v:'14.75',what:'the stash header counts what the ALL tab counts: with two Bandages and two guns the STASH held number matches the ALL tab, guns included (stash and trader audit finding 3)',
   run:function(){
     if(typeof renderHub!=='function'||typeof WEAPONS==='undefined'||!document.getElementById('stashn')) return 'SKIP: no stash header in this build';
     var guns=Object.keys(WEAPONS).filter(function(g){ return g!=='fists'; }).slice(0,2);
     if(guns.length<2) return 'SKIP: fewer than two guns';
     var bad=[], prof=null, keep=null;
     try{
       __topClear(); __cleanProfile(); prof=__P();
       keep={s:(prof.stash||[]).slice(),w:(prof.weapons||[]).slice(),t:prof.stashTab};
       prof.stash=['bandage','bandage']; prof.weapons=guns.slice(); prof.stashTab='all';
       renderHub();
       var allTab=[].slice.call(document.querySelectorAll('.invtab')).filter(function(d){ return (/^\s*ALL\b/i).test(d.textContent||''); })[0];
       var m=allTab?String(allTab.textContent).match(/\d+/):null;
       // CONTROL: the ALL tab counts the two Bandages and the two guns.
       if(!m) return 'SKIP: the stash drew no ALL tab with a count';
       if(+m[0]!==4) return 'SKIP: the ALL tab counted '+m[0]+', not the four held';
       var head=+(document.getElementById('stashn').textContent||'NaN');
       if(head!==+m[0]) bad.push('the STASH header reads '+head+' held above an ALL tab counting '+m[0]);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ if(prof&&keep){ var q=__P(); q.stash=keep.s; q.weapons=keep.w; q.stashTab=keep.t; } }catch(_a){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.74',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
