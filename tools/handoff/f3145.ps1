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

if ($s.Contains("  {v:'31.45',what:")) { throw "check 31.45 is in the fixture already" }

SubRx @'
  {v:'31.44',what:
'@ @'
  {v:'31.45',what:'cw-inihead: the initials card is drawn with its heading: a 2 player card says whose turn it is (player 1, then player 2) and that it is the initials, a 1 player card says top 10 tonight and the initials, and the heading is the first line of the card above the three letters and the hint (a line comment swallowed the statement that adds it from v30.36 on, so the card showed the letters and the hint only)',
   run:function(){
     if(typeof arcadeIniDraw!=='function'||typeof ARCADE!=='object'||!ARCADE) return 'SKIP: no initials card in this build';
     var bad=[], solo0=ARCADE.solo, c, h, t, k;
     function draw(who){ c=document.createElement('div'); arcadeIniDraw(c,{l:['A','B','C'],pos:1,who:who}); h=c.querySelector('.aoi'); return h?String(h.textContent||''):''; }
     try{
       // ONE: two players, player 1's turn and then player 2's
       ARCADE.solo=0;
       t=draw(1); if(!t) bad.push('ONE: the card has no heading for player 1'); else if(!/player 1/i.test(t)||!/enter initials/i.test(t)) bad.push('ONE: the player 1 heading reads "'+t+'"');
       t=draw(2); if(!t) bad.push('TWO: the card has no heading for player 2'); else if(!/player 2/i.test(t)||!/enter initials/i.test(t)) bad.push('TWO: the player 2 heading reads "'+t+'"');
       // THREE: one player: what the letters are for
       ARCADE.solo=1;
       t=draw(1); if(!t) bad.push('THREE: the 1 player card has no heading'); else if(!/top 10 tonight/i.test(t)||!/enter initials/i.test(t)) bad.push('THREE: the 1 player heading reads "'+t+'"');
       // FOUR: the heading is the first line, then the three letters, then the hint
       ARCADE.solo=0; draw(1);
       k=[].map.call(c.children,function(e){ return e.className; }).join(',');
       if(k!=='aoi,aol,aoq') bad.push('FOUR: the card is drawn as ['+k+'], not the heading, the letters and the hint (aoi,aol,aoq)');
       else if(c.querySelector('.aol').children.length!==3) bad.push('FOUR: the card does not draw three letters');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ ARCADE.solo=solo0; }catch(_s){} }
     return bad.length?bad.join('; '):null; }},
  {v:'31.44',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
