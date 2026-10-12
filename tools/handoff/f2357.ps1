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

if ($s.Contains("  {v:'23.57',what:")) { throw "check 23.57 is in the fixture already" }

SubRx @'
  {v:'23.56',what:
'@ @'
  {v:'23.57',what:'arcade32, a low finding of the arcade31 review (the board starts fresh in credits): with the board key holding one untagged old scale row (s 99999) and one row tagged u cr (s 500), TONIGHTS BEST and BEST EVER see only the tagged row, the saved key no longer holds the untagged row, and a new board row is written with u cr',
   run:function(){
     var bad=[], hadBk=false, bk=null, now=Date.now(), sv=null, rows, i, o, raw, hit, b;
     try{
       __topClear();
       if(typeof arcadeBoardLoad!=='function'||typeof ARCADE!=='object'||typeof ARCADE_BOARD_KEY!=='string') return 'no arcade board in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       bk=localStorage.getItem(ARCADE_BOARD_KEY); hadBk=true;
       localStorage.setItem(ARCADE_BOARD_KEY,JSON.stringify({v:1,rows:[
         {run:'t32old',i:'OLD',s:99999,x:1,k:3,t:now-2000},
         {run:'t32new',i:'NEW',s:500,x:1,k:2,t:now-1000,u:'cr'}]}));
       rows=arcadeBoardTonight(now,2)||[];
       for(i=0;i<rows.length;i++) if(rows[i].run==='t32old') bad.push('TONIGHTS BEST still shows the untagged old scale row');
       hit=false; for(i=0;i<rows.length;i++) if(rows[i].run==='t32new'&&rows[i].s===500) hit=true;
       if(!hit) bad.push('TONIGHTS BEST lost the tagged row of 500');
       b=arcadeBoardBest(2);
       if(b!==500) bad.push('BEST EVER reads '+b+', not 500 (the untagged 99999 must be gone)');
       raw=localStorage.getItem(ARCADE_BOARD_KEY)||'';
       if(raw.indexOf('t32'+'old')>=0) bad.push('the saved board key still holds the untagged row');
       if(raw.indexOf('t32'+'new')<0) bad.push('the saved board key lost the tagged row');
       sv={on:ARCADE.on,role:ARCADE.role,run:ARCADE.run,mine:ARCADE.mine,mate:ARCADE.mate,solo:ARCADE.solo,ext:ARCADE.ext,kills:ARCADE.kills,mateX:ARCADE.mateX,mateK:ARCADE.mateK};
       ARCADE.on=true; ARCADE.role='host'; ARCADE.run={id:'t32put'}; ARCADE.mine=777; ARCADE.mate=0; ARCADE.solo=0;
       if(!arcadeBoardPut()) bad.push('arcadeBoardPut wrote no row');
       else {
         o=null; try{ o=JSON.parse(localStorage.getItem(ARCADE_BOARD_KEY)||'null'); }catch(_p){ o=null; }
         hit=null; if(o&&Array.isArray(o.rows)) for(i=0;i<o.rows.length;i++) if(o.rows[i]&&o.rows[i].run==='t32put') hit=o.rows[i];
         if(!hit) bad.push('the new run row is not in the saved key');
         else if(hit.u!=='cr') bad.push('the new board row has no u cr tag (u is '+hit.u+')');
         else if(hit.s!==777) bad.push('the new board row scored '+hit.s+', not 777');
         hit=null; if(o&&Array.isArray(o.rows)) for(i=0;i<o.rows.length;i++) if(o.rows[i]&&o.rows[i].run==='t32new') hit=o.rows[i];
         if(!hit||hit.u!=='cr') bad.push('the tagged row lost its tag on the save');
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(sv){ for(var kk in sv) ARCADE[kk]=sv[kk]; } }catch(_r){}
       try{ if(hadBk){ if(bk===null) localStorage.removeItem(ARCADE_BOARD_KEY); else localStorage.setItem(ARCADE_BOARD_KEY,bk); } }catch(_rb){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.56',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
