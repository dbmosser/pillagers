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

if ($s.Contains("  {v:'34.92',what:")) { throw "check 34.92 is in the fixture already" }

SubRx @'
  {v:'34.91',what:
'@ @'
  {v:'34.92',what:'itch players start on the new player set (forgiving hits, the long raid, rich loot, light shake, the large crosshair, seven extras off), every row stays in Settings, and the difficulty row switches all twelve to the main game and back',
   run:function(){
     if(typeof itchDefs!=='function'||typeof diffRowHtml!=='function'||typeof diffSet!=='function') return 'no itch new player defaults';
     var bad=[], go=(P&&P.gameOpts)?JSON.stringify(P.gameOpts):null, i, k, b, x;
     var XF=['xfAffix','xfRamp','xfOvPh','xfEvRamp','xfEvBounty','xfEvDebris','xfSupp'];
     function want(tag,ed,rs,lm,sh,xh,xf,word){
       if(CFG.eDmg!==ed) bad.push(tag+': eDmg '+CFG.eDmg+' not '+ed);
       if(CFG.raidSec!==rs) bad.push(tag+': raidSec '+CFG.raidSec+' not '+rs);
       if(CFG.lootMult!==lm) bad.push(tag+': lootMult '+CFG.lootMult+' not '+lm);
       if(CFG.shake!==sh) bad.push(tag+': shake '+CFG.shake+' not '+sh);
       if(CFG.xhSz!==xh) bad.push(tag+': xhSz '+CFG.xhSz+' not '+xh);
       for(i=0;i<XF.length;i++) if(CFG[XF[i]]!==xf) bad.push(tag+': '+XF[i]+' '+CFG[XF[i]]+' not '+xf);
       b=document.getElementById('set_diff');
       if(!b) bad.push(tag+': no difficulty row on the Settings page');
       else if(b.textContent!==word) bad.push(tag+': the difficulty row says "'+b.textContent+'" not "'+word+'"');
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       // 1 itch, nothing saved: the new player set, and every single row still on its page
       P.gameOpts={}; itchDefs(1); applyGameOpts(); SETSUB=''; renderSettings();
       want('itch start',0.7,900,1.35,0.5,1.3,0,'new player');
       for(x=['hits','clock','loot','shake','xhSz'],i=0;i<x.length;i++) if(!document.getElementById('go_'+x[i])) bad.push('itch start: the '+x[i]+' row is gone from Settings');
       SETSUB='exp'; renderSettings();
       for(i=0;i<XF.length;i++) if(!document.getElementById('go_'+XF[i])) bad.push('itch start: the '+XF[i]+' row is gone from the experimental page');
       SETSUB=''; renderSettings();
       // 2 one click: the main game, all twelve saved so a reload keeps it
       b=document.getElementById('set_diff'); if(b) b.click();
       want('after one click',1,540,1,1,1,1,'main game');
       for(i=0;i<DIFF_KEYS.length;i++) if(!P.gameOpts||typeof P.gameOpts[DIFF_KEYS[i]]!=='number') bad.push('after one click: '+DIFF_KEYS[i]+' not saved');
       // 3 a second click: back to the new player set
       b=document.getElementById('set_diff'); if(b) b.click();
       want('after two clicks',0.7,900,1.35,0.5,1.3,0,'new player');
       // 4 a hand change to one row reads custom
       P.gameOpts.hits=0; applyGameOpts(); renderSettings();
       b=document.getElementById('set_diff'); if(b&&b.textContent!=='custom') bad.push('one row changed by hand: the difficulty row says "'+b.textContent+'" not "custom"');
       // 5 anywhere else, nothing saved: the main game, as before
       itchDefs(0); P.gameOpts={}; applyGameOpts(); renderSettings();
       want('not itch',1,540,1,1,1,1,'main game');
     } catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       SETSUB=''; try{ itchDefs(ON_ITCH?1:0); }catch(_d){}
       try{ if(go===null) delete P.gameOpts; else P.gameOpts=JSON.parse(go); }catch(_g){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); applyGameOpts(); __resetCfg(); xfSnap(); renderSettings(); __topClear(); }catch(_f){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'34.91',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
