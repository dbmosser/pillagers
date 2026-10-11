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

# CHATTER LINES IN CAPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
            if(!G.sim&&chatNear(z.x,z.y)) say(e.name+' called extraction.');   // v22.xx (R35): only near or in sight
'@ @'
            // v22.89 (tr7fixa), the review of raid text batch 7: HIS ORDER (2026-10-09), a raid line is a short caps callout of at most 34
            // characters. A pillager calling near you said NAME called extraction. as a sentence; it is PILLAGER CALLED EXTRACTION with
            // his name and the ring as the detail (the name stays out of the headline: the longest tag, 20 letters, would take it past 34).
            if(!G.sim&&chatNear(z.x,z.y)) say('PILLAGER CALLED EXTRACTION','info',{sub:String(e.name)+', Extraction '+extLetter(z)});   // v22.83 (R35): only near or in sight
'@

SubRx @'
          if(chatNear(_sz.x,_sz.y)) say('The survivor made it to Extraction '+extLetter(_sz)+'.');   // v22.xx (R35): only near or in sight
'@ @'
          if(chatNear(_sz.x,_sz.y)) say('SURVIVOR EXTRACTED','info',{sub:'Extraction '+extLetter(_sz)});   // v22.xx (R35): only near or in sight   // v22.89 (tr7fixa): the caps callout, the ring as the detail
'@

SubRx @'
            if(!G.sim&&chatNear(e.x,e.y)) say('The Peddler has set up shop here.','chat');   // v22.xx (R35): only near or in sight
'@ @'
            if(!G.sim&&chatNear(e.x,e.y)) say('THE PEDDLER SET UP SHOP','chat');   // v22.xx (R35): only near or in sight   // v22.89 (tr7fixa): the caps callout
'@

SubRx @'
          if(!G.sim&&chatNear(e.x,e.y)) say('The Peddler is back at his pitch.','chat');   // v22.xx (R35): only near or in sight
'@ @'
          if(!G.sim&&chatNear(e.x,e.y)) say('THE PEDDLER IS BACK','chat');   // v22.xx (R35): only near or in sight   // v22.89 (tr7fixa): the caps callout
'@

SubRx @'
            say(e.name+(e.standing>0?' nods at you.':' is watching you.'),'chat');   // v22.xx (R35): chat
'@ @'
            say(String(e.name).toUpperCase()+(e.standing>0?' IS FRIENDLY':' IS WATCHING'),'chat');   // v22.xx (R35): chat   // v22.89 (tr7fixa): the caps callout, within 34 with the longest tag
'@

SubRx @'
                  say(CW.k==='deer'?'The deer goes down.':'You shot a bird.','chat');   // v22.xx (R35): chat
'@ @'
                  say(CW.k==='deer'?'DEER DOWN':'BIRD DOWN','chat');   // v22.xx (R35): chat   // v22.89 (tr7fixa): the caps callout
'@

SubRx @'
      if(!buzzDoses(_tg)) sayAny(_tg==='drunk'?'The liquor wears off.':'The colours drain away.','chat');   // v22.xx (R35): chat
'@ @'
      if(!buzzDoses(_tg)) sayAny(_tg==='drunk'?'LIQUOR WORE OFF':'BLOTTER WORE OFF','chat');   // v22.xx (R35): chat   // v22.89 (tr7fixa): the caps callout, by the item name
'@

SubRx @'
    if(!DRS.said){ DRS.said=1; try{ sayWhenFree('RESOLUTION STEPPED DOWN','sys',{sub:'Running slowly. Auto resolution in Settings.'}); }catch(_ds){} }   // v22.xx (R36): a system row in caps
'@ @'
    if(!DRS.said){ DRS.said=1; try{ sayWhenFree('RESOLUTION STEPPED DOWN','sys',{sub:'Settings: Auto resolution'}); }catch(_ds){} }   // v22.xx (R36): a system row in caps   // v22.89 (tr7fixa): a short detail, not a sentence
'@

SubRx @'
  if(slow*2>PERF.win.length){ PERF.said=1; try{ sayWhenFree('RUNNING SLOWLY','sys',{sub:'Lower Render resolution or Effects in Settings.'}); }catch(_ps){} return true; }   // v22.xx (R36): a system row in caps
'@ @'
  if(slow*2>PERF.win.length){ PERF.said=1; try{ sayWhenFree('RUNNING SLOWLY','sys',{sub:'Settings: Render resolution, Effects'}); }catch(_ps){} return true; }   // v22.xx (R36): a system row in caps   // v22.89 (tr7fixa): a short detail, not a sentence
'@

SubRx @'
          if(chatNear(e.x,e.y)) say('SOMEONE SHOT THE SURVIVOR','chat',{sub:'Not on you.'});   // v22.81 (tr6fixc): the caps callout, a chat row as the raid text plan has it; v22.xx (R35): only near or in sight
'@ @'
          if(chatNear(e.x,e.y)) say('SOMEONE SHOT THE SURVIVOR','chat',{sub:'Not your kill'});   // v22.81 (tr6fixc): the caps callout, a chat row as the raid text plan has it; v22.xx (R35): only near or in sight   // v22.89 (tr7fixa): a short detail, not a sentence
'@

SubRx @'
          if(chatNear(e.x,e.y)) say('THE PEDDLER IS DEAD','chat',{sub:'Someone else did that.'});   // v22.81 (tr6fixc): the caps callout, a chat row; v22.xx (R35): only near or in sight
'@ @'
          if(chatNear(e.x,e.y)) say('THE PEDDLER IS DEAD','chat',{sub:'Not your kill'});   // v22.81 (tr6fixc): the caps callout, a chat row; v22.xx (R35): only near or in sight   // v22.89 (tr7fixa): a short detail, not a sentence
'@

SubRx @'
var VER='22.88';
'@ @'
var VER='22.89';
'@

$pat = "(?m)^  now:'v22\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.89: The chatter lines read as short caps callouts, such as THE PEDDLER IS BACK and LIQUOR WORE OFF. Check 22.89 fails on v22.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
