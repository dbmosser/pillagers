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

if ($s.Contains("  {v:'27.97',what:")) { throw "check 27.97 is in the fixture already" }

SubRx @'
  {v:'27.96',what:
'@ @'
  {v:'27.97',what:'his answers 12 and 13: the DEMO board holds 20 rows, drawn in two columns of ten, and only NEW PARTY clears it: a run 20 hours old stays on it, and a party seed outlives 12 hours',
   run:function(){
     if(typeof arcadeBoardTonight!=='function'||typeof ARCADE_BOARD!=='object'||typeof arcadeAttBoard!=='function'||typeof arcadeNewParty!=='function'||typeof ARCADE!=='object') return 'there is no party board in this build';
     var bad=[], K=ARCADE_BOARD_KEY, PK=ARCADE_PARTY_KEY, bk=null, pk=null, own=false, t0=Date.now(), rows=[], i, pg, r, cols, hasOld=false, s0, solo0=ARCADE.solo;
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       bk=localStorage.getItem(K); pk=localStorage.getItem(PK); own=true; ARCADE.solo=0;
       localStorage.removeItem(PK);
       if(ARCADE_BOARD.top!==20) bad.push('the board keeps '+ARCADE_BOARD.top+' rows, not 20');
       for(i=0;i<25;i++) rows.push({run:'r'+i,i:'AAA',s:1000+i*100,x:1,k:1,t:t0-(i<20?(60000+i):(20*3600000+i)),u:'cr'});
       localStorage.setItem(K,JSON.stringify({v:1,rows:rows}));
       r=arcadeBoardTonight();
       if(r.length!==20) bad.push('the board lists '+r.length+' rows, not 20');
       for(i=0;i<r.length;i++) if(r[i].run==='r24') hasOld=true;
       if(!hasOld) bad.push('a run 20 hours old is off the board without a NEW PARTY');
       pg=document.createElement('div'); arcadeAttBoard(pg);
       if(pg.querySelectorAll('.apr').length!==20) bad.push('the attract page draws '+pg.querySelectorAll('.apr').length+' rows, not 20');
       cols=pg.querySelectorAll('.apcol');
       if(cols.length!==2||cols[0].querySelectorAll('.apr').length!==10||cols[1].querySelectorAll('.apr').length!==10) bad.push('the page is not two columns of ten');
       localStorage.setItem(PK,JSON.stringify({t:t0-20*3600000,s:777,m:0}));
       s0=arcadePartySeed();
       if(s0!==777) bad.push('a party 20 hours old has lost its seed ('+s0+'): only NEW PARTY ends it');
       localStorage.setItem(PK,JSON.stringify({t:t0-30*3600000,s:777,m:0}));
       if(arcadeBoardTonight().length!==20) bad.push('with a party 30 hours old the board holds '+arcadeBoardTonight().length+', not 20 of the 20 hour old runs');
       if(!arcadeNewParty()) bad.push('NEW PARTY failed');
       if(arcadeBoardTonight().length!==0) bad.push('NEW PARTY left '+arcadeBoardTonight().length+' rows on the board');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ ARCADE.solo=solo0; }catch(_s){}
       try{ if(own){ if(bk===null) localStorage.removeItem(K); else localStorage.setItem(K,bk); if(pk===null) localStorage.removeItem(PK); else localStorage.setItem(PK,pk); } }catch(_r){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
