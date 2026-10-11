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

# A DOWNED TEAMMATE SHOWS DOWN AND [E] REVIVE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var nc2=G.nearContainer;
'@ @'
  // v22.68, the raid text rewrite (R26): A DOWNED TEAMMATE SHOWS [E] REVIVE. Holding E beside a downed teammate picks him up (v16.05,
  // within NET_REV_R), but nothing over him said so: a downed pillager got [E] REVIVE NAME with his seconds, a teammate only his name.
  // Within reach, the teammate E would pick up (netMateDown, the same test netRevHold uses) gets the same prompt as the pillager:
  // [E] REVIVE NAME and the seconds his word says he has left. It is drawn only when promptPick says E acts on him (R25). The bleed
  // clock is read from his word, never written.
  if(_pk==='mate'){
    (function(){
      var ms=-1, mg=null, j, sp, hs;
      try{ ms=netMateDown(p); }catch(_e){ ms=-1; }
      for(j=0;j<NET.up.length;j++) if(NET.up[j]&&NET.up[j].seat===ms){ mg=NET.up[j]; break; }
      if(!mg) return;
      sp=w2s(mg.x,26,mg.y); hs=hudAtIn(sp.x,sp.y);
      hudPrompt('['+keyLabel('KeyE','E')+'] REVIVE '+String(netSeatName(ms)||'PILLAGER').toUpperCase()+((mg.dt>0)?('  \u00b7  '+mg.dt+'s'):''),sp.x,sp.y);
      ctx.textAlign='left';
      if(hs) ctx.restore();
    })();
  }
  var nc2=G.nearContainer;
'@

SubRx @'
      wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x-tw/2,g.y-52);
'@ @'
      wc.fillStyle='#ffc04a'; wc.fillText(nm,g.x-tw/2,g.y-52);
      // v22.68, the raid text rewrite (R26): a teammate who is down says so over his head, DOWN and the seconds his word says he
      // has left, in danger red on a danger plate above his name, seen from anywhere on screen. Read from his word, never written.
      if(g.dn){
        var dl='DOWN'+((g.dt>0)?('  \u00b7  '+g.dt+'s'):''), dw=wc.measureText(dl).width;
        wc.fillStyle='rgba(40,8,6,.86)'; wc.fillRect(g.x-dw/2-4,g.y-77,dw+8,13);
        wc.fillStyle='#ff5a4a'; wc.fillText(dl,g.x-dw/2,g.y-67);
      }
'@

SubRx @'
var VER='22.67';
'@ @'
var VER='22.68';
'@

$pat = "(?m)^  now:'v22\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.68: A downed teammate shows DOWN with his seconds, and within reach [E] REVIVE with his name. Check 22.68 fails on v22.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
