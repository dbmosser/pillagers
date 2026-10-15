$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'27.59',what:")) { throw "check 27.59 is in the fixture already" }

SubRx @'
  {v:'27.58',what:
'@ @'
  {v:'27.59',what:'cloud-menus-enter-skips-haul: ENTER on the EXTRACTED card skips the haul reveal and leaves the card up, and ENTER typed in the note box does not',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof haulRevealing!=='function'||typeof haulRevealSkip!=='function'||typeof HAUL_REV==='undefined') return 'SKIP: no haul reveal in this fixture';
     var P2=__P(), snap=JSON.parse(JSON.stringify(P2)), cfg=JSON.parse(JSON.stringify(CFG)), bad=[], oSfx=sfx, k, oc, note, ev, hid0, rest;
     function key(el,code,type){ var e=new KeyboardEvent(type||'keydown',{code:code,key:'Enter',bubbles:true,cancelable:true}); el.dispatchEvent(e); return e; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       G.player.iv=99; G.bag=['scrap','board','optic','servo','core','medkit','wire','cell'];
       sfx=function(){};
       __endRaid('extract');
       oc=document.getElementById('outcome');
       if(!oc||!oc.classList.contains('on')) return 'SKIP: staging: no EXTRACTED card';
       if(!haulRevealing()) return 'SKIP: staging: the haul did not start revealing';
       HAUL_REV.t=1e6;
       hid0=HAUL_REV.list.length-HAUL_REV.i;
       // ONE: ENTER typed in the note box stays in the note box
       note=document.getElementById('oc_note');
       if(note){ note.focus(); key(note,'Enter'); key(note,'Enter','keyup'); note.blur(); if(!haulRevealing()) return 'ONE: ENTER typed in the note box skipped the haul reveal'; }
       // TWO: ENTER with the focus on the page skips the reveal and the card stays
       if(document.activeElement&&document.activeElement.blur) document.activeElement.blur();
       ev=key(document.body,'Enter'); key(document.body,'Enter','keyup');
       if(haulRevealing()) bad.push('TWO: ENTER did not skip the haul reveal ('+(HAUL_REV.list.length-HAUL_REV.i)+' of '+hid0+' items still hidden)');
       if(!oc.classList.contains('on')) bad.push('TWO: ENTER closed the card');
       if(!G||!G.over) bad.push('TWO: the raid left its end');
       rest=HAUL_REV?HAUL_REV.list.length-HAUL_REV.i:0;
       if(rest>0) bad.push('TWO: '+rest+' items still hidden');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       sfx=oSfx; HAUL_REV=null; keys={};
       try{ for(k in P2) if(!(k in snap)) delete P2[k]; for(k in snap) P2[k]=snap[k]; saveProfile(); }catch(_r){}
       try{ for(k in CFG) if(!(k in cfg)) delete CFG[k]; for(k in cfg) CFG[k]=cfg[k]; }catch(_g){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'27.58',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
