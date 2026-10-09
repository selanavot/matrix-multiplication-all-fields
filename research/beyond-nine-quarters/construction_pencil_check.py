#!/usr/bin/env python3
"""Exact normalized matrix-pencil algebra for C(2,2) tensor its outer swap."""
from fractions import Fraction as Q
import argparse,json
from itertools import product
from math import comb


def ident(n):return [[Q(i==j) for j in range(n)] for i in range(n)]
def mul(A,B):return [[sum(x*y for x,y in zip(row,col)) for col in zip(*B)] for row in A]
def add(A,B):return [[x+y for x,y in zip(a,b)] for a,b in zip(A,B)]
def scale(k,A):return [[k*x for x in row] for row in A]
def flat(A):return sum(A,[])
def trace(A):return sum(A[i][i] for i in range(len(A)))

def inv(A):
 n=len(A);R=[list(a)+b for a,b in zip(A,ident(n))]
 for k in range(n):
  p=next(i for i in range(k,n) if R[i][k]);R[k],R[p]=R[p],R[k]
  c=R[k][k];R[k]=[v/c for v in R[k]]
  for i in range(n):
   if i!=k:
    c=R[i][k];R[i]=[x-c*y for x,y in zip(R[i],R[k])]
 return [r[n:] for r in R]


def source(width=2):
 assert isinstance(width,int) and width>=1
 Y=[(i,j) for i in range(width) for j in range(width+1)]
 Z=[(i,j) for i in range(width+1) for j in range(width)]
 return {f'{i}{j}':[[Q(k-u==i and v-z==j) for u,v in Y] for k,z in Z] for i in range(2) for j in range(2)}


def independent(rows,vector):
 v=vector[:]
 for p,r in sorted(rows.items()):
  if v[p]:
   c=v[p];v=[x-c*y for x,y in zip(v,r)]
 if not any(v):return False
 p=next(i for i,x in enumerate(v) if x);c=v[p];v=[x/c for x in v];rows[p]=v
 return True


def algebra(gens):
 n=len(next(iter(gens.values())));basis=[('',ident(n))];rows={}
 independent(rows,flat(basis[0][1]));index=0
 while index<len(basis):
  word,A=basis[index];index+=1
  for key,B in gens.items():
   C=mul(A,B)
   if independent(rows,flat(C)):basis.append((word+key+' ',C))
 return basis


def target(orientations):
    result={k:[[Q(0) for _ in range(6)] for _ in range(6)] for k in ('00','01','10','11')}
    assert len(orientations)==3 and all(x in ('F','B') for x in orientations)
    for block in range(3):
        for i in range(2):
            for j in range(2):
                row,col=(i,j) if orientations[block]=='F' else (j,i)
                result[f'{i}{j}'][2*block+row][2*block+col]=Q(1)
    return result


def word_trace(B,word):
    R=ident(6)
    for key in word.split():R=mul(R,B[key])
    return trace(R)


def family_quartic(max_width):
    assert isinstance(max_width,int) and max_width>=1
    results=[]
    for width in range(1,max_width+1):
        S=source(width);A=inv(add(S["00"],S["11"]))
        B,C=mul(A,S["01"]),mul(A,S["10"])
        value=trace(mul(mul(B,B),mul(C,C)))
        predicted=-2*comb(width+2,4)
        results.append({"width":width,"exact_trace":str(value),"conjectured_formula":predicted,"matches":value==predicted})
    return results


def main(details=False,family_max=None):
    S=source();I=inv(add(S['00'],S['11']));B={k:mul(I,M) for k,M in S.items()}
    alg=algebra(B)
    assert len(alg)==36, "source normalized algebra is not full Mat6"
    words=('01 01 10 10','01 10 01 10','00 01 10','00 10 01')
    source_traces={w:str(word_trace(B,w)) for w in words}
    assert word_trace(B,'01 01 10 10')==-2
    targets=[]
    for orientation in product(('F','B'),repeat=3):
        T=target(orientation)
        assert add(T['00'],T['11'])==ident(6)
        assert word_trace(T,'01 01 10 10')==0
        targets.append({'orientations':''.join(orientation),'traces':{w:str(word_trace(T,w)) for w in words}})
    result={'status':'passed','associative_algebra_dimension':len(alg),'source_traces':source_traces,'target_quartic_traces':{t['orientations']:t['traces']['01 01 10 10'] for t in targets},'scope':'Exact rational fixed-first-leg pencil obstruction. General first-leg normalization is a separate mathematical argument.'}
    if details:
        result['target_details']=targets
        result['normalized_generators']={k:[[str(v) for v in r] for r in A] for k,A in B.items()}
        result['independent_words']=[w for w,_ in alg]
    if family_max is not None:result['family_checks']=family_quartic(family_max)
    return result

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--details',action='store_true',help='Include all normalized matrices and independent algebra words')
    parser.add_argument('--family-max',type=int,help='Check the conjectured wider-pencil trace formula through this positive width')
    args=parser.parse_args()
    if args.family_max is not None and args.family_max<1:parser.error('--family-max must be positive')
    print(json.dumps(main(args.details,args.family_max),indent=2))
