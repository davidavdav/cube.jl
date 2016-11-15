moves that keep corners in position:
#=6
1) l b2 l2 b l2 b2: seems to go a ++-- in l-plane (plus some damage)
2) b2 ri b2 r2 bi r2: --++ in two layers, corners 2, 4, 6, 8 (plus a lot of damage)
3) bi r bi r bi r: --+-++ in two layers, corners 2, 3, 4, 6, 7, 8
4) ui l2 u2 li u2 l2: -+-+ in top plane, 1)
5) l2 bi l2 b2 li b2: similar to 2)
more of these, efficiency ~ 5 / 100000, 20 sec, 4GB allocated
#=7
6) l u l2 u2 l u2 l -++- s-shaped (messy)
7) b li b ri u r l2 +-- --+ very messy
8) ui r bi ri l2 ui l similar
#=8
9) r bi ri u2 li u l2 u  --++ over 2, 4, 5, 8 == quite messy
10) li u ri u ri u ri l --+ -++ completely in FR planes but 1...
11) l b2 u2 l2 bi l2 u2 b2 similar
12) b2 ri b2 l u li b r +++ in B
13) l2 b l2 bi li b li bi ---, finaly, in only L---this is my 8-move --- ~ 1 / 4e5

Time to generate moves (leaving out symmetric moves, but inclusing repeats on the same plane)
depth=2, nmoves=17, time=0.0122
depth=3, nmoves=184, time=0.237
depth=4, nmoves=2632, time=4.55
depth=5, nmoves=43524, time=84.40

OK, more efficient traversal of moves, timing now (2-6)
2ms, 13ms, .14s, 2.1s, 
depth=6, nmoves=761124, 34s 
depth=7, nmoves=13569236, 607s, 91 GB allocated 

Remove trivial same-plane-in-succession moves (code gets hairier)
1      2       0.6 ms
2      12      2 ms
3      109     8 ms
4      1412    65 ms
5      20508   0.94 s
6      305608  13.5 s
7      4578095 205 s
8      68653368	   3131 s

for 8 moves, the fraction of left-over moves after symmetry and trivial removing is almost 1/170!
for 6 moves, the 305608 Moves only results in 74440 different positions, less than 1/4.  Would these be l r l'r' type moves?

OK, now with 6 moves I can make easier filters for interesting moves:

ma = Move[]
for m in Moves(6); push!(ma, m); end
i6 = map(x->index(rotate2(x)), ma)
corners6 = map(x->nthperm(corners(x)) == 1, i6)
print(ma[find(corners6 & !(i6 .== 1))])

still a lot of moves of type lrl'r', but some insteresting new moves:
1) r l' u r' l f' : similar to 2 below but with quarter-slice turn.  Rotates 5 edges
2) r l' u2 r' l f2 : simplest known 3-edge rotate
3) r u r' l f' l' : new, rotates 5 edges in S-curve
4) r l u2 f b d2 : new, interesting: +-+-+-+-, plus movement of all edges, as ^3 a nice "fives" pattern
5) r u' r u' r u' : same as original 3) in random experiment
6) r u' b l' d f' : -i+--i-+ plus a mess---11/12  edges move.  The whole rf rib makes a turn around the cube---this is the only bit that stays in place. In ^3, with lots of inversion like edges. 
7) r u2 r2 u r2 u2 : i+-ii-+i plus 6 edges in r an u planes mess. ^3 = I
8) r u2 l2 d l2 u2 : i+-ii-+i similar to 7), ^3 = I
9) r u2 f b d2 l : --++++-- ege complete mess! ^3 6 swaps of edges, ^6 = I
10) r2 u r2 u2 r u2 : similar to 7, ^3 = I
11) r2 u r2 d2 l d2 : +ii-i+-i, 6 edges rotated, ^3 = I
12) r2 u d l2 f b : -+-++-+-+-, all edges, ^3 is "fives" in ubdf planes. ^6 = I
13) r2 u2 r u2 r2 u : -+-+iiii, 6 edges (similar to top 3)
14) r2 u2 l u2 r2 d : iiii+-+-, similar to 13) but at the bottom. 


