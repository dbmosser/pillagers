$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
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
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null;
'@ @'
    // v15.66, stealth audit finding: PILLAGERS SEE A DOWNED OR ROLLING PLAYER AT THEIR NORMAL RANGE. The stance the sight rules
    // read, G.pCrouch with G.pBush and G.pConceal, is written only at the bottom of updatePlayer, below the downed return, and
    // nothing here cleared it, so a man shot down while crouched stayed crouched to every pillager for the whole bleed-out. The
    // hard crouch rule in updateEnts then hid the body from anything past 170: no pillager out there could build his aim or fire,
    // so the 3 seconds of bleed each hit on the floor costs never came, while a man downed standing at the same spot was shot as
    // intended. Machines are blinded to a downed man by their own rule on purpose; pillagers are meant to see him. Going down now
    // takes the crouch toggle off and clears the crouched flag, and the downed branch keeps the stance fresh every frame (the sim
    // bot already reads a downed man as not crouched). No number, dial or seeded draw moved.
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null; G.crouchTog=false; G.pCrouch=false;
'@
SubRx @'
    if(mg0>0){ p.x+=(mx0/mg0)*30*dt; p.y+=(my0/mg0)*30*dt; collide(p,G.map.walls); }
'@ @'
    if(mg0>0){ p.x+=(mx0/mg0)*30*dt; p.y+=(my0/mg0)*30*dt; collide(p,G.map.walls); }
    // v15.66, stealth audit finding: PILLAGERS SEE A DOWNED OR ROLLING PLAYER AT THEIR NORMAL RANGE. This branch returns before
    // the three lines at the bottom of updatePlayer that write the stance the sight rules read, so the bush, the crouch and the
    // concealment of his last standing frame stood for the whole bleed-out and through every crawl: crouched in a bush he stayed
    // concealed at the crouched value of every sight range while lying there, and the plate read HIDDEN, CROUCHED under the red
    // wash. A man on the floor is not crouching. The three are written here every frame as a man lying still or crawling, the
    // way updateBot already reads its own downed frames. No number, dial or seeded draw moved.
    G.pBush=inBush(p.x,p.y); G.pCrouch=false; G.pConceal=concealAt(p.x,p.y,mg0>0,false,false);
'@
SubRx @'
  G.crouchTog=false;   // v11.53, HIS NOTE: "rolling should automatically stop crouching"
'@ @'
  // v15.66, stealth audit finding: PILLAGERS SEE A DOWNED OR ROLLING PLAYER AT THEIR NORMAL RANGE. This line took the toggle
  // off, but the crouched flag the sight rules read is written only below the roll return in updatePlayer, so for the whole
  // 0.38s of a roll out of a crouch he still counted as crouched: hidden from every pillager past 170 and the HIDDEN plate on
  // screen while the status read ROLLING, though his note says the roll leaves the crouch. The flag and the concealment now
  // leave the crouch with the toggle, as a man moving on his feet. No number, dial or seeded draw moved.
  G.crouchTog=false; G.pCrouch=false; G.pConceal=concealAt(p.x,p.y,true,false,false);   // v11.53, HIS NOTE: "rolling should automatically stop crouching"
'@
SubRx @'
var VER='15.65';
'@ @'
var VER='15.66';
'@

$pat = "(?m)^  now:'v15\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.66: PILLAGERS SEE A DOWNED OR ROLLING PLAYER AT THEIR NORMAL RANGE. Shot down while crouched, the body stayed crouched to every pillager for the whole bleed-out, so nothing past 170 could see it or shoot it, and a roll out of a crouch hid him the same way until the roll ended. Going down and rolling now leave the crouch, and on the floor the body is seen and concealed as a man lying there. Check 15.66 stands one hostile pillager 200 away and watches him take aim at a player shot down from a crouch and rolling out of one, with standing, crouched and downed standing controls; it fails on v15.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
