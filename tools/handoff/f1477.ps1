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
  {v:'14.76',what:
'@ @'
  {v:'14.77',what:'the ascent question says what goes up when nothing is packed: with one item packed it says one item you packed, and with nothing packed it names how many items go up from the stash (first-hour audit finding 1)',
   run:function(){
     if(typeof askKit!=='function'||typeof standardKit!=='function'||!document.getElementById('asksub')) return 'SKIP: no ascent question in this build';
     var bad=[], prof=null, keep=null;
     function sub(){
       askKit();
       var t=String((document.getElementById('asksub')||{}).textContent||'');
       try{ document.getElementById('askmodal').classList.remove('on'); }catch(_m){}
       return t.split(/The freebie kit/i)[0];
     }
     try{
       __topClear(); __cleanProfile(); prof=__P();
       keep={s:(prof.stash||[]).slice(),k:(prof.kit||[]).slice(),f:prof.freeKit,ks:prof.kitSaved,h:JSON.parse(JSON.stringify(prof.hotAssign||{}))};
       prof.stash=['frag','frag','smoke','bandage','bandage']; prof.hotAssign={}; prof.freeKit=0; prof.kitSaved=null;
       // CONTROL: one Bandage packed reads as one item you packed.
       prof.kit=['bandage'];
       var t1=sub();
       if(!(/\b1 item you packed/).test(t1)) return 'SKIP: with one Bandage packed the question read: '+t1.slice(0,120);
       prof.kit=[];
       var nk=standardKit().length;
       if(nk<1) return 'SKIP: the standard kit picks nothing from this stash';
       var t2=sub();
       if(t2.indexOf(String(nk)+' item')<0||t2.toLowerCase().indexOf('from your stash')<0) bad.push('with nothing packed and '+nk+' items about to be packed from the stash, the question read: '+t2.slice(0,140));
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var q=__P(); if(keep){ q.stash=keep.s; q.kit=keep.k; q.freeKit=keep.f; q.kitSaved=keep.ks; q.hotAssign=keep.h; } }catch(_a){} try{ document.getElementById('askmodal').classList.remove('on'); }catch(_m){} try{ __topClear(); __cleanProfile(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'14.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
