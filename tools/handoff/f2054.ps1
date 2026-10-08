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

if ($s.Contains("  {v:'20.54',what:")) { throw "check 20.54 is in the fixture already" }

SubRx @'
  {v:'20.53',what:
'@ @'
  {v:'20.54',what:'a restore code waits for the Undercroft: in a raid REPLACE leaves the save alone and arms no reload, even for a code read before the raid, and READ CODE does not ask for the word; and a code applied in the Undercroft drops the armoury guns and the dead hire a raid left noted, so the reload settles nothing onto the restored character',
   run:function(){
     if(!(window.__deploy&&window.__endRaid&&window.__state)) return 'SKIP: this fixture cannot deploy';
     if(typeof restoreCode!=='function'||typeof restoreRead!=='function'||typeof restoreApply!=='function'||typeof applyLoadedProfile!=='function'||typeof saveProfile!=='function'||typeof MERC_DEATH!=='number') return 'SKIP: no restore code here';
     function el(id){ return document.getElementById(id); }
     if(!el('resread')||!el('resgo')||!el('rescode')||!el('resword')||!el('resconfirm')||!el('resno')) return 'SKIP: no restore code panel in this page';
     var bad=[], keep=null, BK=(typeof RESTORE_BACKUP_KEY!=='undefined')?RESTORE_BACKUP_KEY:(SKEY+':prerestore'), keepBk=null, o=null, code='', gx=null, k, cfm=el('resconfirm'), ow;
     try{ keepBk=localStorage.getItem(BK); }catch(_k){}
     try{
       __topClear(); __runPrep(); __cleanProfile();
       if(typeof G!=='undefined'&&G&&!G.over&&!G.sim) return 'SKIP: a raid is already running';
       keep=JSON.parse(JSON.stringify(P));
       P.pname='ZQXCODE35'; P.credits=5151;
       code=restoreCode(); o=restoreRead(code);
       if(!code||!o) return 'SKIP: no restore code could be made';
       P.pname='ZQXHOLD35'; P.credits=2929;
       // ONE: read in the Undercroft, so the box asks for the word; then the raid starts with the box still waiting.
       try{ el('resno').click(); }catch(_n0){}
       el('rescode').value=code; el('resread').click();
       if(cfm.style.display==='none') return 'SKIP: staging: the code did not read in the Undercroft';
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(!G||G.over||!G.player) return 'SKIP: staging: no raid';
       try{ clearTimeout(RESTORE_TIMER); }catch(_t0){} RESTORE_RELOAD=0;
       el('resword').value='restore'; el('resgo').click();
       if(P.pname!=='ZQXHOLD35') bad.push('REPLACE in a raid put the code character ('+P.pname+') in place of the one playing');
       if(RESTORE_RELOAD) bad.push('REPLACE in a raid armed the reload that throws the raid away');
       try{ clearTimeout(RESTORE_TIMER); RESTORE_RELOAD=0; }catch(_t){}
       // TWO: READ CODE in a raid does not open the box that asks for the word.
       try{ el('resno').click(); }catch(_n1){}
       el('rescode').value=code; el('resread').click();
       if(cfm.style.display!=='none') bad.push('READ CODE in a raid opened the box that asks for the word');
       try{ el('resno').click(); }catch(_n2){}
       try{ if(G&&!G.over){ G.player.downed=false; __endRaid('abandon'); } }catch(_e1){}
       __topClear();
       // THREE: in the Undercroft, with a raid's armoury gun and dead hire still noted, the code replaces the save, then the page reloads.
       ow=(o.g&&o.g.w)?o.g.w:[];
       for(k in WEAPONS) if(k!=='fists'&&WEAPONS[k]&&ow.indexOf(k)<0){ gx=k; break; }
       if(!gx) return bad.length?bad.join('; '):'SKIP: staging: no gun the code character lacks';
       P.raidSpliced=[gx]; P.mercOut={dead:1};
       if(restoreApply(o)!==true) return bad.length?bad.join('; '):'SKIP: restoreApply refused a code made a moment ago';
       applyLoadedProfile({value:JSON.stringify(P)});
       if(P.credits!==5151) bad.push('after a code for a character with 5151 credits the reload left '+P.credits+', billing him a hire he never had');
       if((P.weapons||[]).indexOf(gx)>=0) bad.push('after the code the reload gave the restored character the armoury gun ('+gx+') the replaced character carried up');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ clearTimeout(RESTORE_TIMER); RESTORE_RELOAD=0; }catch(_t2){}
       try{ if(keepBk===null) localStorage.removeItem(BK); else localStorage.setItem(BK,keepBk); }catch(_b){}
       try{ el('resno').click(); }catch(_n3){}
       try{ el('rescode').value=''; el('resword').value=''; var rw=el('reswhat'); if(rw) rw.textContent=''; }catch(_v){}
       try{ if(typeof G!=='undefined'&&G&&!G.over){ G.player.downed=false; __endRaid('abandon'); } }catch(_e2){}
       try{ if(keep) applyLoadedProfile({value:JSON.stringify(keep)}); saveProfile(); }catch(_p){}
       try{ __topClear(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.53',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
