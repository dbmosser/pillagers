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

if ($s.Contains("  {v:'30.97',what:")) { throw "check 30.97 is in the fixture already" }

SubRx @'
  {v:'30.96',what:
'@ @'
  {v:'30.97',what:'the operator card hides tonight 0 runs and rings the focused New party in amber, not white (critic 62)',
   run:function(){
     if(typeof arcadeEnter!=='function'||typeof arcadeOpDraw!=='function'||typeof arcadeBoardTonight!=='function'||typeof arcadePartyCode!=='function') return 'SKIP: no arcade here';
     var oldT=arcadeBoardTonight, oldC=arcadePartyCode, res=null, op, sub, b0, probe, acc, tx, sh;
     function key(code,o){ o=o||{}; var tg=document.body||window;
       tg.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,ctrlKey:!!o.c,shiftKey:!!o.s,bubbles:true,cancelable:true}));
       tg.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,ctrlKey:!!o.c,shiftKey:!!o.s,bubbles:true,cancelable:true})); keys={}; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeEnter('host')||!ARCADE.on) return 'SKIP: arcadeEnter did not turn the arcade on';
       arcadeBoardTonight=function(){ return []; }; arcadePartyCode=function(){ return ''; };
       key('F10',{c:1,s:1});
       op=document.getElementById('arc'+'op');
       if(!op) return 'the operator chord opened no operator menu';
       sub=op.querySelector('.arcopsub');
       if(sub&&/tonight|run/i.test(sub.textContent)) return 'the card still says: '+sub.textContent;
       b0=op.querySelector('button[data-op]');
       probe=document.createElement('i'); document.body.appendChild(probe);
       probe.style.color='var(--acc)'; acc=getComputedStyle(probe).color; probe.style.color='var(--tx-1)'; tx=getComputedStyle(probe).color; probe.remove();
       sh=getComputedStyle(b0).boxShadow;
       if(sh.indexOf(acc)<0) return 'the focus ring is not amber: '+sh;
       if(sh.indexOf(tx)>=0) return 'the focus ring still has white: '+sh;
       arcadeBoardTonight=function(){ return [1]; };
       arcadeOpDraw(); op=document.getElementById('arc'+'op'); sub=op.querySelector('.arcopsub');
       if(!sub||!/tonight: 2 runs/i.test(sub.textContent)) return 'with runs the line is gone: '+(sub?sub.textContent:'missing');
       return res;
     } finally {
       try{ arcadeBoardTonight=oldT; arcadePartyCode=oldC; }catch(_o){}
       try{ if(typeof arcadeOpClose==='function') arcadeOpClose(); }catch(_c){}
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
     }
   }},
  {v:'30.96',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
