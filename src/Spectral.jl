module Spectral
    import Images, ImageView
    import Plots

    function linearizeSRGB(x)
        float(x <= 0.04045 ? x / 12.92 : ((x + 0.055) / 1.055) ^ 2.4)
    end

    function getVector(img, p1, p2)
        m = (p2[2] - p1[2]) / (p2[1] - p1[1])
        pixels = [CartesianIndex(pixel + p1[1], round(Int, m * pixel, RoundDown) + p1[2]) for pixel in (p2[1] - p1[1]):-1:0]
        return img[pixels]
    end

    function plotSpectrum(spectrum)
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

    function getSpectrum(imgLocation::Union{Vector{String}, String})
        if isfile(imgLocation)
            img = Images.load(imgLocation)
        elseif isdir(imgLocation)
            files = String[]
            foreach(vals -> files = map(file -> joinpath(first(vals), file), last(vals)), walkdir(imgLocation))
            img = averageImages(files)
        elseif imgLocation isa Vector{String}
            img = averageImages(imgLocation)
        else
            println("File not found")
            return
        end
        ImageView.imshow(img)

        println("Enter the coordinates of the first point x, y: ")
        p1 = CartesianIndex(parse.(Int, split(readline(), ", "))...)
        println("Enter the coordinates of the second point x, y: ")
        p2 = CartesianIndex(parse.(Int, split(readline(), ", "))...)
    
        spectrum = getVector(img, p1, p2)
        plotSpectrum(spectrum)
    end

    function getSpectrum(imgLocations::Vector{String})
        img = averageImages(imgLocations)

        println("Enter the coordinates of the first point x, y: ")
        p1 = CartesianIndex(parse.(Int, split(readline(), ", "))...)
        println("Enter the coordinates of the second point x, y: ")
        p2 = CartesianIndex(parse.(Int, split(readline(), ", "))...)
    
        spectrum = getVector(img, p1, p2)
        plotSpectrum(spectrum)
    end

    function averageImages(images::Vector{String})
        averageImage = sum(img -> Images.load(img) ./ length(images), images)
        ImageView.imshow(averageImage)
        return averageImage
    end
    export getSpectrum, averageImages
end