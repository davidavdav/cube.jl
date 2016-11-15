## types.jl Julia types for Rubik's cube
## (c) 2014 David A. van Leeuwen

## A cube is represented by corner positions and orientations, and edge positions and orientations
## Corner positions are numbered 1..8 in the order ufl, ufr, ubr, ubl, dfl, dfr, dbr, dbl
## A number n in the the array at index p indicates the cubie n in the position p
## Corner orientation follow the face of the white or yellow sticker of the cubie in index p:
## - up or down: 0, left or right: 1, front or back: 2
## Edge positions are numbered 1..12 in the order uf, ur, ub, ul, fl, fr, br, bl, df, dr, db, dl
## A number n in the array at index p indicates the cubie n in the position p
## Edge orientation: one colour in same or opposite plane: false, reversed: true

type Cube
    size::Int8                  # 2 or 3
    cp::Vector{Int8}            # corner position, ufl, ufr, ubr, ubl, dfl, dfr, dbr, dbl
    co::Vector{Int8}            # corner orientations
    ep::Vector{Int8}            # edge position, uf, ur, ub, ul, fl, fr, br, bl, df, dr, db, dl
    eo::BitVector               # edge orientation
    function Cube(size::Int)
        @assert 2 <= size <= 3
        cp = Array{Int8}(1:8)
        co = zeros(Int8, 8)
        ep = Array{Int8}(1:12)
        eo = falses(12)
        new(size, cp, co, ep, eo)
    end
end

const fact12 = factorial(12)
const fact8 = factorial(8)
const three2seven = 3^7

## an iterator state
type Move
    moves::Vector{Int8}
end
Move() = Move(Int8[])
#Move{T<:Integer}(m::Vector{T}) = Move(int8(m))

## an iterator
type Moves
    move::Move
    depth::Int
    nmoves::Int
    function Moves(m::Move, depth::Int)
        nmoves = 0
        p18 = 1
        for n = 1:depth
            p18 *= 18
            nmoves += p18
        end
        new(m, depth, nmoves)
    end
end
Moves(depth::Int) = Moves(Move(),depth)
