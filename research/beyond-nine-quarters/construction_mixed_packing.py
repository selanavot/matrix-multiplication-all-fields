#!/usr/bin/env python3
"""Exact finite search for mixed convolution branches in a tensor square.

Search is combinatorial only: a successful packing is NOT a degeneration.
All support coordinates are integers, independent of the scalar field.
No third-party dependencies.
"""
from __future__ import annotations
import argparse
import json


def positive_dimensions(**values):
    for name, value in values.items():
        if not isinstance(value, int) or value < 1:
            raise ValueError(f"{name} must be a positive integer")


def rectangle(x, y, w, h):
    return {(x+i,y+j) for i in range(w) for j in range(h)}


def candidates(a,h,H,all_orientations=False):
    positive_dimensions(a=a,h=h,H=H)
    A=a-1
    out=[]
    for kind in (('FF','FB','BF','BB') if all_orientations else ('FF','BB')):
        for x in range(H):
            for y in range(H+A):
                bx,by=kind[0]=='B',kind[1]=='B'
                Y=rectangle(x,y,h+A if bx else h,h if by else h+A)
                Z=rectangle(x+A if bx else x,y-A if by else y,h if bx else h+A,h+A if by else h)
                if all(0<=i<H and 0<=j<H+A for i,j in Y) and all(0<=i<H+A and 0<=j<H for i,j in Z):
                    cells={(0,i,j) for i,j in Y}|{(1,i,j) for i,j in Z}
                    out.append({'kind':kind,'x':x,'y':y,'cells':cells})
    return out


def exact_cover(a,h,H):
    """Full-cover only; return None means NO balanced full monomial tiling."""
    cs=candidates(a,h,H)
    cells={(0,i,j) for i in range(H) for j in range(H+a-1)}|{(1,i,j) for i in range(H+a-1) for j in range(H)}
    if len(cells)%(2*h*(h+a-1)):
        return {'status':'nonintegral_capacity','candidates':len(cs)}
    bycell={v:[] for v in cells}
    for k,c in enumerate(cs):
        for v in c['cells']: bycell[v].append(k)
    nodes=0
    def rec(left,chosen):
        nonlocal nodes
        nodes+=1
        if not left: return chosen
        avail=[]
        for v in sorted(left):
            ids=[i for i in bycell[v] if cs[i]['cells']<=left]
            if not ids:return None
            if not avail or len(ids)<len(avail):avail=ids
            if len(avail)==1:break
        for i in avail:
            z=rec(left-cs[i]['cells'],chosen+[i])
            if z is not None:return z
        return None
    found=rec(cells,[])
    return {'a':a,'h':h,'H':H,'capacity':H*(H+a-1)//(h*(h+a-1)), 'candidates':len(cs),'nodes':nodes,'status':'packing_found' if found is not None else 'no_full_packing','branches':[{k:v for k,v in cs[i].items() if k!='cells'} for i in found] if found is not None else []}


# Research helpers below are imported by the companion audit driver.
def torus_cover(a,h,N):
    positive_dimensions(a=a,h=h,N=N)
    A=a-1
    cells={(v,i,j) for v in (0,1) for i in range(N) for j in range(N)}
    cs=[]
    for kind in ('FF','BB'):
        for x in range(N):
            for y in range(N):
                if kind=='FF':Y,Z=rectangle(x,y,h,h+A),rectangle(x,y,h+A,h)
                else:Y,Z=rectangle(x,y,h+A,h),rectangle(x+A,y-A,h,h+A)
                covered={(0,i%N,j%N) for i,j in Y}|{(1,i%N,j%N) for i,j in Z}
                if len(covered)==2*h*(h+A):cs.append({'kind':kind,'x':x,'y':y,'cells':covered})
    by={v:[] for v in cells}
    for i,c in enumerate(cs):
        for v in c['cells']:by[v].append(i)
    nodes=0
    def rec(left,chosen):
        nonlocal nodes
        nodes+=1
        if not left:return chosen
        best=None
        for v in sorted(left):
            opts=[i for i in by[v] if cs[i]['cells']<=left]
            if not opts:return None
            if best is None or len(opts)<len(best):best=opts
            if len(best)==1:break
        for i in best:
            r=rec(left-cs[i]['cells'],chosen+[i])
            if r is not None:return r
        return None
    found=rec(cells,[])
    return {'a':a,'h':h,'period':N,'nodes':nodes,'status':'periodic_packing_found' if found is not None else 'no_periodic_packing','branches':[{k:v for k,v in cs[i].items() if k!='cells'} for i in found] if found is not None else []}


def lifted_packing_cycle(a,h,N,pattern,copies=3):
    """Find exact directed cycle of cross-branch support edges in finite lift.

    For a=h=2, internal branch equations force affine first-leg weights;
    gauge those away, making each branch have Y weight c and Z weight -c.
    A directed cycle of strict-erasure edges is then impossible.
    """
    positive_dimensions(a=a,h=h,N=N,copies=copies)
    A=a-1
    Ymap,Zmap,branches={},{},[]
    for dx in range(copies):
        for dy in range(copies):
            for b in pattern:
                kind,x,y=b['kind'],b['x']+dx*N,b['y']+dy*N
                if kind=='FF':Y,Z=rectangle(x,y,h,h+A),rectangle(x,y,h+A,h)
                else:Y,Z=rectangle(x,y,h+A,h),rectangle(x+A,y-A,h,h+A)
                if any(min(i,j)<0 for i,j in Y|Z):continue
                k=len(branches);branches.append({'kind':kind,'x':x,'y':y})
                for v in Y:
                    assert v not in Ymap
                    Ymap[v]=k
                for v in Z:
                    assert v not in Zmap
                    Zmap[v]=k
    edges={k:{} for k in range(len(branches))}
    for (x,y),j in Ymap.items():
        for i1 in range(a):
            for i2 in range(a):
                z=(x+i1,y-i2);k=Zmap.get(z)
                if k is not None and k!=j:edges[j][k]={'X':[i1,i2],'Y':[x,y],'Z':list(z)}
    state={};path=[]
    def visit(v):
        state[v]=1;path.append(v)
        for w in edges[v]:
            if state.get(w)==1:return path[path.index(w):]+[w]
            if state.get(w,0)==0:
                z=visit(w)
                if z:return z
        path.pop();state[v]=2
        return None
    found=None
    for v in edges:
        if state.get(v,0)==0:
            found=visit(v)
            if found:break
    return {'lifted_branch_count':len(branches),'cycle_branches':[branches[i] for i in found] if found else [],'cycle_edges':[edges[i][j] for i,j in zip(found,found[1:])] if found else [],'status':'cycle_found' if found else 'no_cycle_found'}


def main():
    p=argparse.ArgumentParser()
    p.add_argument('--a',type=int,default=2);p.add_argument('--h',type=int,default=2)
    p.add_argument('--H',type=int,default=6);p.add_argument('--torus',action='store_true')
    p.add_argument('--period',type=int,default=12);p.add_argument('--output')
    z=p.parse_args()
    if z.torus:
        r=torus_cover(z.a,z.h,z.period)
        if r['branches']:r['finite_lift_obstruction']=lifted_packing_cycle(z.a,z.h,z.period,r['branches'])
    else:r=exact_cover(z.a,z.h,z.H)
    out=json.dumps(r,indent=2)+'\n'
    if z.output:
        with open(z.output,'w') as f:f.write(out)
    print(out,end='')

if __name__=='__main__':main()
