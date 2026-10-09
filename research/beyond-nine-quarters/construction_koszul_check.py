#!/usr/bin/env python3
"""Exact all-characteristic Koszul ranks for binary convolution pencils.

Rows of K(S_H) have zero, one, or two entries. Two-entry rows are +1,-1,
so their equations identify two unknowns; one-entry rows force an unknown
zero. Union-find therefore computes rank over every field, without floating
point or a selected modulus. It also verifies the explicit kernel labels.
"""
import argparse,json
from itertools import combinations


def verify(H):
    if not isinstance(H,int) or H<1:raise ValueError('H must be a positive integer')
    X=list((r,s) for r in (0,1) for s in (0,1))
    Y=list((u,v) for u in range(H) for v in range(H+1))
    Z=list((w,z) for w in range(H+1) for z in range(H))
    columns=[(r,s,u,v) for r,s in X for u,v in Y]
    index={x:i for i,x in enumerate(columns)}
    parent=list(range(len(columns)))
    def root(i):
        while parent[i]!=i:parent[i]=parent[parent[i]];i=parent[i]
        return i
    def union(i,j):parent[root(i)]=root(j)
    forced=[];rows=0
    for i,j in combinations(range(4),2):
        p,q=X[i];r,s=X[j]
        for w,z in Z:
            entries=[]
            # coefficient N_pq enters the (r,s) unknown with sign +1;
            # coefficient N_rs enters the (p,q) unknown with sign -1.
            if 0<=w-p<H and 0<=z+q<=H:entries.append((index[r,s,w-p,z+q],1))
            if 0<=w-r<H and 0<=z+s<=H:entries.append((index[p,q,w-r,z+s],-1))
            if len(entries)==2:
                a,b=entries[0][0],entries[1][0]
                assert entries[0][1]==-entries[1][1]
                ra,sa,ua,va=columns[a];rb,sb,ub,vb=columns[b]
                assert (ua-ra,va+sa)==(ub-rb,vb+sb)
                union(a,b)
            elif len(entries)==1:
                a=entries[0][0];r0,s0,u0,v0=columns[a]
                assert u0-r0 in (-1,H-1),'interior kernel coordinate forced'
                forced.append(a)
            rows+=1
    forced_roots={root(i) for i in forced}
    components={}
    for i,c in enumerate(columns):components.setdefault(root(i),[]).append(c)
    free=[cs for k,cs in components.items() if k not in forced_roots]
    labels=set()
    for cs in free:
        ls={(u-r,v+s) for r,s,u,v in cs};assert len(ls)==1
        alpha,beta=next(iter(ls));assert 0<=alpha<=H-2 and 0<=beta<=H+1
        labels.add((alpha,beta))
        expected={(r,s,alpha+r,beta-s) for r,s in X if 0<=alpha+r<H and 0<=beta-s<=H}
        assert set(cs)==expected
    assert labels=={(a,b) for a in range(H-1) for b in range(H+2)}
    rank=len(columns)-len(free)
    assert rank==3*H*(H+1)+2
    return {'H':H,'matrix_rows':rows,'matrix_columns':len(columns),'kernel_dimension':len(free),'exact_rank':rank}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--max-width',type=int,default=10)
    args=parser.parse_args()
    if args.max_width<1:parser.error('--max-width must be positive')
    results=[verify(H) for H in range(1,args.max_width+1)]
    print(json.dumps({'status':'passed','method':'exact signed incidence equations; valid over every field','checks':results},indent=2))

if __name__=='__main__':main()
