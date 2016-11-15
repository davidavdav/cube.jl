## cube.jl
## see if we can compute things for the Rubik's cube.
## start at 2x2x2

## Cube functions
function init!(c::Cube)
    for i in 1:8
        c.cp[i] = i
        c.co[i] = 0
    end
    for i in 1:12
        c.ep[i] = i
    end
    c.eo.chunks[1] = 0
    c
end

## colors for printing
cubecolors = [:red, :magenta, :yellow, :gray, :blue, :green]
## corners: order of colors l/r, u/d, f/b
cornercolors = [2 3 5;
                1 3 5;
                1 3 6;
                2 3 6;
                2 4 5;
                1 4 5;
                1 4 6;
                2 4 6]

## modulo for index-types
imod{T<:Integer}(x::T, d::T) = mod(x-1, d) + 1
## This is ugly
function Base.print(io::IO, c::Cube)
    pk(c) = print_with_color(cubecolors[c], io, "o")
    cp=c.cp
    co=c.co
    ## back
    print(io, "   ")
    pk(cornercolors[cp[8],imod(3+co[8],3)])
    print(io, " ")
    pk(cornercolors[cp[7],imod(3+co[7],3)])
    println(io)
    println(io)
    print(io, "   ")
    pk(cornercolors[cp[4],imod(3+co[4],3)])
    print(io, " ")
    pk(cornercolors[cp[3],imod(3+co[3],3)])
    ##
end


function coindex(co::Vector{Int8})
    corners = 0
    for i = 1:7
        corners *= 3
        corners += co[i]
    end
    corners
end

function index(c::Cube)
    if c.size==3
        edges = nthperm(c.ep) + fact12 * (c.eo.chunks[1] & 0x7ff) - 1
    else
        edges  = 0
    end
    return nthperm(c.cp) + UInt64(fact8) * (coindex(c.co) + three2seven * edges)
end

## extract corner positions from index
corners(index::UInt64) = nthperm(collect(1:8), mod1(index, fact8))

## rotate some of the corners at position p of the array pos
function rot!(pos::Array{Int8}, p::Vector{Int}, or::Array{Int8}, twist::Vector{Int})
    dest = vcat(p[2:end], p[1])
    or[dest] = twist[or[p]+1]
    pos[dest] = pos[p]
end
## same for edges
function rot!(pos::Array{Int8}, p::Vector{Int}, or::BitVector, twist::Vector{Int})
    dest = vcat(p[2:end], p[1])
    or[dest] = or[p]
    pos[dest] = pos[p]
    ## taking care of orientation is harder. We have to see of any of the affected positions p
    ## contain orientation-sensitive cubies (the ones in the mid-parallel plane).
    for pp in p
        cubie = pos[pp]
        if cubie in twist
            or[pp] = !or[pp]
        end
    end
end

## exchange some cubes, by a performing a half twist. Orientation stays the same.
## p now contains pairs of cubies to be exchanged.
function exch!{T}(pos::Array{Int8}, p::Vector{Int}, or::T)
    dest = p[[2, 1, 4, 3]]
    pos[dest] = pos[p]
    or[dest] = or[p]
end

## tables in order r, ri, l, li, u, d, f, b
## corner positions, quarter turns
cptrans = [2 3 7 6;             # r
           2 6 7 3;
           1 5 8 4;             # l
           1 4 8 5;
           1 4 3 2;             # u
           1 2 3 4;
           5 6 7 8;             # d
           5 8 7 6;
           1 2 6 5;             # f
           1 5 6 2;
           3 4 8 7;             # b
           3 7 8 4]
## corner orientations, quarter turns
## inversion and normal give the same answers, so do l and r
cotrans = [2 1 0;
           0 2 1;
           1 0 2]
## half turns r2, l2, u2, d2, f3, b2 --- orientations don't change
cp2trans = [2 7 3 6;
            1 8 4 5;
            1 3 2 4;
            5 7 6 8;
            1 6 2 5;
            3 8 4 7]
## edge positions, quarter turns
eptrans = [2 7 10 6;
           2 6 10 7;
           4 5 12 8;
           4 8 12 5;
           1 4 3 2;
           1 2 3 4;
           9 10 11 12;
           9 12 11 10;
           1 6 9 5;
           1 5 9 6;
           3 8 11 7;
           3 7 11 8]
## edge orientations, quarter turns.  Numbers are cubie numbers that flip orientation
## one line per axis, r, r', l and l' have the same entry
eotrans = [1 3 9 11;
           5 6 7 8;
           2 4 10 12]
## edge positions, half turns, pairs exchange just like for corners
ep2trans = [2 10 7 6;
            4 12 5 8;
            1 3 2 4;
            9 11 10 12;
            1 9 5 6;
            3 11 7 8]

## quarter turn functions
for (i, func) in enumerate([:r, :ri, :l, :li, :u, :ui, :d, :di, :f, :fi, :b, :bi])
    coi = ((i-1) ÷ 4) + 1
    @eval function $func(c::Cube)
        rot!(c.cp, vec(cptrans[$i,:]), c.co, vec(cotrans[$coi,:]))
        if c.size > 2
            rot!(c.ep, vec(eptrans[$i,:]), c.eo, vec(eotrans[$coi,:]))
        end
        return c
    end
end
## half turn functions
for (i, func) in enumerate([:r2, :l2, :u2, :d2, :f2, :b2])
    @eval function $func(c::Cube)
        exch!(c.cp, vec(cp2trans[$i,:]), c.co)
        if c.size > 2
            exch!(c.ep, vec(ep2trans[$i,:]), c.eo)
        end
        return c
    end
end

cubemoves = [r, ri, r2, l, li, l2, u, ui, u2, d, di, d2, f, fi, f2, b, bi, b2]

function rotate(c::Cube, move::Function...)
    for m in move
        m(c)
    end
    return c
end

rotind = Dict(zip(['r', 'l', 'u', 'd', 'f', 'b'], 0:5))

function rotate{S<:AbstractString}(c::Cube, move::S)
    next = string(move[2:end]," ")
    i = 1
    moves = Function[]
    while i <= length(move)
        if haskey(rotind, move[i])
            ind = 3*rotind[move[i]]
            alt = searchindex("'2", next[i:i])
            ind += alt
            push!(moves, cubemoves[ind+1])
            i += 1 + (alt>0)
        else
            error("Unsupported move: ", move[i])
        end
    end
    rotate(c, moves...)
end

function rotate(c::Cube, m::Move)
    rotate(c, cubemoves[m.moves]...)
end

rotate2(m::Move) = rotate(Cube(2),m)

function Base.randperm(c::Cube, n::Int)
    s = Dict{UInt64,Int}()
    for i=1:n
        m = cubemoves[rand(1:12)]
        ind = index(m(c))
        if haskey(s, ind)
            s[ind] += 1
        else
            s[ind] = 1
        end
    end
    return s
end

## filter that checks for keeping corner position, but not orientation
function keepscp(m::Move)
    c = rotate(Cube(2), m)
    return nthperm(c.cp)==1 && coindex(c.co)!=0
end

## filter that checks for keeping corner position & orientation
function keepscpco(m::Move)
    c = rotate(Cube(3), m)
    return nthperm(c.cp)==1 && coindex(c.co)==0 && nthperm(c.ep)!=1
end

## Move / Moves
Base.copy(m::Move) = Move(copy(m.moves))
Base.length(m::Move) = length(m.moves)
function index(m::Vector{Int8})
    r = zero(Int)
    for i in 1:length(m)
        r *= 18
        r += m[i]
    end
    return r
end
function Base.print(io::IO, m::Move)
    for move in m.moves
        print(io, "rludfb"[div(move-1,3)+1])
        if (i = (move -1) % 3)>0
            print(io, "'2"[i])
        end
        print(" ")
    end
end


index(m::Move) = index(m.moves)
index(m::Array{Int8,2}) = map(i->index(m[:,i]), 1:size(m,2))
function Move(i::Int)
    r = Int8[]
    while i>0
        unshift!(r, mod(i-1,18)+1)
        i = div(i-1, 18)
    end
    return Move(r)
end

## Dumb iterator for moves
## State is the next move sequence
Base.start(m::Moves) = index(m.move)+1
Base.done(m::Moves, s::Int) = s >= m.nmoves
function Base.next(m::Moves, s::Int)
    c = s
    done = false
    m = Move(s)
    inc!(m)
    s = index(m)
    return (Move(c), s)
end

## increment move, a recursive function.
function inc!(m::Move, e=length(m))
    c = index(m.moves[1:e])
    done = false
    while !done
        m.moves[e] += 1
        if e > 1 && div(m.moves[e-1]-1, 3) == div(m.moves[e]-1, 3)
##            print("e=", e, " skipping from ", m)
            m.moves[e] += 3     # skip same plane in succession
##            println(" to ", m)
        elseif e>2 && div(m.moves[e-2]-1,6) == div(m.moves[e-1]-1,6) == div(m.moves[e]-1,6)
##            println("e=", e, " skipping from ", m)
            m.moves[e] += 6
        end
        if m.moves[e] > 18
            m.moves[e] = 1
            if e==1
                push!(m.moves, 1) # now end+1 1's, the first non-trivial move is rlrlrl...
                for i=2:2:length(m.moves) # which is trivial for other reasons...
                    m.moves[i] += 3
                end
                break
            else
                inc!(m, e-1)
                if m.moves[e-1] <= 3
                    m.moves[e] = 4
                else
                    m.moves[e] = 1
                end
                break
            end
        end
        done = minimum(index(alltrans[m.moves[1:e],:])) > c
    end
    return m
end

## Moves(from..to)
function Moves(start::Int, depth::Int)
    moves = Moves(depth)
    seq = repmat([1,4,7], iceil(start/3))
    moves.move = Move(seq[1:start])
    return moves
end

## init from string
function Move{S<:AbstractString}(move::S)
    next = string(move[2:end]," ")
    i = 1
    moves = Int[]
    while i <= length(move)
        if haskey(rotind, move[i])
            ind = 3*rotind[move[i]]
            alt = searchindex("'2", next[i:i])
            ind += alt
            push!(moves, ind+1)
            i += 1 + (alt>0)
        else
            error("Unsupported move: ", move[i])
        end
    end
    return Move(moves)
end

## displays in how many repetitions a move returns to Indentity.
function repeats(m::Move)
    c = rotate(Cube(3), m)
    i = 1
    while index(c) != 1
        rotate(c, m)
        i += 1
    end
    return i
end
