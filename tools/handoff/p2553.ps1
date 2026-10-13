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

# CAREER PAYOUT: SCORE X2 IN CREDITS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // THE SEAL banks only if you walk out. Thirty seconds of cutting and a death
'@ @'
  try{ careerSettle(how,lines); }catch(_cst){}   // v24.xx (feat0i): the CAREER score, paid only on an extraction
  // THE SEAL banks only if you walk out. Thirty seconds of cutting and a death
'@

SubRx @'
function careerPostBuild(g){
'@ @'
// v24.xx (feat0i), HIS MODE DESIGN AND ANSWERS (2026-10-12): "somehow the score converts to credits that you can spend in the
// undercroft", "extraction gives 2x bonus to score", and his answers: 1 score = 1 credit, banked ONLY when you extract (the score is
// doubled first), and CAREER keeps its own personal-best board. THE CAREER PAYOUT. An extraction doubles the raid score and pays it
// into his Undercroft credits, and the KIA / EXTRACTED card reads CAREER SCORE $N x2 and +N CR. A banked run goes on his CAREER board
// in his save (P.careerBoard, the top 10 by score, with his save name, the kills, the map and the time) and a new top reads CAREER
// BEST. A death or an abandon banks nothing (SCORE LOST) and the board is not touched. The loot he brings out goes to the stash as
// items only, as before, and never counts in the score. Each window settles its own player into its own save.
var CAREER_BOARD_N=10;
function careerSettle(how,lines){
  if(!G||!G.career||G.sim||!G.cs) return 0;
  if(typeof G.careerPaid==='number') return G.careerPaid;
  var s=Math.max(0,G.cs.s|0), fin=0, B, best=false, rk=0, i, row;
  if(how==='extract'){
    fin=s*2;
    P.credits=(+P.credits||0)+fin;
    if(fin>0){
      B=P.careerBoard=Array.isArray(P.careerBoard)?P.careerBoard:[];
      row={s:fin,k:G.cs.k|0,m:P.mapIx|0,t:Date.now(),n:String(P.pname||'').slice(0,16)};
      B.push(row); B.sort(function(a,b){ return ((b.s|0)-(a.s|0))||((a.t|0)-(b.t|0)); });
      if(B.length>CAREER_BOARD_N) B.length=CAREER_BOARD_N;
      for(i=0;i<B.length;i++) if(B[i]===row){ rk=i+1; break; }
      best=(rk===1);
      if(best) P.careerBest=fin;
    }
    if(lines){
      lines.push('<span style="color:#ffc04a;font-weight:700">CAREER SCORE '+arcadeCr(s)+' x2  \u00b7  +'+arcadeN(fin)+' CR</span>');
      if(best) lines.push('<span style="color:#ffc04a;font-weight:700">CAREER BEST</span>');
      else if(rk>0) lines.push('<span style="color:#ffc04a">CAREER BOARD #'+rk+'</span>');
    }
  } else if(lines&&s>0) lines.push('<span style="color:var(--rust);font-weight:700">SCORE LOST  \u00b7  '+arcadeCr(s)+'</span>');
  G.careerPaid=fin;
  return fin;
}
function careerPostBuild(g){
'@

SubRx @'
var VER='25.52';
'@ @'
var VER='25.53';
'@

$pat = "(?m)^  now:'v25\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.53: Extracting from a CAREER raid pays your score x2 in credits and puts the run on your CAREER board. Check 25.53 fails on v25.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
