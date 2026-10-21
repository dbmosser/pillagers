# coord-07: median of repeats per run group, from raw-*.json (A, C) and raw-B-*.txt (stress.ps1 lines)
import json,glob,os,re,statistics as st,sys
D=os.path.dirname(os.path.abspath(__file__)); out={}
def med(v): v=[x for x in v if x is not None]; return round(st.median(v),1) if v else None
def spread(v): v=[x for x in v if x is not None]; return '%s-%s'%(min(v),max(v)) if v else ''
groups={}
for f in sorted(glob.glob(D+'/raw-[AC]-*.json')):
    if 'try1' in f: continue
    d=json.load(open(f)); s=d['sample']; name=d['run']; g=re.sub(r'-r\d','',name); groups.setdefault(g,[]).append((d,s))
for g,L in groups.items():
    S=[s for d,s in L]
    un=[]
    for d,s in L:
        u=d.get('unthrottled_calib_ms')
        if u is None: u=float(str(d.get('reset_and_unthrottled_calib','0 0')).split()[1])
        un.append(u)
    thr=[ (s['calib_ms']['before'])/u for (d,s),u in zip(L,un)]
    out[g]={'repeats':len(L),'p50':med([s['gap']['p50'] for s in S]),'p95':med([s['gap']['p95'] for s in S]),'worst':med([s['gap']['worst'] for s in S]),
      'over16_7':med([s['gap']['over16_7'] for s in S]),'over25':med([s['gap']['over25'] for s in S]),'frames':med([s['frames'] for s in S]),
      'fps_p50':med([s['fps_p50'] for s in S]),'p95_spread':spread([s['gap']['p95'] for s in S]),'p50_spread':spread([s['gap']['p50'] for s in S]),
      'busy_p50':med([s['busy_ms']['p50'] for s in S]),'busy_p95':med([s['busy_ms']['p95'] for s in S]),
      'gfx_window_p50':med([s['gfx_window']['p50'] for s in S if s['gfx_window']]),'gfx_window_p95':med([s['gfx_window']['p95'] for s in S if s['gfx_window']]),
      'gfx_end':S[-1]['gfx_end'],'throttle_ratio':round(st.median(thr),2),'throttle_ratio_spread':'%.2f-%.2f'%(min(thr),max(thr)),
      'scale_end':[s['drs_end']['gfxScaleNow'] for s in S],'rung_end':[s['drs_end']['q'] for s in S],'drs_moves':[s['drs_end']['moves'] for s in S],'stepdown_toast':[s['drs_end']['said'] for s in S],
      'canvas':S[-1]['canvases'],'dpr':S[-1]['dpr'],'moved_px':[s['moved_px'] for s in S],'free_gb':[d.get('free_gb') for d,s in L]}
B={}
for f in sorted(glob.glob(D+'/raw-B-*.txt')):
    T=re.search(r'raw-B-t(\d)',f).group(1)
    for line in open(f):
        line=line.strip()
        if line.startswith('{"n"'):
            j=json.loads(line); B.setdefault('B-t%s-n%d'%(T,j['n']),[]).append(j)
for g,L in B.items():
    out[g]={'repeats':len(L),'p50':med([j['ms']['med'] for j in L]),'p95':med([j['ms']['p95'] for j in L]),'worst':med([j['ms']['worst'] for j in L]),
      'p95_spread':spread([j['ms']['p95'] for j in L]),'update_med':med([j['update']['med'] for j in L]),'draw_med':med([j['draw']['med'] for j in L]),'draw_p95':med([j['draw']['p95'] for j in L]),'frames':med([j['frames'] for j in L]),'ents':L[0]['ents']}
json.dump(out,open(D+'/summary.json','w'),indent=1)
for g in sorted(out):
    o=out[g]; print(g, {k:v for k,v in o.items() if k not in ('gfx_end','canvas')})
