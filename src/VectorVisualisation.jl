module VectorVisualisation

V = VectorVisualisation
export V

using Infiltrator, StaticArrays
import Base: rand, abs, *
import Makie: arrows, arrows!, linesegments, linesegments!, Rect3D, Scene, convert_arguments, AbstractPlot, Arrows, cameracontrols

include("Point.jl")

const total_span = Rect3D(-1,-1,-1,2,2,2)
const Origin = Point(0.0, 0.0, 0.0)
const i_hat = Point(1.0,0.0,0.0)
const j_hat = Point(0.0,1.0,0.0)
const k_hat = Point(0.0,0.0,1.0)

origin() = Point(0.0,0.0,0.0)
origin(p::Point) = zero(p)
origin(num_origins) = [origin() for _ in num_origins]

Base.abs(p::Point) = √sum([i^2 for i in p])

direction(p::Point) = p ./ abs(p)

Base.rand(::Type{Point{3}}) = Point(rand_between(total_span[1]), rand_between(total_span[2]), rand_between(total_span[3]))
Base.rand(::Type{Point{3}}, numrand::Int) = [rand(Point{3}) for _ in 1:numrand]

rand_between(start_finish::NTuple{2,<:Real}, randnum) = (rand(randnum) .* (start_finish[2] .- start_finish[1]) .+ start_finish[1]) 
rand_between(start_finish::NTuple{2,<:Real}) = (rand() * (start_finish[2]- start_finish[1]) + start_finish[1]) 
rand_between(start::Real, finish::Real) = (rand() * (finish - start) + start)
rand_between(start, finish, randnum) = rand(randnum) .* (finish .- start) .+ start


"""
Overloading of arrows functions
"""
convert_arguments(P::Type{<: Arrows}, p1::Point{Float64, 3}, p2::Point{Float64, 3}) = convert_arguments(P, p1..., p2...)

plot_arrows(p1::Point, p2::Point; kwargs...) = arrows(p1,p2, arrowsize=0.05, limits=total_span; kwargs...)
plot_arrows!(p1::Point, p2::Point; kwargs...) = arrows!(p1,p2, arrowsize=0.05; kwargs...)
plot_arrows!(p1::Vector{Point}, p2::Vector{Point}; kwargs...) = arrows!(p1, p2, arrowsize=0.05; kwargs...)
plot_arrows(p1::Vector{Point}, p2::Vector{Point}; kwargs...) = arrows(p1, p2, arrowsize=0.05; kwargs...)
plot_arrows!(s::Scene, p1::Point, p2::Point; kwargs...) = arrows!(s::Scene, p1, p2, arrowsize=0.05; kwargs...)
plot_arrows!(s::Scene, p1::Vector{<:Point}, p2::Vector{<:Point}; kwargs...) = arrows!(s, p1, p2, arrowsize=0.05; kwargs...)

plot_arrows(p::Point; kwargs...) = arrows(origin(p), p, arrowsize=0.05; kwargs...)
plot_arrows!(p::Point; kwargs...) = arrows!(origin(p), p, arrowsize=0.05; kwargs...)
plot_arrows!(s::Scene, p::Point; kwargs...)  = arrows!(s::Scene, origin(p), p, arrowsize=0.05; kwargs...)

function initialise_scene()
	println("Setting up the environment. This might take a few seconds...")
	scene = Scene(limits=total_span, show_axis=false)
	plot_axis!(scene)
	cameracontrols(scene).rotationspeed[] = 0.002f0
	return scene
end
function plot_axis!(scene::Scene)
	plot_arrows!(scene, i_hat, linewidth=4)
	plot_arrows!(scene, j_hat, linewidth=4)
	plot_arrows!(scene, Origin, k_hat; arrowcolor=:green, linecolor=:green, arrowsize=0.05, linewidth=4)	
	plot_arrows!(scene, -i_hat, linewidth=4)
	plot_arrows!(scene, -j_hat, linewidth=4)
	plot_arrows!(scene, -k_hat, linewidth=4)
end



"""
Plane Arrows: Plot arrows across a given plane.
"""
plane_arrows(scene::Nothing, start, stop, direction_vector, num_lines::Int) = plane_arrows(start, stop, direction_vector, num_lines)
function plane_arrows(start, stop, direction_vector, num_lines::Int)
	
	scene = initialise_scene()
	plane_arrows!(scene, start, stop, direction_vector, num_lines)
	return scene
end
function plane_arrows!(scene::Scene, start, stop, direction_vector, num_lines::Int)

	points = row_of_points(start, stop, num_lines)
	plot_arrows!(scene, points, fill(direction_vector, num_lines + 1))
end
function row_of_points(start, stop, num_lines::Int)

	v = stop - start

	spacing = abs(v) / num_lines

	h = spacing * direction(v)

	[start] .+ [0:num_lines;] .* [h]
end


function plot_gridlines!(limits, spacing)

	gridlines = (get_gridlines(limits, spacing))
	for g in gridlines
		linesegments!(g)
	end
	return gridlines
end

function get_gridlines(limits, spacing)

	k = [limits.origin[1]:spacing:(limits.origin[1] + limits.widths[1]);]
	j = [limits.origin[2]:spacing:(limits.origin[2] + limits.widths[2]);]
	i = [limits.origin[3]:spacing:(limits.origin[3] + limits.widths[3]);]
	

	i_lines = (Point.(i[1],j,k') .=> Point.(i[1], j, k') .+ [i_hat * limits.widths[1]])[:]
	j_lines = (Point.(i,j[1],k') .=> Point.(i, j[1], k') .+ [j_hat * limits.widths[2]])[:]
	k_lines = (Point.(i,j',k[1]) .=> Point.(i, j', k[1]) .+ [k_hat * limits.widths[3]])[:]
	
	return i_lines, j_lines, k_lines
end

#=Base.:*(mult, pair::Pair{T,T}) where {T} = mult * pair[1] => mult * pair[2]
@inline function Base.:*(mult::Array{<:Any,1},p::Point)

	if size(mult) == length(p)
		for i in 1:length(p)
			mult[i]


	end
end=#

end