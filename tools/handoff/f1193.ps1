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

# v11.93 CHECK, inserted before the v11.92 entry. The title is raised, a name
# is typed into the box and ENTER pressed on the box itself (the element a
# real key event reaches); then another name is typed and the start button
# clicked. Both names must reach the profile.
SubRx @'
  {v:'11.92',what:'the NEW IN card greets only a player with runs behind him, and for him it fits the screen with its heading and its dismiss line both on the canvas (2026-09-06 first-ten-minutes audit)',
'@ @'
  {v:'11.93',what:'ENTER in the title name box commits the name, and the start button commits whatever is typed there (2026-09-06 first-ten-minutes audit)',
   run:function(){
     var t=document.getElementById('title'), pin=document.getElementById('pnamein'), st=document.getElementById('titlestart');
     if(!t||!pin||!st) return 'SKIP: no title screen in this fixture';
     var bad=[], P2=__P(), keepName=P2.pname, wasOn=t.classList.contains('on');
     try{
       __topClear(); __runPrep();
       t.classList.add('on');
       pin.value='KESTREL 4242'; try{ pin.focus(); }catch(_f){}
       pin.dispatchEvent(new KeyboardEvent('keydown',{key:'Enter',code:'Enter',bubbles:true,cancelable:true}));
       if(P2.pname!=='KESTREL 4242') bad.push('ENTER in the box left the name as '+P2.pname);
       if(!t.classList.contains('on')) bad.push('control: ENTER in the box started the game');
       t.classList.add('on');
       pin.value='MERLIN 4242';
       st.click();
       if(P2.pname!=='MERLIN 4242') bad.push('the start button left the name as '+P2.pname);
       if(t.classList.contains('on')) bad.push('control: the start button did not start the game');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       P2.pname=keepName; try{ pin.value=keepName||''; pin.blur(); }catch(_v){}
       try{ saveProfile(); }catch(_s){}
       t.classList.toggle('on',wasOn);
       try{ if(titleRefresh) titleRefresh(); }catch(_tr){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.92',what:'the NEW IN card greets only a player with runs behind him, and for him it fits the screen with its heading and its dismiss line both on the canvas (2026-09-06 first-ten-minutes audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
