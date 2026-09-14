$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'14.45',what:
'@ @'
  {v:'14.46',what:'SPACE and H wait while the floor backpack is open: SPACE on the floor with the backpack shut starts a roll, and with it open SPACE starts no roll and H does not toggle the controls panel (floor audit finding 2)',
   run:function(){
     if(typeof showScreen!=='function'||typeof hubBagOpenSet!=='function') return 'SKIP: no floor backpack in this build';
     if(typeof G!=='undefined'&&G) return 'SKIP: a raid is live, so the floor keys cannot be driven';
     var bad=[], tt=document.getElementById('title'), ttOn=tt&&tt.classList.contains('on');
     var press=function(code,key){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true})); };
     try{
       __topClear(); __cleanProfile();
       showScreen('hub'); __topClear();
       if(tt) tt.classList.remove('on');
       if(typeof HB==='undefined'||!HB||!HB.player) return 'SKIP: no Undercroft floor player in this build';
       HB.player.rollT=0; HB.legend=false;
       // CONTROL: with the backpack shut, SPACE on the floor starts a roll.
       press('Space',' ');
       if(!(HB.player.rollT>0)) return 'SKIP: SPACE on the floor with nothing open started no roll, so the floor keys did not run here';
       HB.player.rollT=0;
       // THE FIX: with the backpack open, SPACE and H do nothing.
       hubBagOpenSet(true);
       if(!hubBagOpen) return 'SKIP: the floor backpack did not open';
       press('Space',' ');
       if(HB.player.rollT>0) bad.push('SPACE behind the open floor backpack started a roll that runs the moment it closes');
       press('KeyH','h');
       if(HB.legend) bad.push('H behind the open floor backpack toggled the controls panel hidden under it');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ if(hubBagOpen) hubBagOpenSet(false); }catch(_b){}
       try{ if(HB&&HB.player){ HB.player.rollT=0; HB.legend=false; } }catch(_r){}
       try{ if(tt&&ttOn) tt.classList.add('on'); }catch(_t){}
       try{ var K3=__keysRef(); for(var k3 in K3) K3[k3]=false; }catch(_k){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'14.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
