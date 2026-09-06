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

# v11.50 HOOK: open or close the Undercroft backpack through the REAL
# hubBagOpenSet, which takes the snapshot; __hubBag only flips the flag.
SubRx @'
window.__hubBagLive=function(){ return hubBagG; };
'@ @'
window.__hubBagLive=function(){ return hubBagG; };
window.__hubBagSet=function(on){ hubBagOpenSet(!!on); return {open:hubBagOpen, snap:!!hubBagG}; };
'@

# v11.50 CHECK, inserted before the v11.49 entry.
SubRx @'
  {v:'11.49',what:'with the backpack open, a click on the panel background (not a tile) does not reach the trigger; a click outside the panel still does',
'@ @'
  {v:'11.50',what:'opening THE STASH with the Undercroft backpack open commits and closes the backpack first, so what you pack at the terminal is not overwritten by the stale backpack snapshot when it closes',
   run:function(){
     if(!(window.__hubBagSet&&window.__hubBagLive&&window.__station&&window.__P)) return 'SKIP: this fixture cannot open the Undercroft backpack and the terminal';
     __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
     var P=window.__P(), bad=[];
     P.kit=[]; P.hotAssign={};
     // Open the backpack on the floor: this takes the snapshot the close commits.
     var o=window.__hubBagSet(true);
     if(!(o.open&&o.snap)) return 'SKIP: the backpack did not open with a snapshot';
     // Walk to THE STASH and press E: the real terminal act.
     var st=null; try{ st=window.__station('term','KeyE'); }catch(e){ st={err:String(e)}; }
     if(st&&st.err) return 'SKIP: '+st.err;
     // THE FIX: the terminal committed and closed the backpack before drawing.
     var openAfter=window.__hubBagSet===undefined?null:(function(){ try{ return !!window.__hubBagLive(); }catch(e){ return null; } })();
     // What the terminal does to the loadout: pack an item and bind it to a key.
     P.kit.push('medkit'); P.hotAssign[3]='medkit';
     // ESC: on the old build the backpack is still open and its close writes the
     // stale (empty) snapshot over the terminal's edits.
     if(openAfter) window.__hubBagSet(false);
     if(openAfter) bad.push('the backpack was still open (snapshot live) after the terminal opened, so its close could overwrite the terminal');
     if((P.kit||[]).indexOf('medkit')<0) bad.push('the item packed at the terminal was wiped from the backpack when the backpack closed');
     if(P.hotAssign[3]!=='medkit') bad.push('the belt key set at the terminal was wiped when the backpack closed');
     try{ document.getElementById('hub').classList.remove('on'); }catch(e2){}
     __cleanProfile(); __topClear();
     return bad.length?bad.join('; '):null; }},
  {v:'11.49',what:'with the backpack open, a click on the panel background (not a tile) does not reach the trigger; a click outside the panel still does',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
