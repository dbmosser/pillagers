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

if ($s.Contains("  {v:'20.51',what:")) { throw "check 20.51 is in the fixture already" }

SubRx @'
  {v:'20.50',what:
'@ @'
  {v:'20.51',what:'a save on the title can be picked on a controller: every save row the title lists is a control the pad highlight can land on, and D-pad down from 1 PLAYER lands on a save',
   run:function(){
     if(typeof padFocusables!=='function'||typeof pollPad!=='function'||typeof padSetFocus!=='function'||typeof PAD!=='object'||!PAD) return 'SKIP: no controller menus here';
     var t=document.getElementById('title'), sl=document.getElementById('slotlist'), go=document.getElementById('titlestart'), bad=[], tOn=false, rows, Lf, i, hit=null, seen=[];
     var own=Object.prototype.hasOwnProperty.call(navigator,'getGamepads'), NG=navigator.getGamepads, stubbed=false, PK={}, k, pad=null, mOn=[];
     if(!t||!sl||!go) return 'SKIP: no saves list on the title';
     function mk(down){ var b=[],q; for(q=0;q<17;q++) b.push({pressed:q===down,value:q===down?1:0,touched:q===down}); return {connected:true,id:'save row check pad',index:0,mapping:'standard',timestamp:Date.now(),buttons:b,axes:[0,0,0,0]}; }
     function tap(b){ pad=mk(b); pollPad(); pad=mk(-1); pollPad(); }
     function nm(el){ if(!el) return 'nothing'; if(el.getAttribute&&el.getAttribute('data-slot')) return 'save row '+el.getAttribute('data-slot'); return String(el.id||el.textContent||el.tagName).replace(/\s+/g,' ').slice(0,24); }
     for(k in PAD) PK[k]=PAD[k];
     tOn=t.classList.contains('on');
     try{
       if(typeof pauseOpen!=='undefined'&&pauseOpen) return 'SKIP: the pause box is open here';
       mOn=[].slice.call(document.querySelectorAll('.modal.on'));
       mOn.forEach(function(m){ m.classList.remove('on'); });
       __topClear();
       t.classList.add('on');
       rows=[].slice.call(sl.querySelectorAll('[data-slot]'));
       if(!rows.length) return 'SKIP: the title lists no saves here';
       Lf=padFocusables(t);
       if(Lf.indexOf(go)<0) return 'SKIP: 1 PLAYER is not laid out as a pad control here';
       for(i=0;i<rows.length;i++) if(Lf.indexOf(rows[i])<0) bad.push('save row '+rows[i].getAttribute('data-slot')+' is not a control the pad highlight can land on');
       // The D-pad, from 1 PLAYER down the title, one press and release at a time.
       try{ navigator.getGamepads=function(){ return [pad]; }; stubbed=(navigator.getGamepads!==NG); }catch(_s){}
       if(stubbed){
         padSetFocus(null); PAD.focus=null;
         pad=mk(-1); pollPad(); pollPad();
         if(PAD.focus!==go) bad.push('the pad highlight on the title starts on '+nm(PAD.focus)+', not 1 PLAYER');
         else {
           for(i=0;i<14&&!hit;i++){ tap(13); seen.push(nm(PAD.focus)); if(PAD.focus&&PAD.focus.getAttribute&&PAD.focus.getAttribute('data-slot')) hit=PAD.focus; }
           if(!hit) bad.push('D-pad down from 1 PLAYER never lands on a save ('+seen.join(' > ')+')');
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ navigator.getGamepads=function(){ return [null,null,null,null]; }; pollPad(); }catch(_p){}
       try{ if(own) navigator.getGamepads=NG; else delete navigator.getGamepads; }catch(_r){}
       try{ padSetFocus(null); }catch(_f){}
       for(k in PAD) if(!(k in PK)) delete PAD[k];
       for(k in PK) PAD[k]=PK[k];
       try{ padBodyCls(); }catch(_b){}
       t.classList.toggle('on',tOn);
       mOn.forEach(function(m){ m.classList.add('on'); });
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
