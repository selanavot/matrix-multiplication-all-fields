#!/usr/bin/env python3
"""Exact integer checks for sector and monomial-box lemmas in constructions.md."""
from fractions import Fraction


def odd_sectors(a,h,k):
    assert a>=1 and h>=1 and k%2==1
    A=a-1
    Y,Z=[],[];ys=zs=0
    for b in range(k):
        yl,zl=(h,h+A) if b%2==0 else (h+A,h)
        Y.extend([b]*yl);Z.extend([b]*zl)
        ys+=yl;zs+=zl
    H=k*h+(k//2)*A
    assert len(Y)==H and len(Z)==H+A
    counts=[0]*k
    for i in range(a):
        for j in range(H):
            z=i+j;b,c=Y[j],Z[z]
            w=(b%2)-(c%2)
            assert w in (0,1)
            assert (w==0)==(b==c)
            if w==0:counts[b]+=1
    assert counts==[a*h]*k


def interval(a,h,kind,s):
    A=a-1
    if kind=='F':Y=(s,s+h);Z=(s,s+h+A)
    else:Y=(s,s+h+A);Z=(s+A,s+A+h)
    shadow=(Fraction(Y[0]+Z[0],2),Fraction(Y[1]+Z[1],2))
    return Y,Z,shadow


def edge(Y,Z,A):
    return Z[0]<=Y[1]-1+A and Z[1]-1>=Y[0]


def shadows():
    cases=0
    for a in range(2,10):
        A=a-1
        for h in range(1,10):
            for kind in ('F','B'):
                Y,Z,S=interval(a,h,kind,0)
                for other in ('F','B'):
                    for d in range(-3*(a+h),3*(a+h)+1):
                        V,W,T=interval(a,h,other,d)
                        overlap=max(S[0],T[0])<min(S[1],T[1])
                        if overlap:assert edge(Y,W,A) and edge(V,Z,A),(a,h,kind,other,d)
                        cases+=1
    return cases


if __name__=='__main__':
    n=0
    for a in range(1,13):
        for h in range(1,13):
            for k in (1,3,5,7,9,11):odd_sectors(a,h,k);n+=1
    from construction_mixed_packing import torus_cover,lifted_packing_cycle,rectangle
    r=torus_cover(2,2,12)
    assert len(r['branches'])==24
    YM,ZM={},{}
    for k,b in enumerate(r['branches']):
        x,y=b['x'],b['y']
        Y,Z=(rectangle(x,y,2,3),rectangle(x,y,3,2)) if b['kind']=='FF' else (rectangle(x,y,3,2),rectangle(x+1,y-1,2,3))
        for i,j in Y:assert (i%12,j%12) not in YM;YM[i%12,j%12]=k
        for i,j in Z:assert (i%12,j%12) not in ZM;ZM[i%12,j%12]=k
    counts=[]
    for u in (0,1):
        for v in (0,1):
            cross=sum(YM[x,y]!=ZM[(x+u)%12,(y-v)%12] for x in range(12) for y in range(12))
            assert cross==48
            counts.append(cross)
    cyc=lifted_packing_cycle(2,2,12,r['branches'])
    assert cyc['status']=='cycle_found'
    print({'odd_sector_exact_cases':n,'shadow_implication_exact_cases':shadows(),'periodic_branches':24,'cross_slice_ranks':counts,'finite_cycle_edges':len(cyc['cycle_edges']),'status':'passed'})
