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

# A PROBLEM-REPORT TEXT BOX IN THE PAUSE MENU (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    <!-- v24.50, his answer 38: FEEDBACK, a typed note and a screenshot of this moment (the note box above is replaced by it) -->
    <button id="fbbtn" style="padding:8px 22px">FEEDBACK</button>

'@ @'
    <!-- v28.xx (cw-pausefb), HIS Q9 (2026-10-18): "A text box in the pause menu, or chat. Both carry the same weight". A problem-report box right in the pause menu, above the Feedback button. Typed text + the Feedback button saves it exactly like the Feedback window does (fbSave: note, version, time, where, screenshot). Q61: the feedback line, the button and Send play data stay. -->
    <textarea id="pausefb" rows="2" maxlength="1000" placeholder="Report a problem" aria-label="Report a problem"></textarea>
    <!-- v24.50, his answer 38: FEEDBACK, a typed note and a screenshot of this moment (empty box: the window; text typed: sends it) -->
    <button id="fbbtn" style="padding:8px 22px">Feedback</button>

'@

SubRx @'
  var out=[],q=root.querySelectorAll('button,.cell,.vcell,.crow,.invtab,.scard,.vpill,.sectorpick,input,select,[data-plan],.imenurow:not(.dim),[data-slot],.costile,.avslot,.tag,.kst');

'@ @'
  var out=[],q=root.querySelectorAll('button,.cell,.vcell,.crow,.invtab,.scard,.vpill,.sectorpick,input,select,[data-plan],.imenurow:not(.dim),[data-slot],.costile,.avslot,.tag,.kst,#pausefb');   // v28.xx (cw-pausefb): the pause menu problem box

'@

SubRx @'
document.getElementById('fbbtn').onclick=function(){ fbOpen(); };

'@ @'
// v28.xx (cw-pausefb), HIS Q9 (2026-10-18): "A text box in the pause menu, or chat. Both carry the same weight". The pause menu has its own problem box
// (#pausefb). With text in it the Feedback button reads Send feedback and saves the note through fbSave, with a screenshot of the world as it stands and
// the version, exactly like the Feedback window; with the box empty the button opens that window as before. CTRL+ENTER in the box sends too; ESC shuts the
// pause menu as ever. Landing: on this PC through the collector into exports\feedback-STAMP.txt and .png, elsewhere the browser's downloads as
// pillagers_feedback_STAMP.txt and .png, and in an itch page the note is copied.
function pauseFbLabel(){
  var ta=document.getElementById('pausefb'), b=document.getElementById('fbbtn');
  if(b) b.textContent=(ta&&String(ta.value||'').trim())?'Send feedback':'Feedback';
}
function pauseFbSend(){
  var ta=document.getElementById('pausefb'), t=ta?String(ta.value||'').trim():'', png;
  if(!t) return false;
  png=fbShot();
  ta.value=''; try{ ta.blur(); }catch(_b){}
  pauseFbLabel();
  fbSave(t.slice(0,1000),png);
  return true;
}
document.getElementById('fbbtn').onclick=function(){ if(!pauseFbSend()) fbOpen(); };
(function(){
  var ta=document.getElementById('pausefb');
  if(!ta) return;
  ta.addEventListener('input',pauseFbLabel);
  ta.addEventListener('click',function(){ try{ ta.focus(); }catch(_f){} });   // a pad A is a click
  ta.addEventListener('keydown',function(e){
    if((e.ctrlKey||e.metaKey)&&(e.code==='Enter'||e.code==='NumpadEnter')){ e.preventDefault(); document.getElementById('fbbtn').click(); }
  });
})();

'@

SubRx @'
    var _ta=document.getElementById('pausenote'); if(_ta) _ta.blur();

'@ @'
    var _ta=document.getElementById('pausenote'); if(_ta) _ta.blur();
    var _tf=document.getElementById('pausefb'); if(_tf) _tf.blur();   // v28.xx (cw-pausefb)

'@

SubRx @'
</style><canvas id="cv"></canvas>

'@ @'
/* v28.xx (cw-pausefb) HIS Q9: a problem box in the pause menu. Full column width (560), 72px high (two lines of 20px), 16px inner padding, the panel fill and a 1px line like the buttons, amber edge on focus; hidden while Abandon asks. */
#root #pausebox #pausefb{ box-sizing:border-box; width:100%; height:calc(var(--btn-h) + var(--sp-2)); min-height:0; resize:none; padding:var(--sp-1) var(--sp-2); border:1px solid var(--ui-line-hi); border-radius:var(--rad); background:var(--ui-panel); color:var(--tx-1); font:400 var(--fs-body)/1.3 var(--f-body); letter-spacing:0; text-transform:none; margin:0; }
#root #pausebox #pausefb::placeholder{ color:var(--tx-3); opacity:1; }
#root #pausebox #pausefb:focus{ outline:none; border-color:var(--acc); }
#root #pausebox.asking #pausefb{ display:none !important; }
</style><canvas id="cv"></canvas>

'@

SubRx @'
var VER='30.36';
'@ @'
var VER='30.37';
'@

$pat = "(?m)^  now:'v30\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.37: The pause menu has a Report a problem box. Type, press Send feedback, and the note goes out with a screenshot and the version. Check 30.37 fails on v30.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
