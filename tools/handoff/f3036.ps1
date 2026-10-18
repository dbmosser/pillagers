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

if ($s.Contains("  {v:'30.36',what:")) { throw "check 30.36 is in the fixture already" }

SubRx @'
  {v:'30.35',what:
'@ @'
  {v:'30.36',what:'his Q62 and Q63: a 2 player board row takes initials from each player, a 1 player row one set, and rude initials are refused',
   run:function(){
     if(window.storage&&window.storage.set) return 'SKIP: this host saves through window.storage, not localStorage';
     if(typeof arcadeSandboxIn!=='function'||typeof arcadeIniStart!=='function'||typeof arcadeIniOp!=='function'||typeof arcadeBoardSave!=='function') return 'SKIP: no arcade initials here';
     if(typeof arcadeIniRude!=='function') return 'there is no rude initials check';
     var bad=[], BK=ARCADE_BOARD_KEY, bk=null, hadB=false, nsp=netSamePost, row, rows, i;
     function rowOf(id){ var r=arcadeBoardLoad(), j; for(j=0;j<r.length;j++) if(r[j].run===id) return r[j]; return null; }
     function typeIt(s){ for(var j=0;j<s.length;j++) arcadeIniOp(s.charAt(j)); }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       try{ bk=localStorage.getItem(BK); hadB=true; localStorage.removeItem(BK); }catch(_b){}
       netSamePost=function(){ return true; };
       if(!arcadeIniRude('FCK')||!arcadeIniRude('ass')) bad.push('FCK or ASS is not on the rude list');
       if(arcadeIniRude('ABC')||arcadeIniRude('???')) bad.push('ABC or ??? is on the rude list');
       if(!arcadeSandboxIn('host')) return 'arcadeSandboxIn failed';
       ARCADE.solo=0; ARCADE.run={id:'tq62'}; ARCADE.ini=null;
       arcadeBoardSave([{run:'tq62',i:'',s:5000,x:1,k:3,t:Date.now(),m:2,u:'cr'}]);
       if(!arcadeBoardQual('tq62')) bad.push('a fresh 2 player row does not ask for initials');
       arcadeIniStart('tq62'); typeIt('ABC');
       if(!ARCADE.ini||(ARCADE.ini.who|0)!==2) bad.push('after player 1 typed ABC the card is not on player 2 (who '+(ARCADE.ini&&ARCADE.ini.who)+')');
       row=rowOf('tq62');
       if(!row||row.i!=='ABC') bad.push('player 1 initials were not written (row i '+(row&&row.i)+')');
       typeIt('XYZ');
       if(ARCADE.ini) bad.push('the card is still up after both players typed');
       row=rowOf('tq62');
       if(!row||row.i2!=='XYZ') bad.push('player 2 initials were not written (row i2 '+(row&&row.i2)+')');
       if(arcadeBoardQual('tq62')) bad.push('a row with both sets of initials still asks for them');
       // a rude set is refused
       ARCADE.run={id:'tq63'}; arcadeBoardSave([{run:'tq63',i:'',s:4000,x:1,k:3,t:Date.now(),m:2,u:'cr'}]);
       arcadeIniStart('tq63'); typeIt('FCK');
       row=rowOf('tq63');
       if(!ARCADE.ini||(ARCADE.ini.who|0)!==1) bad.push('FCK was taken as player 1 initials');
       if(row&&row.i) bad.push('FCK was written to the board (row i '+row.i+')');
       ARCADE.ini=null;
       // a 1 player row takes one set
       ARCADE.solo=1; ARCADE.run={id:'tq64'}; arcadeBoardSave([{run:'tq64',i:'',s:3000,x:1,k:3,t:Date.now(),m:1,u:'cr'}]);
       arcadeIniStart('tq64'); typeIt('QRS');
       if(ARCADE.ini) bad.push('a 1 player card asked for a second set');
       row=rowOf('tq64');
       if(!row||row.i!=='QRS') bad.push('1 player initials were not written (row i '+(row&&row.i)+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       netSamePost=nsp;
       try{ ARCADE.ini=null; ARCADE.solo=0; ARCADE.run=null; }catch(_i){}
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(hadB){ if(bk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,bk); } }catch(_b2){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'30.35',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
