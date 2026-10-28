import re,sys,os,collections
s=open(os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','..','..','dark_raiders.html'),newline='').read()
# strip // line comments and /* */ blocks roughly for reference counting (keep strings)
code=re.sub(r'/\*.*?\*/','',s,flags=re.S)
code=re.sub(r'(?m)(^|[^:\'"\\])//[^\n]*',r'\1',code)
defs=[(m.group(1),s.count('\n',0,m.start())+1) for m in re.finditer(r'(?:^|[;\s}])function\s+([A-Za-z_$][\w$]*)\s*\(',s)]
byname=collections.defaultdict(list)
for n,l in defs: byname[n].append(l)
dups={n:ls for n,ls in byname.items() if len(ls)>1}
words=collections.Counter(re.findall(r'[A-Za-z_$][\w$]*',code))
dead=[]
for n,ls in byname.items():
    if words[n]<=len(ls): dead.append((n,ls[0]))
print('functions defined:',len(byname),' total defs:',len(defs))
print('defined more than once:',len(dups))
for n,ls in sorted(dups.items(),key=lambda x:x[1][0])[:40]: print('  DUP',n,ls)
print('never referenced outside their definition:',len(dead))
for n,l in sorted(dead,key=lambda x:x[1]): print('  DEAD',n,l)
