#!/usr/bin/env python3
"""MILP heuristic with exact verification for actual monomial mixed sectors.

Run using research venv with SciPy. Feasibility is checked afterwards using
integer support coordinates; a solver bound is a numerical result, not a proof.
For a=2, branch equations force affine X weights; acyclic interaction suffices
for a monomial degeneration with X weights zero and branch potential weights.
"""
import argparse,json,math
from construction_mixed_packing import candidates
import numpy as np
from scipy.optimize import milp, Bounds, LinearConstraint
from scipy.sparse import coo_array


def solve(a,h,H,seconds,all_orientations=False):
 if not math.isfinite(seconds) or seconds<=0:raise ValueError("seconds must be finite and positive")
 cs=candidates(a,h,H,all_orientations);n=len(cs)
 Y=[{(x,y) for v,x,y in b['cells'] if v==0} for b in cs]
 Z=[{(x,y) for v,x,y in b['cells'] if v==1} for b in cs]
 edges=set();conflicts=set()
 for i in range(n):
  for j in range(i+1,n):
   if cs[i]['cells']&cs[j]['cells']:conflicts.add((i,j));continue
   for s,t in ((i,j),(j,i)):
    if any((x+u,y-v) in Z[t] for x,y in Y[s] for u in range(a) for v in range(a)):edges.add((s,t))
 for i,j in edges:
  if (j,i) in edges:conflicts.add(tuple(sorted((i,j))))
 edges={(i,j) for i,j in edges if tuple(sorted((i,j))) not in conflicts}
 rows=[];cols=[];data=[];lbs=[];ubs=[]
 def row(items,lo,hi):
  k=len(lbs);lbs.append(lo);ubs.append(hi)
  for i,v in items:rows.append(k);cols.append(i);data.append(v)
 for i,j in conflicts:row([(i,1),(j,1)],-np.inf,1)
 M=n+1
 for i,j in edges:row([(n+i,1),(n+j,-1),(i,-M),(j,-M)],1-2*M,np.inf)
 A=coo_array((np.array(data,dtype=float),(np.array(rows,dtype=np.int32),np.array(cols,dtype=np.int32))),shape=(len(lbs),2*n)).tocsc()
 r=milp(np.r_[-np.ones(n),np.zeros(n)],integrality=np.r_[np.ones(n),np.zeros(n)],bounds=Bounds(np.zeros(2*n),np.r_[np.ones(n),np.full(n,n)]),constraints=LinearConstraint(A,lbs,ubs),options={'time_limit':seconds,'mip_rel_gap':0})
 chosen=[i for i in range(n) if r.x is not None and r.x[i]>.5]
 assert all(not(cs[i]['cells']&cs[j]['cells']) for m,i in enumerate(chosen) for j in chosen[m+1:])
 graph={i:[] for i in chosen}
 for i,j in edges:
  if i in graph and j in graph:graph[i].append(j)
 state={};pot={}
 def visit(i):
  assert state.get(i)!=1,'integer selected graph has a cycle'
  if state.get(i)==2:return pot[i]
  state[i]=1;pot[i]=max([visit(j)+1 for j in graph[i]]+[0]);state[i]=2;return pot[i]
 for i in chosen:visit(i)
 branches=[{**{k:v for k,v in cs[i].items() if k!='cells'},'potential':pot[i]} for i in chosen]
 # Recheck every source-support edge between retained coordinates.
 YM={xy:pot[i] for i in chosen for xy in Y[i]};ZM={xy:-pot[i] for i in chosen for xy in Z[i]}
 ownersY={xy:i for i in chosen for xy in Y[i]};ownersZ={xy:i for i in chosen for xy in Z[i]}
 for (x,y),w in YM.items():
  for u in range(a):
   for v in range(a):
    z=(x+u,y-v)
    if z in ZM:assert (w+ZM[z]==0) if ownersY[(x,y)]==ownersZ[z] else (w+ZM[z]>0)
 return {'a':a,'h':h,'H':H,'all_four_orientations':all_orientations,'candidates':n,'kept':len(chosen),'current_profile_squared_ratio':((H+(a-1)/2)/(h+(a-1)/2))**2 if h>=a else None,'dimension_capacity':H*(H+a-1)/(h*(h+a-1)),'solver_status':int(r.status),'solver_message':r.message,'solver_dual_upper_bound':float(-r.mip_dual_bound) if hasattr(r,'mip_dual_bound') else None,'exact_support_verification':'passed','branches':branches}

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--a',type=int,default=2);p.add_argument('--h',type=int,default=2);p.add_argument('--H',type=int,default=6);p.add_argument('--seconds',type=float,default=10);p.add_argument('--all-orientations',action='store_true')
 z=p.parse_args();print(json.dumps(solve(z.a,z.h,z.H,z.seconds,z.all_orientations),indent=2))
