module Spectral
    import Images, ImageView
    import Plots
    using LinearAlgebra

    function linearizeSRGB(x)
        float(x <= 0.04045 ? x / 12.92 : ((x + 0.055) / 1.055) ^ 2.4)
    end

    function getVector(p1, p2)
        p0 = CartesianIndex(p1[1], p1[2])
        p1 = CartesianIndex(p2[1], p2[2])
        vec = (p1 - p0)
        mag = round(Int, norm([vec[1], vec[2]]))
        slice = map(1:mag) do i
            x = p0[1] + round(Int, i * vec[1] / mag)
            y = p0[2] + round(Int, i * vec[2] / mag)
            CartesianIndex(x, y)
        end
        return slice
    end

    function plotSpectrum(spectrum::Vector{Images.ColorTypes.RGB})
        blue = [linearizeSRGB(pixel.b) for pixel in spectrum]
        green = [linearizeSRGB(pixel.g) for pixel in spectrum]
        red = [linearizeSRGB(pixel.r) for pixel in spectrum]
        intensity = blue .+ green .+ red
    
        plt = Plots.plot(eachindex(blue), intensity, label="Intensity", color = :black)
        Plots.plot!(eachindex(blue), blue, label="Blue", color = :blue)
        Plots.plot!(eachindex(blue), green, label="Green", color = :green)
        Plots.plot!(eachindex(blue), red, label="Red", color = :red)
        display(plt)
    end

    function plotSpectrum(frames::Vector{Vector{Images.ColorTypes.RGB{Images.FixedPointNumbers.N0f8}}})
        blue  = [sum(frame -> linearizeSRGB(frame[idx].b), frames) for idx in eachindex(frames[1])]
        green = [sum(frame -> linearizeSRGB(frame[idx].g), frames) for idx in eachindex(frames[1])]
        red   = [sum(frame -> linearizeSRGB(frame[idx].r), frames) for idx in eachindex(frames[1])]
        intensity = blue .+ green .+ red
    
        plt = Plots.plot(eachindex(blue), intensity, label="Intensity", color = :black)
        Plots.plot!(eachindex(blue), blue, label="Blue", color = :blue)
        Plots.plot!(eachindex(blue), green, label="Green", color = :green)
        Plots.plot!(eachindex(blue), red, label="Red", color = :red)
        display(plt)
    end

    function getSpectrum(imgLocation::Union{Vector{String}, String})
        if isfile(imgLocation)
            img = Images.load(imgLocation)
        elseif isdir(imgLocation)
            files = String[]
            foreach(vals -> files = map(file -> joinpath(first(vals), file), last(vals)), walkdir(imgLocation))
            img = Images.load(first(files))
            println("This is assuming that the chosen vector is be the same for all images")
        elseif imgLocation isa Vector{String}
            img = Images.load(first(imgLocation))
            println("This is assuming that the chosen vector is be the same for all images")
        else
            println("File not found")
            return
        end
        ImageView.imshow(img)
        println("Enter the coordinates of the first point x, y: ")
        p1 = CartesianIndex(parse.(Int, split(readline(), ", "))...)
        println("Enter the coordinates of the second point x, y: ")
        p2 = CartesianIndex(parse.(Int, split(readline(), ", "))...)
    
        slice = getVector(p1, p2)
        if isfile(imgLocation)
            spectrum = img[slice]
        elseif isdir(imgLocation)
            spectrum = map(imgFile -> Images.load(imgFile)[slice], files)
        elseif imgLocation isa Vector{String}
            spectrum = map(imgFile -> Images.load(imgFile)[slice], imgLocation)
        end
        plotSpectrum(spectrum)
    end

    function getSpectrum(imgLocations::Vector{String})
        img = averageImages(imgLocations)

        println("Enter the coordinates of the first point x, y: ")
        p1 = CartesianIndex(parse.(Int, split(readline(), ", "))...)
        println("Enter the coordinates of the second point x, y: ")
        p2 = CartesianIndex(parse.(Int, split(readline(), ", "))...)
    
        slice = getVector(p1, p2)
        plotSpectrum(img[slice])
    end

    function averageImages(images::Vector{String})
        averageImage = sum(img -> Images.load(img) ./ length(images), images)
        ImageView.imshow(averageImage)
        return averageImage
    end
    export getSpectrum, averageImages
end