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
  {v:'15.96',what:
'@ @'
  {v:'15.97',what:'your rival is always a pillager, never the imported friend: with a pillager at two kills on the ledger and the imported friend record at three, the rival on paper is that pillager and a body built for him carries the rival mark, and with only the friend record on the ledger nobody is the rival, while a pillager at two kills alone is still the rival on paper and in the body built for him (ghost audit finding)',
   run:function(){
     if(!window.__P||typeof myRival!=='function'||typeof IDENTITIES==='undefined'||!IDENTITIES.length) return 'SKIP: no rivals ledger in this build';
     if(typeof mkRaider!=='function'||typeof idRec!=='function') return 'SKIP: no pillager builder in this build';
     var bad=[], P2=__P(), keep=JSON.stringify(P2.rivals||{}), rngWas=(typeof RNGS!=='undefined')?RNGS:null;
     var real=IDENTITIES[0], rid=real.id, GK='ghost_ZQXFRIEND';   // the key applyGhost gives the friend, with a tag no report carries
     function realRec(){ return {kills:2,deaths:0,met:2,standing:-3}; }
     function ghostRec(){ return {kills:3,deaths:0,met:3,standing:-3}; }
     try{
       // CONTROL: two kills on a pillager make him the rival on paper, and a body built for him wears the mark, on either build.
       P2.rivals={}; P2.rivals[rid]=realRec();
       if(myRival()!==rid) return 'SKIP: two kills did not make a rival on paper in this build ('+myRival()+'), so nothing here can be measured';
       var c=mkRaider(100,100,real,false);
       if(!c||c.rival!==1) return 'SKIP: a body built for the pillager with two kills on the ledger did not carry the rival mark here, so the world path cannot be read';
       // ARM A: the friend record ahead of him. The rival must still be the pillager, on paper and in the body.
       P2.rivals={}; P2.rivals[rid]=realRec(); P2.rivals[GK]=ghostRec();
       var a=myRival();
       if(a!==rid) bad.push('with the friend record at three kills beside a pillager at two, the rival on paper is '+a+' rather than the pillager, a name no pillager body ever carries');
       var b=mkRaider(100,100,real,false);
       if(!b||b.rival!==1) bad.push('with the friend record at three kills beside him, the pillager with two kills on the ledger was built without the rival mark');
       // ARM B: only the friend on the ledger. Nobody is the rival, rather than a key no body can match.
       P2.rivals={}; P2.rivals[GK]=ghostRec();
       var nb=myRival();
       if(nb!==null) bad.push('with only the friend record on the ledger, at three kills, the rival on paper is '+nb+' rather than nobody');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ P2.rivals=JSON.parse(keep); saveProfile(); }catch(_s){}
       try{ if(rngWas!==null) RNGS=rngWas; }catch(_g){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
