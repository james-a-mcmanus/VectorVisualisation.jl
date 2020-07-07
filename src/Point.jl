import Base: size, show, getindex, setindex!, zero, -, +

struct Point{T,S} <: AbstractArray{T,1}
	data::SArray{Tuple{S},T,1,S}
end

Point(a::T,b::T,c::T) where {T<:Real} = Point(SA[a,b,c])
Point(a::T,b::T) where {T<:Real} = Point(SA[a,b])
Point(a::Real) = Point(SA[a])

Base.size(p::Point) = size(p.data)
Base.show(p::Point) = show(p.data)
Base.getindex(p::Point, i) = getindex(p.data, i)
Base.setindex!(p::Point, f, i) = setindex!(p.data, f, i)
Base.zero(p::Point{T,S}) where {T,S} = Point(zeros(SVector{S,T}))

Base.:-(p::Point) = Point(-p.data)
Base.:+(p::Point, a::AbstractArray) = length(p) == length(a) ? Point(p.data + a) : error("arrays are of different lengths")

convert(::Type{MakiePoint}, p::Point) = MakiePoint(p.data)