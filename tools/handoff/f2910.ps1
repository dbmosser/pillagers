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

if ($s.Contains("  {v:'29.10',what:")) { throw "check 29.10 is in the fixture already" }

SubRx @'
  {v:'29.09',what:
'@ @'
  {v:'29.10',what:'a Ctrl drag of a stack between the stash and the backpack asks how many (his note: i should get a prompt asking me how many I want to transfer), Enter moves that many, Esc cancels, a plain drag still moves one',
   run:function(){
     if(typeof qtyAsk!=='function'||typeof qtyDrag!=='function') return 'a Ctrl drag has no quantity prompt (no qtyAsk)';
     if(!__vpAlive()) return 'SKIP: the pane has no layout, so no drag can land';
     var g=null, P0=null, bad=null;
     function find(gridId,name){
       var gr=document.getElementById(gridId); if(!gr) return null;
       var cs=gr.querySelectorAll('.cell');
       for(var i=0;i<cs.length;i++) if((cs[i].title||'').indexOf(name)===0) return cs[i];
       return null;
     }
     function drag(cell,zone,ctrl){
       var cr=cell.getBoundingClientRect(), zr=zone.getBoundingClientRect();
       var x=zr.left+zr.width/2, y=zr.top+Math.min(zr.height/2,60);
       cell.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true,ctrlKey:!!ctrl,clientX:cr.left+cr.width/2,clientY:cr.top+cr.height/2}));
       document.dispatchEvent(new MouseEvent('mousemove',{bubbles:true,clientX:x,clientY:y}));
       document.dispatchEvent(new MouseEvent('mouseup',{bubbles:true,cancelable:true,ctrlKey:!!ctrl,clientX:x,clientY:y}));
     }
     function key(inp,code){ inp.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:code,bubbles:true,cancelable:true})); }
     function kitN(){ var n=0, p=__P(); for(var i=0;i<(p.kit||[]).length;i++) if(p.kit[i]==='servo') n++; return n; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __showScreen('hub'); }catch(_sh){}
       P0=__P();
       P0.stash=['servo','servo','servo','servo','servo','scrap']; P0.kit=[]; P0.hotAssign={}; P0.kitChosen=0;
       renderHub(); document.getElementById('hub').classList.add('on');
       var nm=ITEMS.servo.name, cell=find('stashgrid',nm), kc=document.getElementById('kitcol'), kg=document.getElementById('kitgrid'), sg=document.getElementById('stashgrid');
       if(!cell||!kc||!kg) return 'the stash screen did not open, so this check is testing nothing';
       if(!(cell.getBoundingClientRect().width>0&&kg.getBoundingClientRect().width>0)) return 'the stash panel has no layout, so this check is testing nothing';
       // 1. Ctrl drag opens the prompt with the most preselected, and moves nothing yet
       drag(cell,kg,true);
       var md=document.getElementById('qtymodal'), num=document.getElementById('qtyn');
       if(!md||!md.classList.contains('on')) return 'a Ctrl drag of 5 servos to the backpack opened no prompt';
       if(String(num.value)!=='5') return 'the prompt did not preselect the most (5), it shows '+num.value;
       if(kitN()!==0) return 'the prompt moved servos before it was answered';
       // 2. 3 and Enter moves exactly 3
       num.value='3'; key(num,'Enter');
       if(md.classList.contains('on')) return 'Enter did not close the prompt';
       if(kitN()!==3) return 'asked for 3, the backpack holds '+kitN()+' servos';
       if(__P().stash.filter(function(x){ return x==='servo'; }).length!==5) return 'the stash lost servos it only lent to the backpack';
       // 3. Esc cancels (2 left to move)
       cell=find('stashgrid',nm); drag(cell,document.getElementById('kitgrid'),true);
       if(!md.classList.contains('on')) return 'the second Ctrl drag opened no prompt';
       if(String(num.value)!=='2') return 'the second prompt did not preselect the 2 left, it shows '+num.value;
       key(num,'Escape');
       if(md.classList.contains('on')) return 'Escape did not close the prompt';
       if(kitN()!==3) return 'Escape still moved servos ('+kitN()+')';
       // 4. a plain drag still moves one, with no prompt
       cell=find('stashgrid',nm); drag(cell,document.getElementById('kitgrid'),false);
       if(md.classList.contains('on')) return 'a plain drag opened the prompt';
       if(kitN()!==4) return 'a plain drag should move one (4), the backpack holds '+kitN();
       // 5. and back: Ctrl drag from the backpack to the stash, 2 of 4
       var kcell=find('kitgrid',nm); if(!kcell) return 'the backpack showed no servo cell';
       drag(kcell,document.getElementById('stashgrid'),true);
       if(!md.classList.contains('on')) return 'a Ctrl drag from the backpack to the stash opened no prompt';
       if(String(num.value)!=='4') return 'the stash prompt did not preselect 4, it shows '+num.value;
       num.value='2'; key(num,'Enter');
       if(kitN()!==2) return 'moving 2 back left '+kitN()+' in the backpack';
       return null;
     } finally {
       try{ var m2=document.getElementById('qtymodal'); if(m2) m2.classList.remove('on'); }catch(_e1){}
       try{ document.getElementById('hub').classList.remove('on'); }catch(_e2){}
       __topClear();
     } }},
  {v:'29.09',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
