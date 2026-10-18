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

if ($s.Contains("  {v:'29.27',what:")) { throw "check 29.27 is in the fixture already" }

SubRx @'
  {v:'29.26',what:
'@ @'
  {v:'29.27',what:'a controller drop of a stack between the stash and the backpack asks how many, like the Ctrl drag',
   run:function(){
     if(typeof qtyAsk!=='function'||typeof qtyDrag!=='function'||typeof stashPadAct!=='function') return 'SKIP: no quantity prompt or pad drop';
     if(!__vpAlive()) return 'SKIP: the pane has no layout';
     var P0, cell, kg, md, num, i, cs, gr, nm;
     function kitN(){ var n=0, p=__P(); for(var j=0;j<(p.kit||[]).length;j++) if(p.kit[j]==='servo') n++; return n; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __showScreen('hub'); }catch(_sh){}
       P0=__P(); P0.stash=['servo','servo','servo','servo','servo','scrap']; P0.kit=[]; P0.hotAssign={}; P0.kitChosen=0;
       renderHub(); document.getElementById('hub').classList.add('on');
       nm=ITEMS.servo.name; gr=document.getElementById('stashgrid'); kg=document.getElementById('kitgrid');
       if(!gr||!kg) return 'the stash screen did not open';
       cs=gr.querySelectorAll('.cell'); cell=null;
       for(i=0;i<cs.length;i++) if((cs[i].title||'').indexOf(nm)===0){ cell=cs[i]; break; }
       if(!cell||!(cell.getBoundingClientRect().width>0)) return 'no servo cell with a layout';
       if(!stashPadAct(cell)) return 'pad A did not pick up the servos';
       stashPadAct(kg);
       md=document.getElementById('qtymodal'); num=document.getElementById('qtyn');
       if(!md||!md.classList.contains('on')) return 'a pad drop of 5 servos on the backpack opened no prompt';
       if(String(num.value)!=='5') return 'the prompt did not preselect 5, it shows '+num.value;
       if(kitN()!==0) return 'the prompt moved servos before it was answered';
       num.value='2'; document.getElementById('qtyok').click();
       if(kitN()!==2) return 'asked for 2, the backpack holds '+kitN();
       return null;
     } finally {
       try{ var m2=document.getElementById('qtymodal'); if(m2) m2.classList.remove('on'); }catch(_e){}
       try{ __cleanProfile(); }catch(_e){}
       __topClear();
     } }},
  {v:'29.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
