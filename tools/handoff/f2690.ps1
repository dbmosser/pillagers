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

if ($s.Contains("  {v:'26.90',what:")) { throw "check 26.90 is in the fixture already" }

SubRx @'
  {v:'26.89',what:
'@ @'
  {v:'26.90',what:'his answer 22 (2026-10-12): the operator chord on the demo attract opens an OPERATOR menu; NEW PARTY (pressed twice) clears tonights best in both lists and keeps BEST EVER; no key drops a player in while it is up; ESC closes it; EXIT DEMO leaves',
   run:function(){
     if(typeof arcadeEnter!=='function'||typeof ARCADE!=='object'||typeof arcadeLeave!=='function'||typeof arcadeBoardTonight!=='function'||typeof arcadeBoardBest!=='function'||typeof ARCADE_BOARD_KEY!=='string') return 'SKIP: no arcade board here';
     var bad=[], bk=null, pk=null, hadB=false, PK='pillagers:arcade:'+'party', now=Date.now(), op, b;
     function opEl(){ return document.getElementById('arc'+'op'); }
     function key(code,o){ o=o||{}; var t=document.body||window;
       t.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,ctrlKey:!!o.c,shiftKey:!!o.s,bubbles:true,cancelable:true}));
       t.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:code,ctrlKey:!!o.c,shiftKey:!!o.s,bubbles:true,cancelable:true})); keys={}; }
     try{
       __topClear(); __runPrep();
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       bk=localStorage.getItem(ARCADE_BOARD_KEY); pk=localStorage.getItem(PK); hadB=true;
       localStorage.setItem(ARCADE_BOARD_KEY,JSON.stringify({v:1,rows:[{run:'topq1',i:'QQQ',s:7770,x:1,k:2,t:now-3600000,m:2,u:'cr'},{run:'topq2',i:'ZZZ',s:3330,x:0,k:1,t:now-60000,m:1,u:'cr'}]}));
       localStorage.removeItem(PK);
       if(!arcadeEnter('host')||!ARCADE.on) return 'SKIP: arcadeEnter did not turn the arcade on';
       if(arcadeBoardTonight(Date.now(),2).length!==1||arcadeBoardTonight(Date.now(),1).length!==1) return 'SKIP: staging: the staged board does not read back';
       key('F10',{c:1,s:1});
       op=opEl();
       if(!ARCADE.on) bad.push('the operator chord on the attract left the arcade at once: there is no operator menu and no NEW PARTY');
       else if(!op) bad.push('the operator chord opened no operator menu');
       else {
         if(!/NEW PARTY/.test(op.textContent)) bad.push('the operator menu has no NEW PARTY');
         if(!/EXIT DEMO/.test(op.textContent)) bad.push('the operator menu has no EXIT DEMO');
         key('KeyX'); key('Space');
         if(__state()&&__state().arcade) bad.push('a key with the operator menu up dropped a player in');
         if(!opEl()) bad.push('a key closed the operator menu');
         b=opEl()&&opEl().querySelector('[data-op="party"]');
         if(!b) bad.push('no NEW PARTY row');
         else {
           if(!(__state()&&__state().arcade)){
             // Space armed it above (row 0 is focused); one more press clears. Click from a fresh arm to test the mouse.
             key('Escape');
             if(opEl()) bad.push('ESC did not close the operator menu');
             if(!ARCADE.on) bad.push('ESC with the operator menu up left the arcade');
             key('F10',{c:1,s:1});
             b=opEl()&&opEl().querySelector('[data-op="party"]');
             if(!b) bad.push('the chord did not open the operator menu again');
             else {
               b.click();
               if(arcadeBoardTonight(Date.now(),2).length!==1) bad.push('one press of NEW PARTY cleared the board (it must ask once more)');
               b=opEl().querySelector('[data-op="party"]'); b.click();
               if(arcadeBoardTonight(Date.now(),2).length) bad.push('NEW PARTY left the 2 player list of tonights best');
               if(arcadeBoardTonight(Date.now(),1).length) bad.push('NEW PARTY left the 1 player list of tonights best');
               if(arcadeBoardBest(2)!==7770) bad.push('NEW PARTY changed BEST EVER ('+arcadeBoardBest(2)+')');
               if(!ARCADE.on) bad.push('NEW PARTY left the arcade');
               if(!opEl()) bad.push('NEW PARTY closed the operator menu');
               key('ArrowDown'); key('Enter');
               if(ARCADE.on) bad.push('EXIT DEMO (down, ENTER) did not leave the arcade');
               if(opEl()) bad.push('the operator menu outlived the arcade');
             }
           }
         }
       }
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof arcadeOpClose==='function') arcadeOpClose(); }catch(_c){}
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(hadB){ if(bk===null) localStorage.removeItem(ARCADE_BOARD_KEY); else localStorage.setItem(ARCADE_BOARD_KEY,bk); if(pk===null) localStorage.removeItem(PK); else localStorage.setItem(PK,pk); } }catch(_rb){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'26.89',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
