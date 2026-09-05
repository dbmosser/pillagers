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
  {v:'11.25',what:'a pillager out of the player sight fires back only when engageNear is lifted: at 600 as shipped he fires zero rounds in a whole raid while the machines fire dozens, at 0 he fires, and the dial rolls no dice',
'@ @'
  {v:'11.26',what:'the pause screen key line prints no literal entity and names the keys the way the H list does: F strikes, TAB is the backpack, 1 to 9 is the tactical belt',
   run:function(){
     var pb=document.getElementById('pausebox');
     if(!pb) return 'SKIP: no pause box in this document';
     var bad=[], html=pb.innerHTML||'', text=(pb.textContent||'').replace(/\s+/g,' ');
     // THE FINDING, assembled so this check cannot match itself.
     var literal=['&','amp;','nbsp;'].join('');
     var lit2=['&','nbsp;'].join('');
     if(html.indexOf(literal)>=0) bad.push('the pause box still carries the double-escaped entity '+(html.split(literal).length-1)+' times');
     if(text.indexOf(lit2)>=0) bad.push('the pause box prints the six characters "'+lit2+'" to the player');
     var stale=[['F ','heal/revive'].join(''), ['Q/G ','throw'].join(''), ['TAB ','bag '].join(''), ['sprint ','on/off'].join(''), ['superhot ','mode'].join('')];
     for(var i=0;i<stale.length;i++) if(text.indexOf(stale[i])>=0) bad.push('the pause box still says "'+stale[i]+'"');
     // WHAT IT MUST SAY, and it must agree with the H list.
     var need=[['F ','melee strike'].join(''), ['TAB ','backpack'].join(''), ['tactical ','belt'].join(''), ['hold to ','sprint'].join('')];
     for(i=0;i<need.length;i++) if(text.indexOf(need[i])<0) bad.push('the pause box does not say "'+need[i]+'"');
     var L=(window.__legend?__legend():null);
     if(L&&L.length){ var fRow=null; for(i=0;i<L.length;i++){ var rows=L[i][1]||[]; for(var j=0;j<rows.length;j++) if(rows[j][0]==='F') fRow=rows[j][1]; }
       if(fRow&&text.indexOf(fRow.split(',')[0])<0) bad.push('the pause box and the LEGEND table disagree about F: LEGEND says "'+fRow+'"'); }
     // CONTROL: the box is still the pause box, with its heading and its buttons.
     if(!pb.querySelector('h3')) bad.push('control: the pause box lost its heading');
     if(!document.getElementById('abandonbtn')||!document.getElementById('resumebtn')) bad.push('control: the pause box lost a button');
     return bad.length?bad.join('; '):null; }},
  {v:'11.25',what:'a pillager out of the player sight fires back only when engageNear is lifted: at 600 as shipped he fires zero rounds in a whole raid while the machines fire dozens, at 0 he fires, and the dial rolls no dice',
'@

SubRx @'
window.__world=function(){ return {w:WORLD_W,h:WORLD_H}; };
'@ @'
window.__world=function(){ return {w:WORLD_W,h:WORLD_H}; };
window.__legend=function(){ return LEGEND; };
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
