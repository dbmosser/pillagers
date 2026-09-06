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

# CHECK 11.52 double-scaled the CONDITIONS box top (HUDBOX.cond is already in
# screen pixels after hudZoomRect), so it was too permissive by the zoom and
# could not see an overlap; the v11.78 check reads the same field the right
# way and the two disagreed.
SubRx @'
       // CLEAR OF THE CONDITIONS BOX, in screen space: that box is drawn zoomed
       // about the top right corner, so its top in pixels is y times its zoom.
       var HB=(typeof HUDBOX!=='undefined')?HUDBOX.cond:null, r=rect();
       if(!HB) bad.push('control: the CONDITIONS box was not drawn, so the clearance cannot be measured');
       else {
         var cz=1; try{ cz=(HUDZ.cond||1)*hudRes()*hudUserZ('cond'); }catch(_z){ cz=1; }
         var condTop=HB.y*cz;
'@ @'
       // CLEAR OF THE CONDITIONS BOX, in screen space. v12.19: HUDBOX.cond is
       // already in screen pixels (drawHUD runs it through hudZoomRect), so it is
       // read as it is; multiplying by the zoom again made this too permissive.
       var HB=(typeof HUDBOX!=='undefined')?HUDBOX.cond:null, r=rect();
       if(!HB) bad.push('control: the CONDITIONS box was not drawn, so the clearance cannot be measured');
       else {
         var condTop=HB.y;
'@

# v12.19 CHECK, inserted before the v12.18 entry. The shop window is opened
# for real and its heading balance measured against the corner readout.
SubRx @'
  {v:'12.18',what:'the crafting bench tells the truth about its guns: one green and three blue by the rarity every other screen shows, the detail panel describes a gun as a gun with its shown rarity, and the stash says servos and optics are kept for guns and contracts (2026-09-06 review of v11.79)',
'@ @'
  {v:'12.19',what:'a station window no longer repeats the credits and XP in its heading under the corner readout: the heading balance is hidden or clear of the readout (2026-09-06 review of v11.78)',
   run:function(){
     if(typeof openTrader!=='function'||!window.__hubEnter) return 'SKIP: this fixture cannot open a station window';
     if(!window.innerWidth||!window.innerHeight) return 'SKIP: the pane is 0x0, nothing here can be measured';
     var bad=[], tr=document.getElementById('topright');
     if(!tr) return 'SKIP: no corner readout in this build';
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ if(window.__forceSize) __forceSize(1920,1080); }catch(_fs){}   // the modal zoom follows the pane; pinned so the control means the same on every run
       G=null; keys={}; __showScreen('hub'); __hubEnter(); saveProfile();
       openTrader('buy');
       var md=document.querySelector('.modal.on'); if(!md) bad.push('control: no station window opened');
       var mc=md?md.querySelector('h3 .modcur'):null;
       if(!mc) bad.push('control: the window heading carries no balance to measure');
       else {
         var shown=getComputedStyle(mc).display!=='none';
         var a=mc.getBoundingClientRect(), b=tr.getBoundingClientRect();
         var hit=shown&&a.width>0&&a.right>b.left&&a.left<b.right&&a.bottom>b.top&&a.top<b.bottom;
         if(hit) bad.push('the heading balance ('+Math.round(a.left)+'..'+Math.round(a.right)+' x '+Math.round(a.top)+'..'+Math.round(a.bottom)+') sits under the corner readout ('+Math.round(b.left)+'..'+Math.round(b.right)+' x '+Math.round(b.top)+'..'+Math.round(b.bottom)+')');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ try{ var ms=document.querySelectorAll('.modal.on'); for(var i=0;i<ms.length;i++) ms[i].classList.remove('on'); }catch(_c){} __topClear(); __cleanProfile(); }
     return bad.length?bad.join('; '):null; }},
  {v:'12.18',what:'the crafting bench tells the truth about its guns: one green and three blue by the rarity every other screen shows, the detail panel describes a gun as a gun with its shown rarity, and the stash says servos and optics are kept for guns and contracts (2026-09-06 review of v11.79)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
