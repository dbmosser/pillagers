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

# ============ HIS NOTE 15: WEIRD EYE COLLISIONS ON UNDERCROFT FACES.
# ============
# ============ "pillagers in the undercroft still have weird eye collissions on
# ============ trhier faces in some instances", 2026-09-04.
# ============
# ============ SOME INSTANCES cannot be answered by looking at the crowd, which
# ============ is eight people out of tens of thousands of possible looks, so it
# ============ was answered by enumeration. Every look the crowd can roll was
# ============ drawn alone, nine times raid size, and the eye was measured: the
# ============ two eye ellipses were located from their own whites, and every
# ============ other rack was then asked how much of that area it paints over.
# ============
# ============ MEASURED. Four of the six face marks paint nothing on the eye.
# ============ The other two paint over most of it:
# ============   facepaint    66 percent of the eye area
# ============   faceshiner   51 percent, which is one whole eye
# ============ The paint is two thin bars straight across both eyeballs, so each
# ============ eye reads as a white sliver above a white sliver. The shiner is an
# ============ ellipse centred exactly on the right eye and slightly larger than
# ============ it, so the eyeball is washed purple. Both are collisions in his
# ============ word: a mark landing ON the eye rather than on the face.
# ============
# ============ THE FIX IS THE ORDER, not the artwork. A mark is on the SKIN and
# ============ an eye is not skin, so the marks are painted BEFORE the eyes and
# ============ the eye goes on top of them. War paint still crosses the face and
# ============ a shiner still bruises the socket; neither is drawn over the
# ============ eyeball any more. Nothing moves, nothing is recoloured, and no
# ============ rack loses a look.
SubRx @'
  // eyes: whites, pupils toward the aim, one specular dot each
  var pupX=Math.cos(face)*1.4,pupY=Math.sin(face)*0.9;
'@ @'
  // v10.94, HIS NOTE: THE FACE MARKS GO ON FIRST. They used to be painted after
  // the eyes, so war paint cut both eyeballs in half and a shiner washed one of
  // them purple. A mark is on the skin; an eye is not skin.
  // v10.21: the FACE rack. The hero face comes from the racks; a pillager one
  // from his look, or from the old index if he has none.
  {
    var _FACE=OUTF?'faceplain':(HERO?cosWorn('face'):(st.faceMark||null));   // faceMark, never face: e.face is the facing angle; v10.54: none under a suit
    var _fx=st.faceIx===undefined?0:st.faceIx;
    if(_FACE){ _fx={faceplain:0,facescar:6,facefreckles:5,facemud:4,facepaint:7,faceshiner:8}[_FACE]||0; }
    if(_fx===6){ wc.fillStyle='#a04a3a'; wc.fillRect(hx2+6.2,ty-32.0,1.1,6.2); wc.fillStyle='#d47a6a'; wc.fillRect(hx2+6.2,ty-29.0,1.1,1); }   // v10.50: outside the eye (hx2+5.9)
    else if(_fx===7){ wc.fillStyle='rgba(20,22,30,.75)'; wc.fillRect(hx2-7,ty-31.6,14,1.6); wc.fillStyle='rgba(200,40,40,.8)'; wc.fillRect(hx2-7,ty-29.6,14,1.4); }
    else if(_fx===8){ wc.fillStyle='rgba(70,40,90,.55)'; wc.beginPath(); wc.ellipse(hx2+3.4,ty-29.5,3.2,3.6,0,0,6.2832); wc.fill(); }
    if(_fx===1){ wc.fillStyle=INK; wc.fillRect(hx2-5.6,ty-33.4,4.4,1.1); wc.fillRect(hx2+1.2,ty-33.4,4.4,1.1); }
    else if(_fx===2){ wc.fillStyle=INK; wc.fillRect(hx2-5.6,ty-33.0,4.4,1.1); wc.fillRect(hx2+1.2,ty-33.8,4.4,1.1); }
    else if(_fx===3){ wc.fillStyle=INK; wc.fillRect(hx2-5.8,ty-32.8,4.8,0.9); wc.fillRect(hx2+1.0,ty-32.8,4.8,0.9); }
    else if(_fx===4){ wc.fillStyle='rgba(40,32,28,.30)'; rrF(hx2-6.4,ty-26.4,12.8,4.6,2.6); }   // v10.50: below the eye band
    else if(_fx===5){ wc.fillStyle='rgba(150,90,60,.55)';   // v10.50: on the cheeks, clear of the eye band (ty-26.5)
      wc.fillRect(hx2-5.8,ty-26.0,1,1); wc.fillRect(hx2-3.6,ty-25.4,1,1);
      wc.fillRect(hx2+2.8,ty-26.0,1,1); wc.fillRect(hx2+4.8,ty-25.4,1,1); }
  }
  // eyes: whites, pupils toward the aim, one specular dot each
  var pupX=Math.cos(face)*1.4,pupY=Math.sin(face)*0.9;
'@

# ---- and the old copy goes, or the marks would be painted twice, the second
# ---- time back over the eyes, which is the bug with an extra step.
SubRx @'
  // v10.21: the FACE rack. The hero's face comes from the racks; a pillager's
  // from his look, or from the old index if he has none.
  {
    var _FACE=OUTF?'faceplain':(HERO?cosWorn('face'):(st.faceMark||null));   // faceMark, never face: e.face is the facing angle; v10.54: none under a suit
    var _fx=st.faceIx===undefined?0:st.faceIx;
    if(_FACE){ _fx={faceplain:0,facescar:6,facefreckles:5,facemud:4,facepaint:7,faceshiner:8}[_FACE]||0; }
    if(_fx===6){ wc.fillStyle='#a04a3a'; wc.fillRect(hx2+6.2,ty-32.0,1.1,6.2); wc.fillStyle='#d47a6a'; wc.fillRect(hx2+6.2,ty-29.0,1.1,1); }   // v10.50: outside the eye (hx2+5.9)
    else if(_fx===7){ wc.fillStyle='rgba(20,22,30,.75)'; wc.fillRect(hx2-7,ty-31.6,14,1.6); wc.fillStyle='rgba(200,40,40,.8)'; wc.fillRect(hx2-7,ty-29.6,14,1.4); }
    else if(_fx===8){ wc.fillStyle='rgba(70,40,90,.55)'; wc.beginPath(); wc.ellipse(hx2+3.4,ty-29.5,3.2,3.6,0,0,6.2832); wc.fill(); }
    if(_fx===1){ wc.fillStyle=INK; wc.fillRect(hx2-5.6,ty-33.4,4.4,1.1); wc.fillRect(hx2+1.2,ty-33.4,4.4,1.1); }
    else if(_fx===2){ wc.fillStyle=INK; wc.fillRect(hx2-5.6,ty-33.0,4.4,1.1); wc.fillRect(hx2+1.2,ty-33.8,4.4,1.1); }
    else if(_fx===3){ wc.fillStyle=INK; wc.fillRect(hx2-5.8,ty-32.8,4.8,0.9); wc.fillRect(hx2+1.0,ty-32.8,4.8,0.9); }
    else if(_fx===4){ wc.fillStyle='rgba(40,32,28,.30)'; rrF(hx2-6.4,ty-26.4,12.8,4.6,2.6); }   // v10.50: below the eye band
    else if(_fx===5){ wc.fillStyle='rgba(150,90,60,.55)';   // v10.50: on the cheeks, clear of the eye band (ty-26.5)
      wc.fillRect(hx2-5.8,ty-26.0,1,1); wc.fillRect(hx2-3.6,ty-25.4,1,1);
      wc.fillRect(hx2+2.8,ty-26.0,1,1); wc.fillRect(hx2+4.8,ty-25.4,1,1); }
  }
  if(HERO){
'@ @'
  // v10.94: the face marks used to be painted here, over the eyes. They are
  // painted before them now, a dozen lines above.
  if(HERO){
'@

SubRx @'
var VER='10.93';
'@ @'
var VER='10.94';
'@
SubRx @'
  now:'v10.93: the text in the Undercroft, your note. The station names were painted into the world BEFORE the room darkness went over it, so they kept 60 percent of an already see-through 75 percent. They are drawn on top of the darkness now, opaque, on a firm plate. And the station with the racks is called FASHION everywhere.',
'@ @'
  now:'v10.94: the eye collisions on Undercroft faces, your note. Enumerated every look the crowd can roll: four of the six face marks are clean, war paint covered 66 percent of the eye area with two bars straight across both eyeballs, and the shiner covered 51 percent, which is one whole eye. A mark is on the skin and an eye is not skin, so the marks are painted before the eyes now.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'FACES DO NOT COLLIDE WITH THEIR OWN EYES. War paint was two bars straight across both eyeballs and the shiner was a purple wash over one of them. Face marks are painted before the eyes now, so paint goes on the skin and the eye sits on top of it, which is where an eye goes.',
'@
SubRx @'
var WHATSNEW_VER='10.93';
'@ @'
var WHATSNEW_VER='10.94';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
