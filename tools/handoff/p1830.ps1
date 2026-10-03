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

# DRAG TO DROP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    // v9.31, HIS 11: LET GO ANYWHERE ELSE AND IT COMES OFF THE BELT. The other
'@ @'
    // v18.30, HIS ORDER (2026-10-03, "drag to drop should work also"): A BACKPACK ITEM LET GO OUTSIDE THE PANEL IS DROPPED. Not on
    // the belt (that is a bind), not on your hire (that is a gift above), not inside the panel (that is the click it always was):
    // anywhere else on the screen, the item is a pile at your feet, as Z makes.
    if(!dropped&&G&&!G.over&&d&&d.key&&d.bagIx!==undefined&&d.fromHot===undefined&&!_onBelt&&G.bagPanel&&
       !(mouse.x>=G.bagPanel.x&&mouse.x<=G.bagPanel.x+G.bagPanel.w&&mouse.y>=G.bagPanel.y&&mouse.y<=G.bagPanel.y+G.bagPanel.h)){
      var _dbi=(G.bag[d.bagIx]===d.key)?d.bagIx:G.bag.indexOf(d.key), _ddk;
      if(_dbi>=0){ _ddk=dropItem(_dbi); if(_ddk){ say('Dropped '+ITEMS[_ddk].name+((typeof NET==='object'&&NET&&NET.on)?'. Your teammate can search it.':'')); blip('clank'); dropped=true; } }
    }
    // v9.31, HIS 11: LET GO ANYWHERE ELSE AND IT COMES OFF THE BELT. The other
'@

SubRx @'
        <div><kbd>1-9</kbd> bind to key</div>
      </div>
'@ @'
        <div><kbd>1-9</kbd> bind to key</div>
      </div>
      <!-- v18.30, HIS ORDER (2026-10-03): DRAG TO DROP. A target for the floor, shown while the windows are linked. -->
      <div id="floordrop" data-drop="floor" style="display:none;margin:6px 12px 0;padding:8px 12px;border:1px dashed var(--amber);border-radius:6px;font-size:11px;color:var(--ash);align-items:center;gap:10px">
        <button id="floordropbtn" style="padding:5px 12px;font-size:11px;letter-spacing:.14em">DROP HERE</button>
        <span>Drag an item here (on a controller, pick it up with A and press A here) to drop it on the floor for <b id="floordropwho" style="color:var(--bone)">your teammate</b>.</span>
      </div>
'@

SubRx @'
  dropzone(document.getElementById('stashgrid'),function(key,from){
'@ @'
  dropzone(document.getElementById('floordrop'),function(key,from){ if(from==='rack'){ say2('Put the gun in the stash first.'); return; } if(from==='kit'){ try{ unpackSome(key,1); }catch(_u){} } hubDropMake(key); });   // v18.30: drag to the floor
  (function(){ var _fb=document.getElementById('floordropbtn'); if(_fb&&!_fb.onclick) _fb.onclick=function(){ say2('Drag an item onto DROP HERE, or pick one up with A and press A here.'); }; })();
  dropzone(document.getElementById('stashgrid'),function(key,from){
'@

SubRx @'
  try{ var _kt=document.getElementById('kb_trade'); if(_kt) _kt.style.display=(typeof netHubSeat==='function'&&netHubSeat()>=0)?'':'none'; }catch(_kte){}   // v18.17: the offer line shows while the windows are linked
'@ @'
  try{ var _kt=document.getElementById('kb_trade'); if(_kt) _kt.style.display=(typeof netHubSeat==='function'&&netHubSeat()>=0)?'':'none'; }catch(_kte){}   // v18.17: the offer line shows while the windows are linked
  try{ var _fd=document.getElementById('floordrop'), _fon=(typeof netHubSeat==='function'&&netHubSeat()>=0); if(_fd) _fd.style.display=_fon?'flex':'none'; var _fw=document.getElementById('floordropwho'); if(_fw&&_fon) _fw.textContent=netSeatName(netHubSeat())||'your teammate'; }catch(_fde){}   // v18.30: the floor target shows while linked
'@

SubRx @'
        <div id="kb_trade" style="display:none"><kbd>RIGHT CLICK</kbd> or <kbd>Y</kbd> drop on the floor for your teammate</div>
'@ @'
        <div id="kb_trade" style="display:none"><kbd>RIGHT CLICK</kbd>, <kbd>Y</kbd> or drag to DROP HERE: drop on the floor for your teammate</div>
'@

SubRx @'
var VER='18.29';
'@ @'
var VER='18.30';
'@

$pat = "(?m)^  now:'v18\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.30: You can drag an item out of the backpack to drop it, and drag a stash item onto DROP HERE to put it on the Undercroft floor. Check 18.30 fails on v18.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
