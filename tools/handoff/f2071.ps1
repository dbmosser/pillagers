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

if ($s.Contains("  {v:'20.71',what:")) { throw "check 20.71 is in the fixture already" }

SubRx @'
  {v:'20.70',what:
'@ @'
  {v:'20.71',what:'a restore code takes the replaced character floor crates with it: after the restore and its reload the restored stash gains none of them, and they leave this floor',
   run:function(){
     if(!window.__P||typeof restoreApply!=='function'||typeof floorDropsRestore!=='function'||!ITEMS.medkit||!ITEMS.scrap) return 'SKIP: no restore or floor crates in this build';
     var P2=__P(), snap=JSON.parse(JSON.stringify(P2)), bad=[], hb=(typeof HB==='object'&&HB)?HB:null, hd=hb?hb.drops:null, seat=(typeof NET==='object'&&NET)?NET.seat:0, i, n=0, sc=0, k, ok;
     try{
       __topClear(); __cleanProfile();
       if(hb) hb.drops=[{id:'zqx-h32-a',k:'medkit',x:200,y:200,by:seat},{id:'zqx-h32-b',k:'medkit',x:230,y:200,by:seat}];
       P2.stash=['scrap']; P2.floorDrops=[{id:'zqx-h32-a',k:'medkit'},{id:'zqx-h32-b',k:'medkit'}];
       ok=restoreApply({v:1,n:'ZQXRESTORE32',c:4321,x:10,l:1,s:{scrap:3}});
       if(!ok) return 'SKIP: restoreApply refused the staged code';
       // CONTROL: the code did replace the stash.
       for(i=0;i<P2.stash.length;i++) if(P2.stash[i]==='scrap') sc++;
       if(sc!==3||P2.pname!=='ZQXRESTORE32') return 'SKIP: the staged code did not replace the save (stash '+JSON.stringify(P2.stash)+')';
       if(hb&&(hb.drops||[]).some(function(q){ return q&&(q.id==='zqx-h32-a'||q.id==='zqx-h32-b'); })) bad.push('the replaced character crates still sit on this floor, where they can be taken into the restored stash');
       floorDropsRestore();   // what the boot after the restore reload does
       for(i=0;i<P2.stash.length;i++) if(P2.stash[i]==='medkit') n++;
       if(n) bad.push('after the restore and its reload the restored stash gained '+n+' Medkits the replaced character left on the floor');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ for(k in P2) if(!(k in snap)) delete P2[k]; for(k in snap) P2[k]=snap[k]; saveProfile(); }catch(_r){}
       try{ if(hb) hb.drops=hd; }catch(_h){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.70',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
