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

# READABLE CAPTURE TITLE AND RECORDING BADGE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  document.head.appendChild(st);
  var d=document.createElement('div'); d.id='attract';
'@ @'
  // v28.xx (cw-cx-capturechrome): recorded labels cannot show through the title or wake prompt; the arcade keeps its own page layout.
  st.textContent+='body #attract[data-capture-playback="1"]{background:var(--ui-void)}'+
    'body #attract[data-capture-playback="1"] .attname{left:50%;right:auto;top:5%;width:max-content;max-width:90vw;min-width:6em;box-sizing:border-box;transform:translateX(-50%);padding:.28em .7em;background:var(--ui-void);border:1px solid var(--ui-line-hi);border-radius:var(--rad);font-size:clamp(56px,5.185185vh,224px);text-shadow:none;opacity:1}'+
    'body #attract[data-capture-playback="1"] .attpress{left:50%;right:auto;bottom:12%;width:max-content;max-width:90vw;box-sizing:border-box;transform:translateX(-50%);padding:.25em .75em;background:var(--ui-void);border:1px solid var(--ui-line-hi);border-radius:var(--rad);font-size:clamp(32px,2.962963vh,128px);text-shadow:none}';
  document.head.appendChild(st);
  var d=document.createElement('div'); d.id='attract';
'@

SubRx @'
  var arcade=!!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on);
  var ap=d.querySelector('.attpress'); if(ap&&!arcade) ap.textContent=padOn()?'press any button':'press any key';
'@ @'
  var arcade=!!(typeof ARCADE==='object'&&ARCADE&&ARCADE.on);
  d.setAttribute('data-capture-playback',arcade?'0':'1'); // v28.xx (cw-cx-capturechrome): only the recorded-footage view gets these backplates.
  var ap=d.querySelector('.attpress'); if(ap&&!arcade) ap.textContent=padOn()?'press any button':'press any key';
'@

SubRx @'
  if(ATT.el){ ATT.el.style.display='none'; try{ var v=ATT.el.querySelector('video'); v.onplaying=v.onended=v.onerror=v.onwaiting=v.onstalled=null; v.pause(); v.removeAttribute('src'); v.load(); v.style.visibility=''; }catch(e){} }
'@ @'
  if(ATT.el){ ATT.el.style.display='none'; ATT.el.removeAttribute('data-capture-playback'); try{ var v=ATT.el.querySelector('video'); v.onplaying=v.onended=v.onerror=v.onwaiting=v.onstalled=null; v.pause(); v.removeAttribute('src'); v.load(); v.style.visibility=''; }catch(e){} }
'@

SubRx @'
    REC.mark.style.cssText='position:fixed;left:14px;top:14px;z-index:9001;display:none;padding:4px 10px 4px 8px;border-radius:999px;background:rgba(0,0,0,.6);'+
      'color:#ff5a4a;font:800 15px var(--f-cond);letter-spacing:.1em;pointer-events:none';
'@ @'
    // v28.xx (cw-cx-capturechrome): the elapsed badge keeps its 20px reading size at 1080p and 40px at 4K.
    REC.mark.style.cssText='position:fixed;left:clamp(24px,2.222222vh,96px);top:clamp(24px,2.222222vh,96px);z-index:9001;display:none;padding:.4em .8em;border:1px solid var(--ui-line-hi);border-radius:var(--rad);background:var(--ui-panel);'+
      'color:#ff5a4a;font:700 clamp(20px,1.851852vh,80px) var(--f-cond);letter-spacing:var(--track);pointer-events:none';
'@

SubRx @'
var VER='36.59';
'@ @'
var VER='36.60';
'@

$pat = "(?m)^  now:'v36\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.60: Recorded footage has opaque title and prompt backplates, a higher 32px prompt and a recording badge that scales from 20px to 40px between 1080p and 4K. LOCAL: no linked review. Check 36.60 fails on v36.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
