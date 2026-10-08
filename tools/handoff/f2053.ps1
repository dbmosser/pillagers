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

if ($s.Contains("  {v:'20.53',what:")) { throw "check 20.53 is in the fixture already" }

SubRx @'
  {v:'20.52',what:
'@ @'
  {v:'20.53',what:'with the backpack highlight on the belt row, Z, controller Y, T and Enter leave the unmarked backpack stack alone and say where the highlight is',
   run:function(){
     if(!window.__deploy||!window.__endRaid||typeof NET!=='object'||!NET||typeof bagDropSel!=='function'||typeof raidKey!=='function'||typeof netGiftKey!=='function'||typeof bagStacks!=='function') return 'SKIP: no raid or backpack here';
     if(!ITEMS.bloom||!ITEMS.gun_lance) return 'SKIP: the test items are gone';
     var NK={}, k, bad=[], oSay=say, oSeat=netGiftSeat, oSend=netGiftSend, lines=[], sent=[], g, p, S, iB=-1, iG=-1, i, w0, ha0;
     for(k in NET) NK[k]=NET[k];
     try{
       NET.on=false; NET.role=null; NET.peers=[];
       __topClear(); __runPrep(); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player) return 'SKIP: staging: no raid';
       p=g.player;
       say=function(m){ lines.push(String(m)); };
       ha0=g.hotAssign; g.hotAssign={};
       g.bag=['bloom','gun_lance']; g.bagOpen=true; g.paused=false; g.drag=null; g.giftIn=null; g.giftOut=null; g.mapOpen=false;
       S=bagStacks(); for(i=0;i<S.length;i++){ if(S[i].key==='bloom') iB=i; if(S[i].key==='gun_lance') iG=i; }
       if(iB<0||iG<0) return 'SKIP: staging: the two test stacks are not in the backpack';
       w0=p.wep?p.wep.id:null;
       g.bagBelt=true; g.bagBeltSel=0;
       g.bagSel=iB; lines=[]; raidKey('KeyZ',false,null); keys['KeyZ']=false;
       if(g.bag.indexOf('bloom')<0) bad.push('Z with the highlight on the belt dropped the unmarked backpack stack');
       else if(!lines.length) bad.push('Z with the highlight on the belt said nothing');
       g.bagSel=iB; lines=[]; bagDropSel();
       if(g.bag.indexOf('bloom')<0) bad.push('controller Y with the highlight on the belt dropped the unmarked backpack stack');
       g.bagSel=iG; lines=[]; raidKey('Enter',false,null); keys['Enter']=false;
       if(g.bag.indexOf('gun_lance')<0||(p.wep?p.wep.id:null)!==w0) bad.push('Enter with the highlight on the belt equipped the unmarked backpack gun');
       NET.on=true; NET.role='host'; NET.seat=0; NET.peers=[];
       netGiftSeat=function(){ return 1; }; netGiftSend=function(to,m){ sent.push(m); return true; };
       S=bagStacks(); for(i=0;i<S.length;i++) if(S[i].key==='bloom') g.bagSel=i;
       g.giftOut=null; lines=[]; netGiftKey();
       if(g.giftOut||sent.length) bad.push('T with the highlight on the belt offered the unmarked backpack stack');
       netGiftSeat=oSeat; netGiftSend=oSend; NET.on=false; NET.role=null;
       g.bagBelt=false; S=bagStacks(); for(i=0;i<S.length;i++) if(S[i].key==='bloom') g.bagSel=i;
       raidKey('KeyZ',false,null); keys['KeyZ']=false;
       if(g.bag.indexOf('bloom')>=0) bad.push('control: Z in the backpack grid no longer drops the ringed stack');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       say=oSay; netGiftSeat=oSeat; netGiftSend=oSend;
       for(k in NET) if(!(k in NK)) delete NET[k];
       for(k in NK) NET[k]=NK[k];
       try{ var g2=__state(); if(g2&&!g2.over){ g2.bagOpen=false; g2.bagBelt=false; g2.giftOut=null; if(ha0!==undefined) g2.hotAssign=ha0; g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'20.52',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
