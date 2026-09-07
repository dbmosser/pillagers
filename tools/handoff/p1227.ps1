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

# THE v12.13 NOT-VERIFIED LINE, verified by reading at v12.21: taking the
# freebie kit keeps the packing AND the belt plan aside (P.kitSaved, v12.16),
# but commitKit, at the lift, takes only the packing out of it (P.kitBeforeFree)
# and throws the rest away, and the end of a free run that is not a clean
# extraction (v6.88) puts only the packing back. So a friend who packs, binds
# a key or two, takes the free kit for a first look, and dies, comes home to
# his packing with every key gone and the gun slot cleared. commitKit now
# keeps the plan and the gun slot beside the packing (a separate field, so a
# save from before this build still reads), and the end of the run restores
# them with the packing and drops any key whose item did not come back.
SubRx @'
    P.kitBeforeFree=((P.kitSaved&&P.kitSaved.kit)||P.kit||[]).slice(); P.kitSaved=null;
'@ @'
    P.kitBeforeFree=((P.kitSaved&&P.kitSaved.kit)||P.kit||[]).slice();
    // v12.27: THE BELT PLAN AND THE GUN SLOT GO ASIDE WITH THE PACKING. The
    // kept-aside record already held them (v12.16); this took only the list.
    P.planBeforeFree=P.kitSaved?{hot:JSON.parse(JSON.stringify(P.kitSaved.hot||{})),gun:P.kitSaved.gun||null}:null;
    P.kitSaved=null;
'@
SubRx @'
      P.kit=_kb;
      if(_kb.length) lines.push('<span style="color:var(--coolant)">'+_kb.length+' item'+(_kb.length===1?'':'s')+
        ' that you had in your loadout before choosing the freebie kit '+(_kb.length===1?'has':'have')+' been restored.</span>');
    }
    P.kitBeforeFree=null;
  }
'@ @'
      P.kit=_kb;
      if(_kb.length) lines.push('<span style="color:var(--coolant)">'+_kb.length+' item'+(_kb.length===1?'':'s')+
        ' that you had in your loadout before choosing the freebie kit '+(_kb.length===1?'has':'have')+' been restored.</span>');
    }
    P.kitBeforeFree=null;
  }
  // v12.27: AND THE BELT PLAN COMES BACK WITH IT, on the same rule (v6.88: any
  // end that is not a clean extraction), then any key whose item did not come
  // back is dropped, the same as USE MY OWN GEAR does (v12.16).
  if(P.planBeforeFree){
    if(how!=='extract'){
      P.hotAssign=P.planBeforeFree.hot||{}; P._gunSlot=P.planBeforeFree.gun||null;
      try{ dropDeadKeys(); }catch(_pk){}
    }
    P.planBeforeFree=null;
  }
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'A FREE-KIT RUN THAT ENDS BADLY GIVES YOU BACK YOUR TACTICAL BELT KEYS with your packing, not just the packing.',
'@

# STAMPS.
SubRx @'
var VER='12.26';
'@ @'
var VER='12.27';
'@
SubRx @'
var WHATSNEW_VER='12.26';
'@ @'
var WHATSNEW_VER='12.27';
'@
$cnt=([regex]::Matches($s,"now:'v12\.26:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.26 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.26:[^']*'",{ param($m) "now:'v12.27: the v12.13 not-verified line: the freebie kit kept the packing and the belt plan aside, but the lift took only the packing into the raid and the end of a free run put only the packing back, so a friend who bound keys, took the free kit and died came home with every key gone. The plan and the gun slot go aside with the packing and come back with it, dead keys dropped. Check 12.27 takes the kit with a key bound, commits it, ends the raid dead and requires the key back; an extraction restores nothing, as before; fails on v12.26.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
