### A Pluto.jl notebook ###
# v0.11.11

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 5cf640b0-eca6-11ea-0b86-2d8c4869e0c7
#This is where I am adding all the packages necessary for this tutorial.
# the Pkg package is how we add other cool packages to our Julia distribution

begin
	#importing some packages
	using Pkg
	using Markdown
	using InteractiveUtils
	Pkg.add("Images")
	using Images
	Pkg.add("ImageMagick")
	using ImageMagick
	Pkg.add("Plots")
	Pkg.add("DataFrames")
	Pkg.add("CSV")
	Pkg.add("ScatteredInterpolation")
	Pkg.add("GMT")
	Pkg.add("PlutoUI")

	
end

# ╔═╡ 3beb6750-eccf-11ea-2142-b95f7e1a3e24
using Plots

# ╔═╡ 4a8e9da0-ecce-11ea-322c-0ba8ab801500
using PlutoUI

# ╔═╡ a7e00f60-ecbb-11ea-00f7-673a16c2723e
begin
	using CSV # package to read in a wide range of data files
	elev = CSV.File("surf_matrix_TEST.txt") |> DataFrame
	names!(elev, [:long, :lat, :val])
	
	# uncomment to change to Elevation by subtracting the radius of the earth
	elev.val = elev.val .- 6371000

	# uncomment to have negative long values
	elev.long = elev.long .- 360
end

# ╔═╡ 964e1960-ecc3-11ea-38ea-d329c41a1640
using ScatteredInterpolation

# ╔═╡ 27b335ae-ecc5-11ea-325e-5d9416eb19e4
using GMT

# ╔═╡ 62887de0-eca6-11ea-2fea-0f79ebe77675
md"""
# Introduction to Julia and GMT.jl 
by Christopher M. Calvelage

This notebook should teach you the basics of the Julia programming language and how to use common GMT methods with a high-level API. Resources for this tutorial can be found at: https://github.com/ccalvelage3/julia_tutorial.git

Julia in a nutshell: 

**Fast:** 
Julia was designed from the beginning for high performance. Julia programs compile to efficient native code for multiple platforms via LLVM.

**Reproducible:**
Reproducible environments make it possible to recreate the same Julia environment every time, across platforms, with pre-built binaries.

**General:**
Julia provides asynchronous I/O, metaprogramming, debugging, logging, profiling, a package manager, and more. One can build entire Applications and Microservices in Julia.

**Dynamic:**
Julia is dynamically typed, feels like a scripting language, and has good support for interactive use.

**Composable:**
Julia uses multiple dispatch as a paradigm, making it easy to express many object-oriented and functional programming patterns. The talk on the Unreasonable Effectiveness of Multiple Dispatch explains why it works so well.

**Open source:**
Julia is an open source project with over 1,000 contributors. It is made available under the MIT license. The source code is available on GitHub.

Find lists of awesome Julia packages at https://juliaobserver.com/packages 🙂

You may have to wait for the animated code below to render before beginning. This could take 5-10 minutes.

"""

# ╔═╡ 7cd40f20-eca6-11ea-2670-c7ce3983da4a
md"## Basic Julia
Syntactically, Julia is very similar to Matlab and Python. This first section will focus on basic Julia syntax.
"

# ╔═╡ c33bb810-eedf-11ea-3ff9-4b089d408ebe
md"#### _Variables_

We can define a variable using `=` (assignment). Then we can use its value in other expressions:"

# ╔═╡ d9b8dc30-eedf-11ea-10d3-8f8523390c57
xx = 2

# ╔═╡ db0e8120-eedf-11ea-1e01-cf0cf662d8da
yy = 6xx

# ╔═╡ f86137e0-eedf-11ea-2960-77f1c0c1c119
md"By default Julia displays the output of the last operation. (You can suppress the output by adding `;` (a semicolon) at the end.)
"

# ╔═╡ 2fc4c0d0-eee0-11ea-17d6-c338f5845682
md" #### _Functions_"

# ╔═╡ 54d56e60-eee0-11ea-24f2-a9e8ad523613
md"We can use a short-form, definition for simple functions:"

# ╔═╡ 90529e40-eee0-11ea-3b53-e3786b2d558a
f(d) = 2 + d

# ╔═╡ a125694e-eee0-11ea-11a9-673b1b987ce7
md"Typing the function's name gives information about the function. To call it we must use parentheses:"

# ╔═╡ ac223770-eee0-11ea-3daf-a9daf48598d7
f

# ╔═╡ b4ef0630-eee0-11ea-06bd-6f89c5e7bd16
f(10)

# ╔═╡ b8d47dc0-eee0-11ea-3969-cb44314f09d4
md"For longer functions we use the following syntax with the `function` keyword and `end`:"

# ╔═╡ c758c4f0-eee0-11ea-0773-810da0ebf5cb
function cart2sphr(x,y,z)
    az = atan(y,x); 
    el = atan(z,sqrt(x^2 + y^2)); 
    r = sqrt(x^2 + y^2 + z^2)
    return az, el, r
end

# ╔═╡ 4168c920-eee1-11ea-3635-378ef85be131
cart2sphr(45555,25533,67000000)

# ╔═╡ 70d10420-eee1-11ea-19d0-dbce252376b3
md"#### _For loops_
Use `for` to loop through a pre-determined set of values:"

# ╔═╡ b5f58440-eee1-11ea-2406-45cab0aab35a
let s = 0
	
	for i in 1:10
		s += i    # Equivalent to s = s + i
	end
	
	s
end

# ╔═╡ cdc7b110-eee1-11ea-27f9-2fd428d8c3b8
md"Here, `1:10` is a **range** representing the numbers from 1 to 10."

# ╔═╡ dfca2280-eee1-11ea-162b-09124642ee3f
md"Above we used a `let` block to define a new local variable `s`. 
But blocks of code like this are usually better inside functions, so that they can be reused. For example, we could rewrite the above as follows:"

# ╔═╡ f8b141be-eee1-11ea-0bdc-db17d4757646
function mysum(n)
	s = 0
	
	for i in 1:n
		s += i    
	end
	
	return s
end

# ╔═╡ 01fc8f50-eee2-11ea-2cd3-27ab5e6ce20b
mysum(500)

# ╔═╡ 620166a0-eee2-11ea-1097-476f7e8e0d8b
md"#### _Conditionals: `if`_
We can evaluate whether a condition is true or not by simply writing the condition:"

# ╔═╡ 816486d0-eee2-11ea-2460-43eeab4efe0e
my_num = 10

# ╔═╡ 8cc016c0-eee2-11ea-07a4-1fc853e5d3f4
my_num > 45

# ╔═╡ a4590b20-eee2-11ea-28c1-4155be27c407
md"We see that conditions have a Boolean (`true` or `false`) value. 

We can then use `if` to control what we do based on that value:"

# ╔═╡ ac98b50e-eee2-11ea-3851-1befb822ec38
if my_num < 5
	"small"
	
else
	"big"
	
end

# ╔═╡ bc9da8d0-eee2-11ea-24f5-95a5ef1f343d
md"""Note that the `if` also returns the last value that was evaluated, in this case the string `"small"` or `"big"`, Since Pluto is reactive, changing the definition of `a` above will automatically cause this to be reevaluated!"""

# ╔═╡ 830a7b90-eca6-11ea-30c5-dfa9a9b4d965
md" #### _Basic Arrays_"

# ╔═╡ 8b42ab70-eca6-11ea-0828-a7fa1cd88119
A = [1 2; 3 4]

# ╔═╡ 91beac60-eca6-11ea-289d-1168c1c37034
md" We see from the above code that you make arrays and matrices the same way as we do in Matlab. We can also index the matrix as we do in Matlab:" 

# ╔═╡ 9ca88ec0-eca6-11ea-16e8-d5a31fb90f2f
A[1,2]

# ╔═╡ b356adf0-eca6-11ea-383b-63ceb28fdbb8
md" #### _An example with an image_
Let's look at something a little more interesting and download an image from the internet. We'll see that an image is really just a large matrix of colors."

# ╔═╡ a52abff0-eca6-11ea-3c51-abefaa6422ab
begin
	url = "https://edgy.app/wp-content/uploads/2018/09/Julia-FI.jpg"
	download(url,"julia_logo.jpg")
	my_logo = load("julia_logo.jpg")
end

# ╔═╡ 0dacfec0-ecad-11ea-0694-0dcd8ba018bc
md" We've loaded an image that we downloaded from the internet. Pretty cool. Let's see wat type 'my_logo' is:"

# ╔═╡ 4a565290-ecad-11ea-0b42-5d47302b1f11
typeof(my_logo)

# ╔═╡ 6a540512-ecad-11ea-0f7e-cd5d5135e96a
md" We can see that an image is just an array of RGB colors as pixels. Because it is an array, we can index it as such. Let's check the size and try it out:"

# ╔═╡ 878f8a50-ecad-11ea-05c6-ddf8beba17fe
size(my_logo) # 2000 by 2000 pixels

# ╔═╡ a36f501e-ecad-11ea-34f4-13556d2517d2
my_logo[1000,1000]

# ╔═╡ e2e02860-ecad-11ea-0f93-d30e04519199
md" Naturally, when we index an array of colors it returns the color that lives at our index. Now what if we took a slice:"

# ╔═╡ 0c6bd6be-ecae-11ea-025f-c7bb8282d2cc
my_logo[1:1000, 1:1500]

# ╔═╡ 22f9c3c0-ecae-11ea-1f35-213150d2fc15
md" As expected, this gives us a nice slice of the image.
Just like any array we can also change the value of the image. Let's try it:"

# ╔═╡ a7a0f672-ecae-11ea-260b-7fcb27b0d0da
begin
	new_logo = copy(my_logo)
	new_logo[1:500,1:750] .= RGB(0,1,0) # Define replacement color
	new_logo
end

# ╔═╡ 31953c70-ecae-11ea-2949-719f2e374ffe
md""" Now the values have been changed to green in the interval that we specified. Let's look more closely at how we accomplished that. We used: 

"new_logo[1:500,1:750] .= RGB(0,1,0)" 

One of the coolest things that Julia brings to the table is a method called **broadcasting**, this is the **".="** operation we did during the color assignment. This method allows for the entry-wise calculation within arrays without the use of a for loop """

# ╔═╡ 80ce62b0-ecb0-11ea-30f8-cfb673dc4cc9
md" #### _Plotting data_
Here we'll make up our own data, put it into a dataframe using DataFrames.jl, and make some plots using the Plots.jl package. You can find documentation for these packages at:

http://docs.juliaplots.org/latest/

https://juliadata.github.io/DataFrames.jl/stable/

Again, you can find great lists of packages for Julia at:
https://juliaobserver.com/packages."

# ╔═╡ f10bc0e0-ecb0-11ea-3ba6-9f0815407df0
begin
	n = 100
	x = 2π * rand(n, 1)
	y = sin.(x[:, 1]) + 0.05*randn(n) + cos.(x[:, 1]) # we use rand to add some noise
end

# ╔═╡ 58e34f82-ecb1-11ea-06d2-1d962ad0a33d
begin
	# putting our generated data into a dataframe
	using DataFrames
	df = [x y] |> DataFrame
	names!(df, [:x, :y]) # rename the columns
end

# ╔═╡ d17f0120-ed8b-11ea-0db5-c52b2291fef3
md" We now have a nicely formatted dataframe that we can reference with dot methods. The DataFrames.jl package acts just like the Pandas package in Python. This means that we can use df.x to outout the x column. This is very useful. 
Now lets try some plots:"

# ╔═╡ 795c08f0-ecb2-11ea-260a-af9c6346f54d
Plots.scatter(df.x,df.y)

# ╔═╡ 3f4ddcf0-ecb3-11ea-2e76-21d52f5d68ed
md" Just like Matlab, its fairly straightforward to make plots. Let's make a few more examples."

# ╔═╡ 23320310-ecb4-11ea-260c-c5b93b1a0d8c
Plots.plot(df.x, df.y)

# ╔═╡ 58848650-ecb4-11ea-0f5f-c995f6f54922
md" We can see that this didnt go very well because of the noise that we added to the original functions. Let's fix that:"

# ╔═╡ 74f604d0-ecb4-11ea-1fba-cbb420c76b5a
# remove the randomness
begin
	x2 = 0:0.1:10*pi # range from 0 to 10pi by 0.1 steps
	y2 = sin.(x2)
	# putting our generated data into a dataframe
	df2 = [x2 y2] |> DataFrame
	names!(df2, [:x, :y]) # rename the columns
end

# ╔═╡ d6059560-ecb4-11ea-3b4d-7faee41c27e8
Plots.plot(df2.x, df2.y)

# ╔═╡ 1b0a14f0-ecb6-11ea-00ba-a965190ef031
md" Now we have a nice smooth curve. Lets try a simple heat map. Heat maps are useful for plotting things like topography and velocity."

# ╔═╡ efd90910-ecb7-11ea-3042-97f61819dee1
begin
	xs = [string("x", i) for i = 1:10]
	ys = [string("y", i) for i = 1:4]
	z = float((1:4) * reshape(1:10, 1, :))
	heatmap(xs, ys, z, aspect_ratio = 1)
end

# ╔═╡ 2640cae2-ecce-11ea-3063-9b121f7eb99a
md" Something cool we can do specifically in the Pluto notebook environment is bind variables to sliders. Let's look at a simple example of this:" 

# ╔═╡ a080b8b0-ecce-11ea-0d07-57f9ecf32846
md"v = $(@bind v Slider(0:20, show_value=true))"

# ╔═╡ 18c19040-ecd1-11ea-2d62-f1a4dc8ebd29
a = 1:0.1:15

# ╔═╡ ed850f80-ecce-11ea-29c0-cbc586063758
w = sin.(a .* pi*v) 

# ╔═╡ 0ebd16c2-eccf-11ea-2a5d-d1d0aa8f3170
Plots.plot(a,w)

# ╔═╡ cadd925e-ecd1-11ea-3a6b-bbfe0ec63bfe
md" Play with the slider to see the function change in real time. This is all made possible by the reactivity of the Pluto notebook. This also means that we have to be careful when we name variables. **Variables in different cells can never be named the same thing.**"

# ╔═╡ ed977d80-ecb7-11ea-392b-470697909b9d
md" Now lets explore all that plots has to offer with a couple of animations from the Plots.jl documentation:"

# ╔═╡ 9058e030-ecb9-11ea-1221-f554216087d2
begin
	default(legend = false)
	xn = yn = range(-5, 5, length = 25)
	zs = zeros(0, 25)
	nn = 100
	
	@gif for i in range(0, stop = 2π, length = nn)
	    f(xn, yn) = sin(xn + 10sin(i)) + cos(yn)
	
	    # create a plot with 3 subplots and a custom layout
	    l = @layout [a{0.7w} b; c{0.2h}]
	    p = Plots.plot(xn, yn, f, st = [:surface, :contourf], layout = l)
	
	    # induce a slight oscillating camera angle sweep, in degrees (azimuth, altitude)
	    Plots.plot!(p[1], camera = (10 * (1 + cos(i)), 25))
	
	    # add a tracking line
	    fixed_x = zeros(25)
	    z = map(f, fixed_x, y)
	    Plots.plot!(p[1], fixed_x, yn, z, line = (:black, 5, 0.2))
	    vline!(p[2], [0], line = (:black, 5))
	
	    # add to and show the tracked values over time
	    global zs = vcat(zs, z')
	    Plots.plot!(p[3], zs, alpha = 0.2, palette = cgrad(:blues).colors)
	end
	
end

# ╔═╡ 961ab8e0-ecb9-11ea-1369-3f80d56aa17e
begin
	# define the Lorenz attractor
	Base.@kwdef mutable struct Lorenz
	    dt::Float64 = 0.02
	    σ::Float64 = 10
	    ρ::Float64 = 28
	    β::Float64 = 8/3
	    x::Float64 = 1
	    y::Float64 = 1
	    z::Float64 = 1
	end
	
	function step!(l::Lorenz)
	    dx = l.σ * (l.y - l.x);         l.x += l.dt * dx
	    dy = l.x * (l.ρ - l.z) - l.y;   l.y += l.dt * dy
	    dz = l.x * l.y - l.β * l.z;     l.z += l.dt * dz
	end
	
	attractor = Lorenz()
	
	
	# initialize a 3D plot with 1 empty series
	plt = Plots.plot3d(
	    1,
	    xlim = (-30, 30),
	    ylim = (-30, 30),
	    zlim = (0, 60),
	    title = "Lorenz Attractor",
	    marker = 2,
	)
	
	# build an animated gif by pushing new points to the plot, saving every 10th frame
	@gif for i=1:1500
	    step!(attractor)
	    push!(plt, attractor.x, attractor.y, attractor.z)
	end every 10
end

# ╔═╡ d233be20-ecba-11ea-2e36-2bbe5a768ba0
md" As we can see from the above examples Julia and the Plots.jl package can offer a lot of versatility! Feel free to play with the above codes to explore the plotting package. "

# ╔═╡ 7afbc020-ecbb-11ea-1329-7b1ba1b54a79
md"## Julia combined with GMT
Now that we have the basics of Julia down, let's experiment with the GMT.jl package. You can find documentation for this at:
https://www.generic-mapping-tools.org/GMT.jl/latest/usage/

We will use elevation data of the western United states at 17 million years ago. Be sure to download this file off of my github page: "

# ╔═╡ 47fc5070-ecc2-11ea-293a-49a67601e3ce
md" First let's read in the elevation data and change the column names."

# ╔═╡ a5d969f0-ecbb-11ea-25ac-23d955b9ef2c
md" Now lets try to plot this data in a heatmap to visualize the topography:"

# ╔═╡ 8be9fe40-ecc2-11ea-26a8-e9dc9b5c0e5c
Plots.heatmap(elev.long, elev.lat, elev.val , c = :balance, title = "Elevation at 17.0 million years ago")

# ╔═╡ 77c3b082-ecc4-11ea-1208-714a9d2b7f0e
md" Hey, thats not right. This happened because the data hasnt been interpolated yet. Let's fix that by using the ScatteredInterpolation.jl package."

# ╔═╡ cd5f5910-ecc2-11ea-225d-f91c77826828
begin
	# Setting the data we have
	samples = elev.val
	points = [elev.long elev.lat]'
	
	# size of the grid
	nz=1000
	# creating the grid
	xz = range(minimum(elev.long), stop = maximum(elev.long), length = n)
	yz = range(minimum(elev.lat), stop = maximum(elev.lat), length = n)
	X = repeat(xz, n)[:]
	Y = repeat(yz', n)[:]
	gridPoints = [X Y]' # finalized grid
	
	#interp and the regrid
	itp = interpolate(NearestNeighbor(), points, samples) # take a nearest neighbor approximation
	interpolated_17_0 = ScatteredInterpolation.evaluate(itp, gridPoints) # calculate for the new grid
	
	Plots.heatmap(xz, yz, interpolated_17_0 , c = :balance, title = "Elevation at 17.0 million years ago")
end

# ╔═╡ f1abba50-ecc4-11ea-195b-59f73bf241a7
md" This looks pretty nice with the Plots.jl package but its quite difficult to set a good color bar for topography. To do this we have to use the GMT.jl package for julia. This packge gives us high-level commands over the usual clunky GMT syntax.

First let's load up the package:"

# ╔═╡ 42a2a810-ecc5-11ea-2a56-2dcb744874ec
md" Now lets get the ranges we need to make our grd file. We'll have to type these in directly to the 'region' argument because GMT.jl doesnt support other objects yet."

# ╔═╡ f0b7a0e0-ecc5-11ea-1060-4b47dda0155d
# lets get the ranges of the data for our grid function

begin
	xmin = minimum(elev.long)
	xmax = maximum(elev.long)
	ymin = minimum(elev.lat)
	ymax = maximum(elev.lat)
	
	# display the information as an array
	[xmin xmax ymin ymax]
end

# ╔═╡ f4ccb3f0-ecc5-11ea-2122-5f33e6ea12ea
md" The GMT module doesnt take DataFrame objets either so we have to convert to an array of long, lat, value."

# ╔═╡ 0de335ae-ecc8-11ea-27c8-2d720d59969d
data = [elev.long elev.lat elev.val]

# ╔═╡ 430a6330-ecc8-11ea-0a6c-8dca2a4dd290
md" Now we're finally ready to make our grid file! Don't panic if this takes a minute or two, these are heavy duty calculations."

# ╔═╡ 602f7a40-ecc8-11ea-1056-0b003cf04d7f
# now we can make our grid file
GMT.surface(data, region = (-125.724, -103.234, 25.3, 43.2533), # this must be int/float
                  tension = 0.1, # smoothing effect
                  inc = "1n", # makes GMT figure out the increment
                  verbose = true, # prints to the REPL
                  outgrid = "elev_17_0.nc") #output to a grid file
# this will take some time to compute. Can crash if you dont have enough ram

# ╔═╡ 5e4e5e30-ecc8-11ea-37cb-25d52f607106
md" After we have the grid file we can create a custom cpt file so that our colors are accurate and based upon the data we are working with.

This references the grid file we've just created so be sure that everything is in the same directory or that the paths are specified."

# ╔═╡ db78c1c0-ecc8-11ea-39a5-31b262978c86
# lets create a cpt file based on the values of our grid file
# see the GMT documentation for a list of colors
topo_17_0 = grd2cpt("elev_17_0.nc", cmap=:geo, continuous=true)

# ╔═╡ 24bb2e90-ecc9-11ea-340f-359aa543c229
md" Now everything is in place for us to create our 2d map of the elevation."

# ╔═╡ 61405890-ecc9-11ea-1016-cb5883ab35ee
# Now we can build the 2d plot of our data
GMT.grdimage("elev_17_0.nc", proj = :Mercator, # can use albers conic
		frame = (annot = :auto, axes = :WSne), # automatic axes generation
        color = topo_17_0, # pick .cpt
        colorbar = (topo_17_0, pos=(anchor=:RM), xaxis=(annot=1500, label=                     		"Topography (m)") ), # makes colorbar and anchors it to the                             right-middle of our figure
		title = "Topography at 17.0 ma", 
        show = true,
        fmt = :jpg) # outputs as a jpeg

# this will take some time

# ╔═╡ 86e074e0-ecc9-11ea-2204-f551d9cd17a5
md" **Let's go through what all these pieces of the grdimage function mean.** 

First, we input the name of the grid file. proj is the type of map projection we want to use. 

_frame_ represents the boundaries of the plot that we want included. Here, we specify that the annotations be created automatically and tht we only want the West and South boundaries annotated  

_color_ is where we specify the cpt we want to use for the plot

_colorbar_ is where we configure the appearance of the map adjacent colorbar. We specify that we want to use our generated cpt, the position of the bar, and the annotations associated with it.

_title_ is where we set the plot title.

_show_ = true means that we want the figure to pop-up when its done.

and _fmt_ is where we set the output of the plot. In this case it is set to jpeg.

More Specific documentation can be found on the GMT.jl github page."

# ╔═╡ ce3e74ce-ecca-11ea-2799-73372fd58c2a
md" **We can also make a 3d image using many of the same parameters as above with the gridview function:** This 3d calculation will take a few minutes to run." 

# ╔═╡ e5a73170-ecca-11ea-39d8-5958ddc36220
# We can also now build our 3d image
GMT.grdview("elev_17_0.nc", proj =:Mercator, # can use albers conic
		frame = (annot = :auto, axes = :ESnwZ), # set the axes you want to be labeled
    	zaxis = (annot = 8000, label = "Topo (m)"), # customizing the z axis
        zsize = "1i", # scaling zaxis
        #zscale = 2,
        shade = (azim=225, norm = "e0.3"), 
        view = (135,30), # angle of view
        #xaxis = (label = "Longitude"), # use if you want axis labels    
        #yaxis = (label = "Latitude"),
        title = "Topography at 17.0 ma",
        color = topo_17_0, # set you .cpt file
        fmt = :jpg, # shows as a jpg
        surf = (surface = true, image = true), # plots a surface
        #smooth = 20,
        show = true)

# ╔═╡ 1d22af30-eccb-11ea-1488-17e71f564999
md" **The new arguments here are:**

_zaxis_ and _zsize_, these set features of the zaxis. I recommend using zsize = '1i' because that has GMT figure out the increment value for you.

_shade_ to set the lighting on the 3d plot,

_view_ to set the angle of the camera,

and _surf_ to specify that we want a surface to be plotted instead of a mesh or other object."

# ╔═╡ Cell order:
# ╠═5cf640b0-eca6-11ea-0b86-2d8c4869e0c7
# ╟─62887de0-eca6-11ea-2fea-0f79ebe77675
# ╠═7cd40f20-eca6-11ea-2670-c7ce3983da4a
# ╟─c33bb810-eedf-11ea-3ff9-4b089d408ebe
# ╠═d9b8dc30-eedf-11ea-10d3-8f8523390c57
# ╠═db0e8120-eedf-11ea-1e01-cf0cf662d8da
# ╟─f86137e0-eedf-11ea-2960-77f1c0c1c119
# ╟─2fc4c0d0-eee0-11ea-17d6-c338f5845682
# ╟─54d56e60-eee0-11ea-24f2-a9e8ad523613
# ╠═90529e40-eee0-11ea-3b53-e3786b2d558a
# ╟─a125694e-eee0-11ea-11a9-673b1b987ce7
# ╠═ac223770-eee0-11ea-3daf-a9daf48598d7
# ╠═b4ef0630-eee0-11ea-06bd-6f89c5e7bd16
# ╟─b8d47dc0-eee0-11ea-3969-cb44314f09d4
# ╠═c758c4f0-eee0-11ea-0773-810da0ebf5cb
# ╠═4168c920-eee1-11ea-3635-378ef85be131
# ╟─70d10420-eee1-11ea-19d0-dbce252376b3
# ╠═b5f58440-eee1-11ea-2406-45cab0aab35a
# ╟─cdc7b110-eee1-11ea-27f9-2fd428d8c3b8
# ╟─dfca2280-eee1-11ea-162b-09124642ee3f
# ╠═f8b141be-eee1-11ea-0bdc-db17d4757646
# ╠═01fc8f50-eee2-11ea-2cd3-27ab5e6ce20b
# ╟─620166a0-eee2-11ea-1097-476f7e8e0d8b
# ╠═816486d0-eee2-11ea-2460-43eeab4efe0e
# ╠═8cc016c0-eee2-11ea-07a4-1fc853e5d3f4
# ╟─a4590b20-eee2-11ea-28c1-4155be27c407
# ╠═ac98b50e-eee2-11ea-3851-1befb822ec38
# ╟─bc9da8d0-eee2-11ea-24f5-95a5ef1f343d
# ╟─830a7b90-eca6-11ea-30c5-dfa9a9b4d965
# ╠═8b42ab70-eca6-11ea-0828-a7fa1cd88119
# ╟─91beac60-eca6-11ea-289d-1168c1c37034
# ╠═9ca88ec0-eca6-11ea-16e8-d5a31fb90f2f
# ╟─b356adf0-eca6-11ea-383b-63ceb28fdbb8
# ╠═a52abff0-eca6-11ea-3c51-abefaa6422ab
# ╟─0dacfec0-ecad-11ea-0694-0dcd8ba018bc
# ╠═4a565290-ecad-11ea-0b42-5d47302b1f11
# ╟─6a540512-ecad-11ea-0f7e-cd5d5135e96a
# ╠═878f8a50-ecad-11ea-05c6-ddf8beba17fe
# ╠═a36f501e-ecad-11ea-34f4-13556d2517d2
# ╟─e2e02860-ecad-11ea-0f93-d30e04519199
# ╠═0c6bd6be-ecae-11ea-025f-c7bb8282d2cc
# ╟─22f9c3c0-ecae-11ea-1f35-213150d2fc15
# ╠═a7a0f672-ecae-11ea-260b-7fcb27b0d0da
# ╟─31953c70-ecae-11ea-2949-719f2e374ffe
# ╟─80ce62b0-ecb0-11ea-30f8-cfb673dc4cc9
# ╠═f10bc0e0-ecb0-11ea-3ba6-9f0815407df0
# ╠═58e34f82-ecb1-11ea-06d2-1d962ad0a33d
# ╟─d17f0120-ed8b-11ea-0db5-c52b2291fef3
# ╠═3beb6750-eccf-11ea-2142-b95f7e1a3e24
# ╠═795c08f0-ecb2-11ea-260a-af9c6346f54d
# ╟─3f4ddcf0-ecb3-11ea-2e76-21d52f5d68ed
# ╠═23320310-ecb4-11ea-260c-c5b93b1a0d8c
# ╟─58848650-ecb4-11ea-0f5f-c995f6f54922
# ╠═74f604d0-ecb4-11ea-1fba-cbb420c76b5a
# ╠═d6059560-ecb4-11ea-3b4d-7faee41c27e8
# ╟─1b0a14f0-ecb6-11ea-00ba-a965190ef031
# ╠═efd90910-ecb7-11ea-3042-97f61819dee1
# ╠═2640cae2-ecce-11ea-3063-9b121f7eb99a
# ╠═4a8e9da0-ecce-11ea-322c-0ba8ab801500
# ╠═a080b8b0-ecce-11ea-0d07-57f9ecf32846
# ╠═18c19040-ecd1-11ea-2d62-f1a4dc8ebd29
# ╠═ed850f80-ecce-11ea-29c0-cbc586063758
# ╠═0ebd16c2-eccf-11ea-2a5d-d1d0aa8f3170
# ╟─cadd925e-ecd1-11ea-3a6b-bbfe0ec63bfe
# ╟─ed977d80-ecb7-11ea-392b-470697909b9d
# ╠═9058e030-ecb9-11ea-1221-f554216087d2
# ╠═961ab8e0-ecb9-11ea-1369-3f80d56aa17e
# ╟─d233be20-ecba-11ea-2e36-2bbe5a768ba0
# ╠═7afbc020-ecbb-11ea-1329-7b1ba1b54a79
# ╟─47fc5070-ecc2-11ea-293a-49a67601e3ce
# ╠═a7e00f60-ecbb-11ea-00f7-673a16c2723e
# ╟─a5d969f0-ecbb-11ea-25ac-23d955b9ef2c
# ╠═8be9fe40-ecc2-11ea-26a8-e9dc9b5c0e5c
# ╟─77c3b082-ecc4-11ea-1208-714a9d2b7f0e
# ╠═964e1960-ecc3-11ea-38ea-d329c41a1640
# ╠═cd5f5910-ecc2-11ea-225d-f91c77826828
# ╟─f1abba50-ecc4-11ea-195b-59f73bf241a7
# ╠═27b335ae-ecc5-11ea-325e-5d9416eb19e4
# ╟─42a2a810-ecc5-11ea-2a56-2dcb744874ec
# ╠═f0b7a0e0-ecc5-11ea-1060-4b47dda0155d
# ╟─f4ccb3f0-ecc5-11ea-2122-5f33e6ea12ea
# ╠═0de335ae-ecc8-11ea-27c8-2d720d59969d
# ╟─430a6330-ecc8-11ea-0a6c-8dca2a4dd290
# ╠═602f7a40-ecc8-11ea-1056-0b003cf04d7f
# ╟─5e4e5e30-ecc8-11ea-37cb-25d52f607106
# ╠═db78c1c0-ecc8-11ea-39a5-31b262978c86
# ╠═24bb2e90-ecc9-11ea-340f-359aa543c229
# ╠═61405890-ecc9-11ea-1016-cb5883ab35ee
# ╟─86e074e0-ecc9-11ea-2204-f551d9cd17a5
# ╟─ce3e74ce-ecca-11ea-2799-73372fd58c2a
# ╠═e5a73170-ecca-11ea-39d8-5958ddc36220
# ╟─1d22af30-eccb-11ea-1488-17e71f564999
