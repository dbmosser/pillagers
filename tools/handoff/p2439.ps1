$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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

# A BLAST LEAVES ITS SCAR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function explodeFrag(f){
'@ @'
// v23.xx (gfx26), HIS ORDER (2026-10-12) on the graphics program: "add ALL of this stuff", item 12, richer ground. A BLAST LEAVES
// ITS SCAR. A frag, a Howler shell or a tripwire mine left one decal, a flat dark oval that faded after 45 seconds and that a busy
// fight pushed off the 420-decal list even sooner. Every blast on open ground now stamps the floor itself (scarStamp, gfx22): a
// scorch sized to the blast, 4 to 7 cracks running out of it and a scatter of debris, all shaped by a hash of where it went off.
// They stay for the whole raid and cost nothing a frame. A shell that bursts on a roof leaves nothing on the ground under it. The
// copies of a blast the other windows draw stamp their own floor the same way. Render only: no seeded draw.
function gfxBlastScar(x,y,size,onRoof){
  var k=(size>0)?size:1, n=0;
  if(onRoof||G.sim||!G.ground) return 0;
  if(scarStamp('scorch',x,y,{r:26*k})) n++;
  if(scarStamp('crack',x,y,{r:34*k})) n++;
  if(scarStamp('debris',x,y,{r:30*k})) n++;
  return n;
}
function explodeFrag(f){
'@

SubRx @'
  if(!G.sim){ try{ boomFx(f.x,f.y,1,'frag'); }catch(_gbx){} }   // v23.xx (gfx2): explosion hook
'@ @'
  if(!G.sim){ try{ boomFx(f.x,f.y,1,'frag'); }catch(_gbx){} }   // v23.xx (gfx2): explosion hook
  if(!G.sim){ try{ gfxBlastScar(f.x,f.y,1,false); }catch(_gbs){} }   // v23.xx (gfx26): and its scar on the floor
'@

SubRx @'
  if(!G.sim){ try{ boomFx(SH.tx,SH.ty,0.8,'howler'); }catch(_gbx){} }   // v23.xx (gfx2): explosion hook
'@ @'
  if(!G.sim){ try{ boomFx(SH.tx,SH.ty,0.8,'howler'); }catch(_gbx){} }   // v23.xx (gfx2): explosion hook
  if(!G.sim){ try{ gfxBlastScar(SH.tx,SH.ty,0.8,_onRoof); }catch(_gbs){} }   // v23.xx (gfx26): and its scar, unless it burst on a roof
'@

SubRx @'
  if(!G.sim){ spark(x,y,'#ff6a4a',28,320); decal(x,y,'#141210',fxn(16,24)); G.puffs.push({x:x,y:y,t:0,life:.5,c:'#ff8a5a',r:44}); }
'@ @'
  if(!G.sim){ spark(x,y,'#ff6a4a',28,320); decal(x,y,'#141210',fxn(16,24)); G.puffs.push({x:x,y:y,t:0,life:.5,c:'#ff8a5a',r:44}); }
  if(!G.sim){ try{ gfxBlastScar(x,y,0.9,false); }catch(_gbs){} }   // v23.xx (gfx26): the mine scars the floor too
'@

SubRx @'
      if(SH.fx){ if(!G.sim){ spark(SH.tx,SH.ty,'#ff9a5c',22,300); decal(SH.tx,SH.ty,'#181310',fxn(14,20)); G.puffs.push({x:SH.tx,y:SH.ty,t:0,life:.5,c:'#ff9a5c',r:40}); } G.shake=Math.max(G.shake,6); flash(SH.tx,SH.ty,220,'#ff9a5c',.4); if(!G.sim){ try{ boomFx(SH.tx,SH.ty,0.8,'howler'); }catch(_gbx){} } }   // a copy only shows the burst (v23.xx gfx2: and its explosion hook)
'@ @'
      if(SH.fx){ if(!G.sim){ spark(SH.tx,SH.ty,'#ff9a5c',22,300); decal(SH.tx,SH.ty,'#181310',fxn(14,20)); G.puffs.push({x:SH.tx,y:SH.ty,t:0,life:.5,c:'#ff9a5c',r:40}); } G.shake=Math.max(G.shake,6); flash(SH.tx,SH.ty,220,'#ff9a5c',.4); if(!G.sim){ try{ boomFx(SH.tx,SH.ty,0.8,'howler'); }catch(_gbx){} try{ gfxBlastScar(SH.tx,SH.ty,0.8,!!roofAt(SH.tx,SH.ty)); }catch(_gbs){} } }   // a copy only shows the burst (v23.xx gfx2: and its explosion hook)
'@

SubRx @'
      if(fr.fx){ if(!G.sim){ spark(fr.x,fr.y,'#ffcf7a',34,340); decal(fr.x,fr.y,'#141210',fxn(20,30)); G.puffs.push({x:fr.x,y:fr.y,t:0,life:.6,c:'#ffb267',r:52}); } G.shake=Math.max(G.shake,9); flash(fr.x,fr.y,310,'#ffb267',.45); if(!G.sim){ try{ boomFx(fr.x,fr.y,1,'frag'); }catch(_gbx){} } }   // a copy only shows the blast (v23.xx gfx2: and its explosion hook)
'@ @'
      if(fr.fx){ if(!G.sim){ spark(fr.x,fr.y,'#ffcf7a',34,340); decal(fr.x,fr.y,'#141210',fxn(20,30)); G.puffs.push({x:fr.x,y:fr.y,t:0,life:.6,c:'#ffb267',r:52}); } G.shake=Math.max(G.shake,9); flash(fr.x,fr.y,310,'#ffb267',.45); if(!G.sim){ try{ boomFx(fr.x,fr.y,1,'frag'); }catch(_gbx){} try{ gfxBlastScar(fr.x,fr.y,1,false); }catch(_gbs){} } }   // a copy only shows the blast (v23.xx gfx2: and its explosion hook)
'@

SubRx @'
var VER='24.38';
'@ @'
var VER='24.39';
'@

$pat = "(?m)^  now:'v24\.38:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.39: Frags, Howler shells and mines now burn a scorch with cracks and debris into the floor that stays all raid. Check 24.39 fails on v24.38',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
