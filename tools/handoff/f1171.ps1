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

# v11.71 CHECK, inserted before the v11.70 entry.
SubRx @'
  {v:'11.70',what:'with Other pillagers set to None the extraction-heat row still reads its own word rather than CUSTOM, the waves are off, and they come back when pillagers return to Standard',
'@ @'
  {v:'11.71',what:'a click on the [+] glyph of a collapsed CURRENT PILLAGERS board expands the board and starts no resize',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame&&window.__mouse&&window.__canvases&&window.__P)) return 'SKIP: this fixture cannot click a panel';
     if(typeof HUDBOX==='undefined'||typeof hudOnGrip!=='function') return 'SKIP: no HUD panels in this build';
     var bad=[], prof, keepHud;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       prof=__P(); keepHud=JSON.stringify(prof.hud===undefined?null:prof.hud);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state();
       if(!g.roster||!g.roster.length) return 'SKIP: no pillager roster, so there is no board to fold';
       prof.hud=prof.hud||{}; prof.hud.raiders={c:true};
       __frame(); __frame();
       var HB=HUDBOX.raiders;
       if(!HB||!HB.tg) bad.push('control: the folded board drew no box or no glyph');
       else {
         var m=__mouse(), cv=__canvases().world;
         var x=Math.round(HB.tg.x+HB.tg.w/2), y=Math.round(HB.tg.y+HB.tg.h/2);
         // CONTROL: the glyph centre really sits inside the grip zone, or the click proves nothing.
         if(!hudOnGrip(HB,x,y)) return 'SKIP: the glyph centre is outside the grip zone at this size, so the clash cannot be driven here';
         m.x=x; m.y=y; m.down=false;
         cv.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,cancelable:true,clientX:x,clientY:y}));
         var rz=(typeof HUDRESIZE!=='undefined'&&HUDRESIZE)?HUDRESIZE.id:null;
         try{ window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true})); }catch(_u){}
         if(rz) bad.push('the click on [+] of the folded board started a resize of "'+rz+'"');
         if(prof.hud.raiders&&prof.hud.raiders.c) bad.push('the click on [+] did not expand the board');
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var kh=JSON.parse(keepHud); if(kh===null) delete prof.hud; else prof.hud=kh; }catch(_h){}
       try{ HUDRESIZE=null; }catch(_z){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'11.70',what:'with Other pillagers set to None the extraction-heat row still reads its own word rather than CUSTOM, the waves are off, and they come back when pillagers return to Standard',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
