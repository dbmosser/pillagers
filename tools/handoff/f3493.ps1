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

if ($s.Contains("  {v:'34.93',what:")) { throw "check 34.93 is in the fixture already" }

SubRx @'
  {v:'34.92',what:
'@ @'
  {v:'34.93',what:'the Settings side panel for the difficulty row says what the choice on its button means (it read "new player" on the main game)',
   run:function(){
     if(typeof diffRowHtml!=='function'||typeof setHintShort!=='function') return 'no difficulty row';
     var bad=[], go=(P&&P.gameOpts)?JSON.stringify(P.gameOpts):null;
     function pane(tag,word,want,never){
       var b=document.getElementById('set_diff'), r=b&&b.closest?b.closest('.row'):null, h=r?r.querySelector('.hint'):null, s;
       if(!b){ bad.push(tag+': no difficulty row'); return; }
       if(b.textContent!==word){ bad.push(tag+': the row says "'+b.textContent+'" not "'+word+'"'); return; }
       s=h?setHintShort(h.textContent):'';
       if(s.indexOf(want)<0) bad.push(tag+': the side panel reads "'+s+'", not "'+want+'"');
       if(never&&s.indexOf(never)>=0) bad.push(tag+': the side panel reads "'+s+'" on '+word);
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       itchDefs(0); P.gameOpts={}; applyGameOpts(); SETSUB=''; renderSettings();
       pane('main game','main game','standard hits','new player');
       diffSet(ITCH_EASY); renderSettings();
       pane('new player','new player','softer hits',null);
       P.gameOpts.hits=0; applyGameOpts(); renderSettings();
       pane('one row by hand','custom','changed by hand','new player');
     } catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       SETSUB=''; try{ itchDefs(ON_ITCH?1:0); }catch(_d){}
       try{ if(go===null) delete P.gameOpts; else P.gameOpts=JSON.parse(go); }catch(_g){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); applyGameOpts(); __resetCfg(); xfSnap(); renderSettings(); __topClear(); }catch(_f){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'34.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
