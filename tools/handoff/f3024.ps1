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

if ($s.Contains("  {v:'30.24',what:")) { throw "check 30.24 is in the fixture already" }

SubRx @'
  {v:'30.23',what:
'@ @'
  {v:'30.24',what:'an empty board draws no ghost rows, one centred line; the operator New party is the amber primary and Exit demo a ghost (critic 56 64 62)',
   run:function(){
     if(typeof arcadeEnter!=='function'||typeof arcadeAttEl!=='function'||typeof arcadeAttBoard!=='function'||typeof attEl!=='function'||typeof ARCADE_BOARD_KEY!=='string') return 'SKIP: no arcade here';
     var PK='pillagers:arcade:'+'party', bk=localStorage.getItem(ARCADE_BOARD_KEY), pk=localStorage.getItem(PK), d, pg, wasDisp, oldT, gs, i, res=null, op, bs, probe, want, got;
     function key(code,o){ o=o||{}; var tg=document.body||window;
       tg.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,ctrlKey:!!o.c,shiftKey:!!o.s,bubbles:true,cancelable:true}));
       tg.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,ctrlKey:!!o.c,shiftKey:!!o.s,bubbles:true,cancelable:true})); keys={}; }
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       try{ if(typeof attZ==='function') attZ(d); }catch(_z){}
       pg=arcadeAttEl('arcpage'); pg.textContent='';
       oldT=arcadeBoardTonight; arcadeBoardTonight=function(){ return []; };
       arcadeAttBoard(pg); pg.style.display='block'; pg.style.translate='none'; pg.style.opacity='1';
       gs=pg.querySelectorAll('.apg');
       if(gs.length<5) return 'the empty board lost its ghost rows in the page: '+gs.length;
       for(i=0;i<gs.length;i++){ if(getComputedStyle(gs[i]).display!=='none') return 'ghost row '+i+' is drawn ('+getComputedStyle(gs[i]).display+')'; }
       if(!pg.querySelector('.apn')||getComputedStyle(pg.querySelector('.apn')).textAlign!=='center') return 'the empty line is not centred: '+(pg.querySelector('.apn')?getComputedStyle(pg.querySelector('.apn')).textAlign:'missing');
       pg.textContent=''; pg.style.display='none'; d.style.display=wasDisp; arcadeBoardTonight=oldT; oldT=null;
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeEnter('host')||!ARCADE.on) return 'SKIP: arcadeEnter did not turn the arcade on';
       key('F10',{c:1,s:1});
       op=document.getElementById('arc'+'op');
       if(!op) return 'the operator chord opened no operator menu';
       bs=op.querySelectorAll('button[data-op]');
       if(bs.length<2) return 'fewer than 2 operator buttons';
       probe=document.createElement('i'); probe.style.background='var(--acc)'; document.body.appendChild(probe); want=getComputedStyle(probe).backgroundColor; probe.remove();
       got=getComputedStyle(bs[0]).backgroundColor;
       if(got!==want) return 'New party is '+got+', not the amber primary '+want;
       got=getComputedStyle(bs[1]).backgroundColor;
       if(got===want||!/rgba\(0, 0, 0, 0\)|transparent/.test(got)) return 'Exit demo is not a ghost: '+got;
       return res;
     } finally {
       try{ if(oldT) arcadeBoardTonight=oldT; }catch(_o){}
       try{ pg.textContent=''; pg.style.display='none'; d.style.display=wasDisp; }catch(_f){}
       try{ if(typeof arcadeOpClose==='function') arcadeOpClose(); }catch(_c){}
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(bk===null) localStorage.removeItem(ARCADE_BOARD_KEY); else localStorage.setItem(ARCADE_BOARD_KEY,bk); if(pk===null) localStorage.removeItem(PK); else localStorage.setItem(PK,pk); }catch(_s){}
     }
   }},
  {v:'30.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
