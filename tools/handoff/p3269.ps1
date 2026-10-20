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

# NAMED STASH READABILITY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      <!-- v28.xx (cw-cx-padname), J4: the stash identifies the save by the name entered on the title. --><div class="brand"><span id="stashname">pillager</span> <span id="verlabel"></span></div>
'@ @'
      <!-- v28.xx (cw-cx-namestashview), J4 critic: identify the screen and show the actual save name in the shared menu font. --><div class="brand">stash <span class="stashsep" aria-hidden="true">/</span> <span id="stashname">pillager</span> <span id="verlabel"></span></div>
'@

SubRx @'
  function detailIdle(){
    if(detail) detail.innerHTML='<span style="color:var(--tx-2)">'+((typeof netHubSeat==='function'&&netHubSeat()>=0)?('Drop on the floor for '+(netSeatName(netHubSeat())||'your teammate')+'. '):'')+'Hover an item and press J to tag it JUNK. '+
      ''+   /* v28.xx (cw-uc-stash2): Q8, the parts line was an explaining sentence on the stash help row (reason in notes/ui/changes.md) */
      '</span>';
  }
'@ @'
  function detailIdle(){
    if(detail)detail.textContent=''; // v28.xx (cw-cx-namestashview): Q8, the idle keyboard sentence duplicated the controls; focused item details still use this row.
  }
'@

SubRx @'
</style><canvas id="cv"></canvas>
'@ @'
/* v28.xx (cw-cx-namestashview), J4 critic 10-20: the saved name uses the menu font, one neutral freebie row and a readable pad legend. No inventory control or slot is removed. */
#root #hub .toprow .brand{font:700 34.8px/1.2 var(--f-cond)!important;letter-spacing:.04em;color:var(--tx-1)!important;display:flex;align-items:baseline;gap:16px;}
#root #hub .toprow #stashname,#root #hub .toprow .stashsep{font:600 21.8px/1.2 var(--f-cond)!important;letter-spacing:.02em;color:var(--tx-2)!important;}
#root #hub #stashdetail:empty,#root #hub #nextunlock:empty{display:none!important;}
#root #hub .panel>div:has(>#sellall){border-top:0!important;padding:0!important;}
#root #hub #hubfreekit .fkbox{background:var(--ui-panel)!important;border:1px solid var(--ui-line-hi)!important;border-left:3px solid var(--acc)!important;padding:12px 16px;margin:8px 0 0;gap:24px;}
#root #hub #hubfreekit .fkbox>span{display:none!important;}
#root #hub #hubfreekit .fkbox>b{font:600 21.8px/1.2 var(--f-cond)!important;color:var(--tx-1)!important;letter-spacing:.04em;flex:1;}
#root #hub #hubfreekit .fkbtn{min-height:52.2px;padding:8px 24px;background:var(--acc)!important;color:var(--acc-ink)!important;border:0!important;font:600 21.8px/1.2 var(--f-cond)!important;}
#root #hub #invkeybarpad div,#root #hub #invkeybarpad kbd{font-size:17.4px!important;letter-spacing:.02em;line-height:1.4;}
#root #hub #kitsetup .kst span,#root #hub #kitsetup .kstc span,#root #hub #kitsetup .ksreset{font-size:18px!important;letter-spacing:0!important;}
/* v28.xx (cw-cx-namestashview): the shared style guide keeps toast notices out of open windows, as Settings and Keys already do. */
body:has(#hub.on) #hubtoast{visibility:hidden;}
</style><canvas id="cv"></canvas>
'@

SubRx @'
var VER='32.68';
'@ @'
var VER='32.69';
'@

$pat = "(?m)^  now:'v32\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.69: The stash heading shows the save name in the shared font. One neutral freebie row keeps a filled action, and focused items keep their details. Check 32.69 fails on v32.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
