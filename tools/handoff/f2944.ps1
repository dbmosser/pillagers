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

if ($s.Contains("  {v:'29.44',what:")) { throw "check 29.44 is in the fixture already" }

SubRx @'
  {v:'29.43',what:
'@ @'
  {v:'29.44',what:'the operator menu is Panel P: a 640px card, 32px title, three 56px buttons, Exit demo set 32px apart, sentence case, no footer hint (critic 2 of 5 on screens 62, 63)',
   run:function(){
     if(typeof arcadeEnter!=='function'||typeof ARCADE!=='object'||typeof arcadeLeave!=='function'||typeof ARCADE_BOARD_KEY!=='string') return 'SKIP: no arcade here';
     var PK='pillagers:arcade:'+'party', bk=localStorage.getItem(ARCADE_BOARD_KEY), pk=localStorage.getItem(PK), op, cs, bs, t, r, i, c2, res=null;
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
       cs=getComputedStyle(op);
       if(Math.abs(parseFloat(cs.width)-640)>1) res='the card is '+cs.width+' wide, not 640px';
       else if(Math.abs(parseFloat(cs.paddingLeft)-32)>1) res='the card padding is '+cs.paddingLeft+', not 32px';
       else if(Math.abs(parseFloat(cs.borderTopLeftRadius)-4)>1) res='the card corner is '+cs.borderTopLeftRadius+', not 4px';
       t=op.querySelector('.arcoptitle');
       if(!res&&(!t||Math.abs(parseFloat(getComputedStyle(t).fontSize)-32)>1)) res='the title is '+(t?getComputedStyle(t).fontSize:'missing')+', not 32px';
       if(!res&&/[A-Z]{4,}/.test(op.textContent)) res='the card has an all caps word: '+op.textContent.slice(0,60);
       bs=op.querySelectorAll('button[data-op]');
       if(!res&&bs.length!==3) res=bs.length+' buttons, not 3';
       for(i=0;!res&&i<bs.length;i++){ c2=getComputedStyle(bs[i]); if(Math.abs(parseFloat(c2.height)-56)>1) res='button '+i+' is '+c2.height+' high, not 56px'; }
       if(!res&&(Math.abs(parseFloat(getComputedStyle(bs[0]).marginTop)-16)>1||Math.abs(parseFloat(getComputedStyle(bs[1]).marginTop)-32)>1)) res='gaps are '+getComputedStyle(bs[0]).marginTop+' and '+getComputedStyle(bs[1]).marginTop+', not 16px and 32px';
       if(!res&&op.querySelector('.arcopnote')) res='a footer hint is on the card before anything was pressed';
       return res;
     } finally {
       try{ if(typeof arcadeOpClose==='function') arcadeOpClose(); }catch(_c){}
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(bk===null) localStorage.removeItem(ARCADE_BOARD_KEY); else localStorage.setItem(ARCADE_BOARD_KEY,bk); if(pk===null) localStorage.removeItem(PK); else localStorage.setItem(PK,pk); }catch(_s){}
     }
   }},
  {v:'29.43',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
