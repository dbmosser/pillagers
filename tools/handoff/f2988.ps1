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

if ($s.Contains("  {v:'29.88',what:")) { throw "check 29.88 is in the fixture already" }

SubRx @'
  {v:'29.87',what:
'@ @'
  {v:'29.88',what:'operator menu: the backdrop is a near solid scrim (the board no longer shows through), the three buttons share one 16px gap, and Exit demo is not red until it is focused (critic 2 of 5: one red, uneven gaps, clutter behind; screens 62 63)',
   run:function(){
     if(typeof arcadeEnter!=='function'||typeof ARCADE!=='object'||typeof arcadeLeave!=='function'||typeof ARCADE_BOARD_KEY!=='string') return 'SKIP: no arcade here';
     var PK='pillagers:arcade:'+'party', bk=localStorage.getItem(ARCADE_BOARD_KEY), pk=localStorage.getItem(PK), op, bs, bd, m, a, res=null;
     function key(code,o){ o=o||{}; var tg=document.body||window;
       tg.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,ctrlKey:!!o.c,shiftKey:!!o.s,bubbles:true,cancelable:true}));
       tg.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,ctrlKey:!!o.c,shiftKey:!!o.s,bubbles:true,cancelable:true})); keys={}; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeEnter('host')||!ARCADE.on) return 'SKIP: arcadeEnter did not turn the arcade on';
       key('F10',{c:1,s:1});
       op=document.getElementById('arc'+'op');
       if(!op) return 'the operator chord opened no operator menu';
       bs=op.querySelectorAll('button[data-op]');
       if(bs.length!==3) return bs.length+' buttons, not 3';
       if(Math.abs(parseFloat(getComputedStyle(bs[1]).marginTop)-parseFloat(getComputedStyle(bs[2]).marginTop))>1) res='the gaps are '+getComputedStyle(bs[1]).marginTop+' and '+getComputedStyle(bs[2]).marginTop+', not one gap';
       if(!res&&bs[1].style.color.indexOf('danger')>=0) res='Exit demo is red while it is not focused: '+bs[1].style.color;
       bd=op.previousElementSibling; m=bd?/rgba?\([^)]*\)|color\(srgb[^)]*\)/.exec(getComputedStyle(bd).backgroundColor):null; a=bd?getComputedStyle(bd).backgroundColor:'';
       if(!res){ var al=/\/\s*([0-9.]+)\s*\)/.exec(a); var av=al?parseFloat(al[1]):(/rgba\([^)]*,\s*([0-9.]+)\)/.exec(a)?parseFloat(/rgba\([^)]*,\s*([0-9.]+)\)/.exec(a)[1]):1); if(av<0.95) res='the operator backdrop is '+a+', the board shows through'; }
       return res;
     } finally {
       try{ if(typeof arcadeOpClose==='function') arcadeOpClose(); }catch(_c){}
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(bk===null) localStorage.removeItem(ARCADE_BOARD_KEY); else localStorage.setItem(ARCADE_BOARD_KEY,bk); if(pk===null) localStorage.removeItem(PK); else localStorage.setItem(PK,pk); }catch(_s){}
     }
   }},
  {v:'29.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
