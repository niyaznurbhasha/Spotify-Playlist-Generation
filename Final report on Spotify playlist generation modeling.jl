using DataFrames, CSV, NamedArrays

# Transform dataframe to relevant named arrays

df = CSV.read("total_data.csv", header = true, delim = ',')
#features = propertynames(df)

songs = convert(Array,df[1:end,2]) 

art = convert(Array, df[1:end,3])
artist = Dict(zip(songs, art))

pop = convert(Array,df[1:end,4]) 
popularity = Dict(zip(songs, pop)) 

dur = convert(Array,df[1:end,5])
duration = Dict(zip(songs,dur))

dance = convert(Array,df[1:end,6]) 
danceability = Dict(zip(songs,dance))

en = convert(Array,df[1:end,7]) 
energy = Dict(zip(songs,en))

tem = convert(Array,df[1:end,8]) 
tempo = Dict(zip(songs,en))

loud = convert(Array,df[1:end,9]) 
loudness = Dict(zip(songs,loud))

val = convert(Array,df[1:end,10]) 
valence = Dict(zip(songs,val))

ac = convert(Array,df[1:end,11]) 
acousticness = Dict(zip(songs,ac))

ins = convert(Array,df[1:end,12]) 
instrumentalness = Dict(zip(songs,ins))

speech = convert(Array,df[1:end,13])
speechiness = Dict(zip(songs,speech))

exp = convert(Array,df[1:end,14])
explicit = Dict(zip(songs,exp))

#using NamedArrays
#song_feature_matrix = convert(Matrix,df[1:end,2:end])
#song_feature_array = NamedArray(song_feature_matrix, (songs, features), ("songs", "features"))

# Model for generating high-energy playlists for working out/partying

using JuMP, Gurobi

m = Model(Gurobi.Optimizer) 
@variable(m, x[songs], Bin)# create blank list of songs, becomes optimal playlist 

@objective(m, Max, sum(x[i]*popularity[i] for i in songs)) #maximize the sum of popularity scores among songs

@constraint(m, length, sum(duration[i]*x[i] for i in songs) <= 3.6e6)
@constraint(m, length2, sum(duration[i]*x[i] for i in songs) >= 1.8e6) # playlist between 30 and 60 minutes
@constraint(m, length3[i in songs], duration[i]*x[i] >= 90000 * x[i]) # individual song must be 1.5 minutes

@constraint(m, dance1[i in songs], x[i] * danceability[i] >= 0.66 * x[i]) # because of normal distribution
@constraint(m, energy1[i in songs], x[i] * energy[i] >= 0.75 * x[i]) # right skew 
@constraint(m, tempo1[i in songs], x[i] * tempo[i] >= 0.66 * x[i])


optimize!(m)
println(objective_value(m))
println("")
for i in songs
    if value(x[i]) != 0
        println(i, " by ", artist[i], "  ", round(duration[i] * 1.66667e-5,digits = 1), " minutes ", popularity[i], " popularity score")
    end
end

# Model for generating high-energy playlists for working out/partying

using JuMP, Gurobi

m = Model(Gurobi.Optimizer) 
@variable(m, x[songs], Bin)# create blank list of songs, becomes optimal playlist 

@objective(m, Max, sum(x[i]*popularity[i] for i in songs)) #maximize the sum of popularity scores among songs

@constraint(m, length, sum(duration[i]*x[i] for i in songs) <= 3.6e6)
@constraint(m, length2, sum(duration[i]*x[i] for i in songs) >= 1.8e6) # playlist between 30 and 60 minutes
@constraint(m, length3[i in songs], duration[i]*x[i] >= 90000 * x[i]) # individual song must be 1.5 minutes

@constraint(m, dance1[i in songs], x[i] * danceability[i] >= 0.66 * x[i]) # because of normal distribution
@constraint(m, energy1[i in songs], x[i] * energy[i] >= 0.75 * x[i]) # right skew 
@constraint(m, valence1[i in songs], x[i] * valence[i] >= 0.5 * x[i]) #positive music
@constraint(m, tempo1[i in songs], x[i] * tempo[i] >= 0.66 * x[i])


optimize!(m)
println(objective_value(m))
println("")
for i in songs
    if value(x[i]) != 0
        println(i, " by ", artist[i], "  ", round(duration[i] * 1.66667e-5,digits = 1), " minutes ", popularity[i], " popularity score")
    end
end

# Model for generating low-energy playlists for studying

using JuMP, Gurobi

m = Model(Gurobi.Optimizer) 
@variable(m, x[songs], Bin)# create blank list of songs, becomes optimal playlist 

@objective(m, Max, sum(x[i]*popularity[i] for i in songs)) #maximize the sum of popularity scores among songs



@constraint(m, length, sum(duration[i]*x[i] for i in songs) <= 3.6e6)
@constraint(m, length2, sum(duration[i]*x[i] for i in songs) >= 1.8e6) # playlist between 30 and 60 minutes
@constraint(m, length3[i in songs], duration[i]*x[i] >= 90000 * x[i]) # individual song must be 1.5 minutes


@constraint(m, acoustic1[i in songs], x[i] * acousticness[i] >= 0.33 * x[i]) # because of left skew
@constraint(m, inst1[i in songs], x[i] * instrumentalness[i] >= 0.2 * x[i]) # majority of values < 0.2
@constraint(m, dance2[i in songs], x[i] * danceability[i] <= 0.66 * x[i])
@constraint(m, loudness2[i in songs], x[i] * loudness[i] <= 0.75 * x[i])
@constraint(m, energy2[i in songs], x[i] * energy[i] <= 0.75 * x[i])
@constraint(m, speech[i in songs], x[i] * speechiness[i] <= 0.33 * x[i])
@constraint(m, tempo2[i in songs], x[i] * tempo[i] <= 0.66 * x[i])



optimize!(m)
println(objective_value(m))
println("")
for i in songs
    if value(x[i]) != 0
        println(i, "  by ", artist[i], "  ", round(duration[i] * 1.66667e-5,digits = 1), " minutes  ", popularity[i], " popularity score")
    end
end

# Model for generating low-energy playlists for studying

using JuMP, Gurobi

m = Model(Gurobi.Optimizer) 
@variable(m, x[songs], Bin)# create blank list of songs, becomes optimal playlist 

@objective(m, Max, sum(x[i]*popularity[i] for i in songs)) #maximize the sum of popularity scores among songs



@constraint(m, length, sum(duration[i]*x[i] for i in songs) <= 3.6e6)
@constraint(m, length2, sum(duration[i]*x[i] for i in songs) >= 1.8e6) # playlist between 30 and 60 minutes
@constraint(m, length3[i in songs], duration[i]*x[i] >= 90000 * x[i]) # individual song must be 1.5 minutes


@constraint(m, acoustic1[i in songs], x[i] * acousticness[i] >= 0.33 * x[i]) # because of left skew
@constraint(m, inst1[i in songs], x[i] * instrumentalness[i] >= 0.2 * x[i]) # majority of values < 0.2
@constraint(m, dance2[i in songs], x[i] * danceability[i] <= 0.5 * x[i])
@constraint(m, loudness2[i in songs], x[i] * loudness[i] <= 0.66 * x[i])
@constraint(m, energy2[i in songs], x[i] * energy[i] <= 0.66 * x[i])
@constraint(m, speech[i in songs], x[i] * speechiness[i] <= 0.33 * x[i])
@constraint(m, tempo2[i in songs], x[i] * tempo[i] <= 0.5 * x[i])
@constraint(m, valence2[i in songs], x[i] * valence[i] >= 0.5 * x[i]) #positive tones



optimize!(m)
println(objective_value(m))
println("")
for i in songs
    if value(x[i]) != 0
        println(i, "  by ", artist[i], "  ", round(duration[i] * 1.66667e-5,digits = 1), " minutes  ", popularity[i], " popularity score")
    end
end

#reads in user songs and returns an optimal playlist given a lambda value for solve opt function. 

using JuMP, Gurobi

df2 = CSV.read("user_data.csv", header = true, delim = ',')
user_songs = convert(Array,df2[1:end,2]) 
z = zeros(Int32,54102)
a = size(songs)

for i in 1:a[1]
    if songs[i] in user_songs
        z[i] = 1
    end
end
     
user_songs_bin = Dict(zip(songs,z))

function solveOpt(λ)

    m = Model(Gurobi.Optimizer)

    @variable(m, alg_songs[songs],Bin) # songs produced by algorithm 

    @objective(m, Min, sum(alg_songs[i]*popularity[i] for i in songs)
        +
        λ*sum((user_songs_bin[i] - alg_songs[i])^2 for i in songs)
    )
    
    @constraint(m, length, sum(duration[i]*alg_songs[i] for i in songs) <= 3.6e6)
    @constraint(m, length2, sum(duration[i]*alg_songs[i] for i in songs) >= 1.8e6)


    optimize!(m)

    y1 = value(sum(alg_songs[i]*popularity[i] for i in songs))
    
    y2 = value(sum((user_songs_bin[i] - alg_songs[i])^2 for i in songs))
    
    xopt = value.(alg_songs)

    c = 0
    for i in xopt
        c = c+1
        if i > 0
            println(songs[c])
        end
    end
    #return (y1,y2,xopt)

end

;

print(solveOpt(0))

print(solveOpt(0.1))

print(solveOpt(0.3))

print(solveOpt(0.5))

print(solveOpt(0.7))

print(solveOpt(0.9))

print(solveOpt(1))
