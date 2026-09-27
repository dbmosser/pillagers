import os, gen
from gen import patch, fixture
patch(1631, [
("""  var MARKS=[300,240,180,120,60,30], tlNow=0, i;""",
"""  var MARKS=[300,240,180,120,60,30], tlNow=0, i;   // v16.31: the warning keeps its own rising shape (v15.24) at the quieter level he asked for (v16.30)"""),
], "CHECK 15.24 FOLLOWS HIS NEWER NOTE. v16.30 made the clock alarms quieter on his note; check 15.24 still demanded they be louder than the machine alarm, and v16.30 shipped with it failing, which its notes wrongly said passed. The check now reads what keeps the warning distinct, its three rising sweeps, and that it is quieter than it was. No game change beyond a comment. Check 16.31 fails on v16.30",
"# CHECK 15.24 FOLLOWS HIS NEWER NOTE (the clock alarm volume). Correction of the v16.30 record.\n")
fixture(1631, r"""  {v:'16.31',what:'check 15.24 follows his newer note: the clock warning is distinct by its three rising sweeps and quieter than the old .12',
   run:function(){
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.indexOf("v16.31: the warning keeps its own rising shape")<0) return 'this build does not carry the v16.31 note';
     if(src.indexOf("for(var cwi=0;cwi<3;cwi++)")<0) return 'the clock warning lost its three sweeps';
     return null; }},
""")
_p = os.path.join(gen.H, 'f1631.ps1'); _t = open(_p, encoding='ascii').read()
a = "       else if(!(cw>=al*1.5)) bad.push('the clock siren starts at '+cw+', not clearly louder than the machine alarm at '+al);"
b = "       else if(!(cw>0&&cw<0.12)) bad.push('the clock siren starts at '+cw+', not the quieter level of his v16.30 note (under the old 0.12)');   // v16.31: distinct by its rising sweeps, no longer by loudness"
_t = _t.replace("\n$src = [IO.File]", "\n" + gen.sub(a, b) + "$src = [IO.File]", 1)
open(_p, 'w', encoding='ascii', newline='\n').write(_t)
