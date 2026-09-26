import os, gen
from gen import patch, fixture
A = "Knocked down. Extraction attempt reset. Hold E to try again."
B = "Knocked down. Extraction progress bar reset. Hold E to try again."
patch(1619, [
("""      say('""" + A + """');   // v16.17, his note: extraction hold meant nothing to him; v16.18: his words, Extraction attempt reset""",
"""      say('""" + B + """');   // v16.17, his note: extraction hold meant nothing to him; v16.19: his words, Extraction progress bar reset"""),
], "HIS WORDS: EXTRACTION PROGRESS BAR RESET. Knocked down while holding E to extract now says Knocked down. Extraction progress bar reset. Hold E to try again. Text only. Check 16.19 fails on v16.18",
"# HIS WORDS: EXTRACTION PROGRESS BAR RESET (2026-09-26), replacing v16.18. Text only.\n")
fixture(1619, r"""  {v:'16.19',what:'his words: knocked down while extracting says Extraction progress bar reset',
   run:function(){
     var src='', i;
     try{ var ss=document.getElementsByTagName('script'); for(i=0;i<ss.length;i++) src+=ss[i].textContent||''; }catch(e){ return 'SKIP: the build cannot read its own script'; }
     var cut=src.indexOf('window.__frame=function'); if(cut>0) src=src.slice(0,cut);
     if(src.length<100000) return 'SKIP: the build cannot read its own script';
     if(src.indexOf('""" + B + """')<0) return 'the knocked down line does not say Extraction progress bar reset';
     return null; }},
""")
# checks 16.17 and 16.18 read the v16.18 words: restaged to his final words
_p = os.path.join(gen.H, 'f1619.ps1'); _t = open(_p, encoding='ascii').read()
MK = open(os.path.join(gen.H, '..', 'mkfixture.ps1'), encoding='utf-8').read().split('\n')
extra = ''
for ln in [x for x in MK if "'" + A + "'" in x]:
    extra += gen.sub(ln, ln.replace(A, B).replace('Extraction attempt reset', 'Extraction progress bar reset'))
assert extra.count("SubRx @'") == 2, extra.count("SubRx @'")
_t = _t.replace("\n$src = [IO.File]", "\n" + extra + "$src = [IO.File]", 1)
open(_p, 'w', encoding='ascii', newline='\n').write(_t)
