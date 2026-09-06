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

# v11.55 CHECK, inserted before the v11.54 entry.
SubRx @'
  {v:'11.54',what:'an extraction point badge names one of his four states in his words (sound the alarm to begin countdown; N s until extraction begins; extract now, N s until it ends; closed for the remainder of this raid) with the live seconds, and the HUD draws that badge',
'@ @'
  {v:'11.55',what:'a cooked frag shouts COOKED GRENADE! THROW GRENADE NOW for its last second in hand, nothing else in hand shouts, and the HUD draws the shout (his notes of 2026-09-05)',
   run:function(){
     if(typeof cookShout!=='function') return 'there is no last-second shout for a cooked grenade';
     if(typeof drawHUD!=='function'||typeof FRAG_FUSE==='undefined') return 'SKIP: no HUD draw or no fuse in this build';
     var bad=[], line='COOKED GRENADE! THROW GRENADE NOW';
     var got1=cookShout({cooking:1,cookKind:'frag',cookT:FRAG_FUSE-0.5});
     if(got1!==line) bad.push('with half a second left in hand the shout is '+JSON.stringify(got1)+' and not the line');
     var got0=cookShout({cooking:1,cookKind:'frag',cookT:FRAG_FUSE-0.05});
     if(got0!==line) bad.push('at the last instant the shout is '+JSON.stringify(got0));
     if(FRAG_FUSE>1.5){
       var gotE=cookShout({cooking:1,cookKind:'frag',cookT:FRAG_FUSE-1.5});
       if(gotE!==null) bad.push('control: with 1.5 s left the shout already shows');
     }
     if(cookShout({cooking:1,cookKind:'smoke',cookT:5})!==null) bad.push('control: a smoke in hand shouts about a grenade');
     if(cookShout({cooking:0,cookKind:'frag',cookT:1})!==null) bad.push('control: an empty hand still shouts');
     var src=''; try{ src=drawHUD.toString(); }catch(_s){}
     if(src.indexOf('cookShout(')<0) bad.push('control: the HUD draw does not read cookShout, so the shout is never on screen');
     return bad.length?bad.join('; '):null; }},
  {v:'11.54',what:'an extraction point badge names one of his four states in his words (sound the alarm to begin countdown; N s until extraction begins; extract now, N s until it ends; closed for the remainder of this raid) with the live seconds, and the HUD draws that badge',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
