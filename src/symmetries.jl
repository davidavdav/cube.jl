## data and code to deal with symmetries of the cube
## There are 48 symmetries, that can be generated from 5 basic symmetries:
## mirror yz (lr), mirror xz (ud), mirror xy (fb), mirror x=y,z (rf), rotate xyz (rfu)
## Orientation: r perp +x, u perl +y. f perp +z
## Order of rotation planes: rludfb
## Order of direction in plane: right, left, half (r,r',r2)
## major: plane, minor: direction: rr'r2ll'l2uu'u2dd'd2ff'f2bb'b2 correspondind to 1..18

## For operating on moves, represent a move as an 18-dim sparse vector, with only one bit set.

bitmoves = eye(Int, 18)

## encode using numbers 1..18, where do these get transformed to?
Myztrans = [5, 4, 6, 2, 1, 3, 8, 7, 9, 11, 10, 12, 14, 13, 15, 17, 16, 18]
Mxztrans = [2, 1, 3, 5, 4, 6, 11, 10, 12, 8, 7, 9, 14, 13, 15, 17, 16, 18]
Mxytrans = [2, 1, 3, 5, 4, 6, 8, 7, 9, 11, 10, 12, 17, 16, 18, 14, 13, 15]
Mxiyztrans = [8, 7, 9, 11, 10, 12, 2, 1, 3, 5, 4, 6, 14, 13, 15, 17, 16, 18]
Rxyztrans = [13, 14, 15, 16, 17, 18, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

alltrans = Array(Int8, 18, 48)
n=1
itrans = Int8[1:18;]                 # identity
for i=0:2
    jtrans = copy(itrans)
    for j=0:1
        ktrans=copy(jtrans)
        for k=0:1
            ltrans=copy(ktrans)
            for l=0:1
                mtrans=copy(ltrans)
                for m=0:1
                    alltrans[:,n] = mtrans
                    n += 1
                    mtrans = Myztrans[mtrans]
                end
                ltrans = Mxztrans[ltrans]
            end
            ktrans = Mxytrans[ktrans]
        end
        jtrans = Mxiyztrans[jtrans]
    end
    itrans = Rxyztrans[itrans]
end
