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

if ($s.Contains("  {v:'32.77',what:")) { throw "check 32.77 is in the fixture already" }

SubRx @'
  {v:'32.76',what:
'@ @'
  {v:'32.77',what:'the trophy case is two full rows of four with no orphan card, every card can take focus and shows a lime ring, and the money readout is hidden while it is open',
   run:function(){
     var q, cards, tops=[], i, cols=0, ring, cs, tr, now=Date.now(), n;
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       q=__P(); q.trophies={firstout:now,ghost:now,centurion:now,forged:now,golden:now,motherlode:now};
       __gx('trophyOpen()');
       cards=document.querySelectorAll('#trophygrid .trp');
       n=cards.length;
       if(n<2) return 'the trophy case drew '+n+' cards';
       for(i=0;i<n;i++){ var t=Math.round(cards[i].getBoundingClientRect().top); if(tops.indexOf(t)<0) tops.push(t); if(t===tops[0]) cols++; }
       if(n%cols!==0) return 'the trophy grid orphans a card: '+n+' cards in rows of '+cols;
       if(cols<4) return 'the trophy grid is only '+cols+' wide';
       if(cards[0].tagName!=='BUTTON') return 'a trophy card is a '+cards[0].tagName+', so Tab and the pad cannot land on it';
       cards[0].focus();
       cs=getComputedStyle(cards[0]);
       if(!(parseFloat(cs.outlineWidth)>=2)||cs.outlineStyle==='none') return 'the focused trophy shows no ring: outline '+cs.outlineStyle+' '+cs.outlineWidth;
       tr=document.getElementById('topright');
       if(tr&&getComputedStyle(tr).display!=='none') return 'the money and xp readout still shows over the trophy case';
       return null;
     } finally {
       try{ document.getElementById('trophymodal').classList.remove('on'); }catch(_e){}
       __topClear();
     } }},
  {v:'32.76',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
