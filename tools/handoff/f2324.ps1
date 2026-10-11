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

if ($s.Contains("  {v:'23.24',what:")) { throw "check 23.24 is in the fixture already" }

SubRx @'
  {v:'23.23',what:
'@ @'
  {v:'23.24',what:'his order: the title has the 2 PLAYER ARCADE DEMO row, the host tells player 2 arcon on entry and on ready, the player 2 address carries arc=1, player 2 enters and leaves the arcade on arcon and arcoff, and in the arcade a mousemove or Shift starts nothing while a key press drops the host straight into an arcade raid',
   run:function(){
     var bad=[], out=[], sv=null, row, rows, u, g0, rp, ap, k;
     function has(t){ for(var q=0;q<out.length;q++) if(out[q]&&out[q].t===t&&out[q].pair==='tp') return true; return false; }
     function kd(code,key){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true})); window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:key,bubbles:true})); }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeEnter!=='function'||typeof arcadeOnMsg!=='function'||typeof ARCADE!=='object') return 'no arcadeEnter in this build';
       row=document.getElementById('modearcade');
       if(!row) bad.push('the title has no arcade row');
       else if(String(row.textContent).trim()!=='2 PLAYER ARCADE'+' DEMO') bad.push('the arcade row reads '+row.textContent);
       rows=netTitleRows();
       if(!row||rows.indexOf(row)<0) bad.push('the arcade row is not one the arrows and the pad land on');
       if(__state()&&!__state().over) __endRaid('abandon');
       if(__state()) return 'SKIP: a raid is still up after __topClear';
       sv={bc:NET.bc,same:NET.same,pair:NET.pair,mode:NET.mode,arcPick:NET.arcPick,busy:NET.sameBusy};
       NET.bc={postMessage:function(m){ out.push(m); },close:function(){}}; NET.same='host'; NET.pair='tp'; NET.sameBusy=true;
       NET.arcPick=0; u=netP2Url('coop','tp');
       if(u.indexOf('arc=')>=0) bad.push('a co-op player 2 address carries arc: '+u);
       NET.arcPick=1; u=netP2Url('coop','tp');
       if(u.indexOf('&arc=1')<0) bad.push('the arcade player 2 address has no &arc=1: '+u);
       if(netArcOf(u.slice(u.indexOf('?')))!==1) bad.push('netArcOf does not read the arcade address');
       if(!arcadeEnter('host')) bad.push('arcadeEnter(host) failed');
       if(!ARCADE.on||ARCADE.role!=='host') bad.push('the host is not in the arcade (on '+ARCADE.on+', role '+ARCADE.role+')');
       if(!has('arcon')) bad.push('entering the arcade did not tell player 2 (no arcon)');
       out.length=0;
       netSameOnMsg({t:'ready',pair:'tp'});
       if(!has('arcon')) bad.push('a player 2 window saying ready is not told arcon');
       ap=ATT.el&&ATT.el.querySelector('.attpress');
       if(!ATT.on||!ATT.el||ATT.el.style.display==='none') bad.push('the arcade attract is not up');
       else if(!ap||ap.textContent!=='PRESS ANY'+' BUTTON') bad.push('the host attract reads '+(ap&&ap.textContent));
       window.dispatchEvent(new MouseEvent('mousemove',{clientX:300,clientY:300,bubbles:true}));
       window.dispatchEvent(new MouseEvent('mousemove',{clientX:620,clientY:480,bubbles:true}));
       if(__state()) bad.push('a mousemove started a raid');
       kd('ShiftLeft','Shift');
       if(__state()) bad.push('a Shift press started a raid');
       kd('KeyJ','j');
       g0=__state();
       if(!g0||g0.arcade!==1) bad.push('a key press did not drop the host into an arcade raid');
       else if(ATT.on) bad.push('the attract stayed up over the arcade raid');
       out.length=0;
       arcadeLeave();
       if(ARCADE.on) bad.push('arcadeLeave left the arcade on');
       if(!has('arcoff')) bad.push('leaving did not tell player 2 (no arcoff)');
       if(ATT.on) bad.push('the attract stayed up after leaving');
       if(__state()) bad.push('a raid is still up after leaving');
       // the player 2 side
       NET.same='p2'; out.length=0;
       rp=netSameOnMsg({t:'arcon',pair:'tp'});
       if(rp!=='arcon'||!ARCADE.on||ARCADE.role!=='p2') bad.push('player 2 did not enter the arcade on arcon ('+rp+', on '+ARCADE.on+', role '+ARCADE.role+')');
       else {
         if(P.pname!=='PLAYER 2') bad.push('player 2 is named '+P.pname);
         ap=ATT.el&&ATT.el.querySelector('.attpress');
         if(!ATT.on||!ap||ap.textContent!=='PLAYER 2: PRESS'+' A') bad.push('the player 2 attract reads '+(ap&&ap.textContent));
         kd('KeyJ','j');
         if(__state()) bad.push('a key in the player 2 window started a raid there');
         if(has('arcon')) bad.push('player 2 sent arcon');
       }
       rp=netSameOnMsg({t:'arcoff',pair:'tp'});
       if(ARCADE.on) bad.push('player 2 stayed in the arcade after arcoff ('+rp+')');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(sv){ netSameStop(); NET.bc=sv.bc||null; NET.same=sv.same||''; NET.pair=sv.pair||''; NET.mode=sv.mode||''; NET.arcPick=sv.arcPick||0; NET.sameBusy=!!sv.busy; } }catch(_ns){}
       try{ for(k in keys) keys[k]=false; }catch(_k){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.23',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
