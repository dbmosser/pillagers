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

# ONE LIME TAB ON THE RAID HUD, A SHORTER DEMO GUN CARD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hudPanel(x,y,w,h,a){
'@ @'
// v28.xx (cw-hudstar), the critic (2026-10-19) on the raid HUD: 'the lime tick on every panel spends the accent'. The style guide gives the 2px tab to the panel that is the star (the gun card, the ammo). Every other raid panel passes plain=1 and draws no tab.
function hudPanel(x,y,w,h,a,plain){
'@

SubRx @'
  if(w>c+20){ ctx.fillStyle='#e6ff3d'; ctx.fillRect(x+c+4,y,Math.min(36,w*0.25),2); }   // the amber tick of the menu plate (ui6)
'@ @'
  if(w>c+20&&!plain){ ctx.fillStyle='#e6ff3d'; ctx.fillRect(x+c+4,y,Math.min(36,w*0.25),2); }   // the tab of the menu plate (ui6); v28.xx (cw-hudstar): only where plain is not set
'@

SubRx @'
hudPanel(x-_ux,y-_ut,w+_ux*2,h+_uh,0.78)
'@ @'
hudPanel(x-_ux,y-_ut,w+_ux*2,h+_uh,0.78,1)
'@

SubRx @'
hudPanel(bx,by,bw,bh);   // v18.13: the one HUD panel
'@ @'
hudPanel(bx,by,bw,bh,undefined,1);   // v18.13: the one HUD panel
'@

SubRx @'
hudPanel(W-8-cw2-16*_cr2,_cyb-LH(20)*_cr2,cw2+16*_cr2,LH(20)*_cr2,0.78)
'@ @'
hudPanel(W-8-cw2-16*_cr2,_cyb-LH(20)*_cr2,cw2+16*_cr2,LH(20)*_cr2,0.78,1)
'@

SubRx @'
hudPanel(18,by-_up-LH(18),_pw+14,LH(16),0.78)
'@ @'
hudPanel(18,by-_up-LH(18),_pw+14,LH(16),0.78,1)
'@

SubRx @'
hudPanel(PADX-8,y0-LH(13),LW,boxH);   // v18.13: the one HUD panel
'@ @'
hudPanel(PADX-8,y0-LH(13),LW,boxH,undefined,1);   // v18.13: the one HUD panel
'@

SubRx @'
hudPanel(x0,y0,PW,PH,0.93)
'@ @'
hudPanel(x0,y0,PW,PH,0.93,1)
'@

SubRx @'
hudPanel(mx-8,my-6,MW,MH+10);   // v18.13: the one HUD panel
'@ @'
hudPanel(mx-8,my-6,MW,MH+10,undefined,1);   // v18.13: the one HUD panel
'@

SubRx @'
hudPanel(x-8,top-6,LEGW,boxH+10,0.84)
'@ @'
hudPanel(x-8,top-6,LEGW,boxH+10,0.84,1)
'@

SubRx @'
       if(_wpw>LH(60)) hudPanel(_wpx,by-LH(90),_wpw,LH(100),0.62);
'@ @'
       /* v28.xx (cw-hudstar): the demo hides the item line and the backpack hint (Q56), so the card is 72 high and not 100 with an empty strip; it keeps the tab, it is the star */
       if(_wpw>LH(60)){ var _gtop=trDemo()?LH(76):LH(90), _gh=trDemo()?LH(72):LH(100); hudPanel(_wpx,by-_gtop,_wpw,_gh,0.62); }
'@

SubRx @'
var VER='30.72';
'@ @'
var VER='30.73';
'@

$pat = "(?m)^  now:'v30\.72:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.73: Only the gun card keeps its lime tab, and in the demo it is shorter. Check 30.73 fails on v30.72',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
