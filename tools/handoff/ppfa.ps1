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

# The title and mode menu use the shared UI look (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    --t-small:500 13px/1.4 var(--f-body); --t-num-xl:700 48px/1 var(--f-cond); --t-num:600 18px/1 var(--f-cond);
  }

'@ @'
    --t-small:500 13px/1.4 var(--f-body); --t-num-xl:700 48px/1 var(--f-cond); --t-num:600 18px/1 var(--f-cond);
    /* v28.xx (cw-uishared-title), his order 2026-10-18 (UI step 2, one shared look): the style guide as tokens. FIVE type sizes, an 8px
       space grid, one radius, one scrim, the button heights. UIT in the script is the same table; the check keeps them equal. */
    --fs-hero:56px; --fs-title:32px; --fs-body:20px; --fs-label:16px; --fs-fine:14px;
    --sp-1:8px; --sp-2:16px; --sp-3:24px; --sp-4:32px; --sp-5:48px; --rad:4px; --scrim:rgba(6,7,8,.80); --track:.04em;
    --btn-h:56px; --btn-h-sm:48px; --btn-h-xs:40px; --menu-w:560px; --acc-hover:#f7c25a; --acc-press:#dfa52f;
  }
'@

SubRx @'
</style>

'@ @'
</style>
<style id="ui-shared">
/* v28.xx (cw-uishared-title), his order 2026-10-18 (UI step 2): THE SHARED LOOK. Every rule in this block reads the tokens at :root
   (--fs-*, --sp-*, --rad, --ui-*, --tx-*, --acc*): no hex, no rgba, no font-size in px. A screen moved onto the shared look gets its
   selectors added here, and the check "ui-shared has no raw literals" keeps it honest. Title and mode menu (screens 01, 57) first. */
#root .ui-panel, #root #title .tcard{ box-sizing:border-box; background:var(--ui-panel); background-image:none; border:1px solid var(--ui-line-hi); border-radius:var(--rad); box-shadow:none; padding:var(--sp-2); }
#root .ui-hd{ font:700 var(--fs-title)/1.1 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); }
#root #title .titlecol [style*="font-size"]{ font-size:var(--fs-label) !important; letter-spacing:var(--track) !important; line-height:1.5 !important; }
#root #title .titlecol > div[style*="margin-top"]{ margin-top:var(--sp-2) !important; }
#root #title .titlecol > .wordmark + div[style]{ margin-top:var(--sp-1) !important; }
#root #title #titleres{ margin-top:var(--sp-1) !important; }
#root #title #titlefs{ min-height:var(--btn-h-xs); padding:0 var(--sp-2) !important; border-radius:var(--rad); font:600 var(--fs-label)/1 var(--f-cond) !important; }
#root #title .tstep{ font:700 var(--fs-label)/1.2 var(--f-cond); letter-spacing:var(--track); color:var(--tx-1); }
#root #title .tcard .tbody{ font:400 var(--fs-label)/1.4 var(--f-body); letter-spacing:0; color:var(--tx-2); margin-top:var(--sp-1); }
#root #title #modemenu{ gap:var(--sp-1); margin-top:var(--sp-3) !important; }
#root #title #modemenu button.moderow{ box-sizing:border-box; min-width:var(--menu-w); min-height:var(--btn-h-sm); padding:0 var(--sp-4); border-radius:var(--rad); background:var(--ui-panel); border:1px solid var(--ui-line-hi); color:var(--tx-1); font:600 var(--fs-body)/1 var(--f-cond) !important; letter-spacing:var(--track) !important; box-shadow:none; }
#root #title #modemenu button.moderow:hover:not(:disabled){ background:var(--ui-hover); border-color:var(--tx-2); }
#root #title #modemenu button.moderow:disabled{ opacity:.4; }
#root #title #modemenu #titlestart{ min-height:var(--btn-h); padding:0 var(--sp-5) !important; background:var(--acc); border-color:var(--acc); color:var(--acc-ink); font-weight:700 !important; }
#root #title #modemenu #titlestart:hover:not(:disabled){ background:var(--acc-hover); border-color:var(--acc-hover); }
#root #title #modemenu #titlestart:active:not(:disabled){ background:var(--acc-press); }
#root #title #modemenu.haspick #titlestart{ background:var(--ui-panel); border-color:var(--ui-line-hi); color:var(--tx-1); }
#root #title #modemenu.haspick #titlestart:hover:not(:disabled){ background:var(--ui-hover); border-color:var(--tx-2); }
#root #title #modemenu button.moderow.picked{ background:var(--ui-raised); border-color:var(--acc); color:var(--tx-1); box-shadow:inset 3px 0 0 var(--acc); }
#root #title #modemenu .modelater button.moderow{ min-height:var(--btn-h-xs); font-size:var(--fs-label) !important; }
#root #title #modemenu .modelater span{ right:var(--sp-2); padding:0 var(--sp-1); border:1px solid var(--ui-line); border-radius:var(--rad); font:600 var(--fs-label)/1.5 var(--f-cond); letter-spacing:var(--track); color:var(--tx-2); }
#root #title #slotpanel > div:first-child{ color:var(--tx-2) !important; }
#root #title #slotpanel button, #root #title #pnamein{ min-height:var(--btn-h-xs); border-radius:var(--rad) !important; font:600 var(--fs-label)/1 var(--f-cond) !important; }
</style>
'@

SubRx @'
  special:UIC.r_elite, plate:'rgba(6,9,13,.78)', dangerPlate:'rgba(40,8,6,.84)', ink:INK};

'@ @'
  special:UIC.r_elite, plate:'rgba(6,9,13,.78)', dangerPlate:'rgba(40,8,6,.84)', ink:INK};
// v28.xx (cw-uishared-title), his order 2026-10-18 (UI step 2, one shared look): UIT is the style guide as ONE table (the same numbers as
// the :root tokens --fs-*, --sp-*, --rad; the check keeps them equal). uiFont(role,z) is the type of a role at a screen scale z, uiPanel
// is Panel P on a canvas (fill --ui-panel at 90 percent, a 1px --ui-line-hi border, --rad, an optional 3px accent bar). The DOM side is
// the CSS block <style id="ui-shared">; the HUD side keeps hudPlate/hudText, whose colours already come from UIC.
var UIT={fs:{hero:56,title:32,body:20,label:16,fine:14}, sp:{1:8,2:16,3:24,4:32,5:48}, rad:4, scrim:0.8, track:0.04, btn:{h:56,hs:48,hx:40}};
function uiFont(role,z){
  var r=UIT.fs[role]?role:'body', w={hero:800,title:700,body:600,label:600,fine:500}[r];
  return w+' '+Math.round(UIT.fs[r]*((z>0)?z:1)*100)/100+'px '+((r==='fine')?HUDFB:HUDF);
}
function uiPanel(c,x,y,w,h,accent){
  if(!(w>0&&h>0)) return;
  var r=Math.max(0,Math.min(UIT.rad,h/2,w/2));
  c.save();
  c.beginPath();
  if(c.roundRect) c.roundRect(x+0.5,y+0.5,w-1,h-1,r);
  else { c.moveTo(x+r,y); c.arcTo(x+w,y,x+w,y+h,r); c.arcTo(x+w,y+h,x,y+h,r); c.arcTo(x,y+h,x,y,r); c.arcTo(x,y,x+w,y,r); c.closePath(); }
  c.globalAlpha=0.9; c.fillStyle=UIC.ui_panel; c.fill();
  c.globalAlpha=1; c.lineWidth=1; c.strokeStyle=UIC.ui_line_hi; c.stroke();
  if(accent){ c.fillStyle=accent; c.fillRect(x,y+r,3,h-r*2); }
  c.restore();
}

'@

SubRx @'
var VER='29.31';
'@ @'
var VER='29.32';
'@

$pat = "(?m)^  now:'v29\.31:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.32: The title screen and mode menu now share one set of sizes, spacing and colors. Check 29.32 fails on v29.31',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
