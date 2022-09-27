module PSP8

using LinearAlgebra

export parse_psp8

parse_fortran(::Type{T}, x::AbstractString) where {T <: Real} = parse(T, replace(lowercase(x), "d" => "e"))

function parse_header!(io, psp)
    header = Dict()
    
    # line 1: title
    header["title"] = readline(io)              # title (unused)
    
    # line 2: atomic number, pseudo-ion charge, date
    s = split(readline(io))
    header["z_atom"] = parse_fortran(Float64, s[1])            # zatom
    header["z_valence"] = parse_fortran(Float64, s[2])          # zion
    header["generation_day"] = parse(Int, s[3][1:2])    # pspd (unused)
    header["generation_month"] = parse(Int, s[3][3:4])
    header["generation_year"] = parse(Int, s[3][5:6])
    
    # line 3
    s = split(readline(io))
    header["format_version"] = parse(Int, s[1]) # pspcod == 8
    header["xc"] = parse(Int, s[2])             # pspxc
    header["l_max"] = parse(Int, s[3])          # lmax
    header["l_local"] = parse(Int, s[4])        # lloc
    header["mesh_size"] = parse(Int, s[5])      # mmax
    header["r2well"] = parse(Int, s[6])         # r2well (unused)
    @assert header["format_version"] == 8

    # line 4
    s = split(readline(io))
    header["rchrg"] = parse_fortran(Float64, s[1])       # rchrg
    header["fchrg"] = parse_fortran(Float64, s[2])       # fchrg
    header["qchrg"] = parse_fortran(Float64, s[3])       # qchrg (unused)
    header["core_correction"] = header["fchrg"] > 0.0

    # line 5: number of scalar-relativistic non-local
    # projectors for each angular momentum (l = 0:l_max)
    s = split(readline(io))
    header["number_of_proj"] = [parse(Int, s[i]) for i = 1:header["l_max"]+1]
    if header["l_local"] <= header["l_max"]
        @assert header["number_of_proj"][header["l_local"]+1] == 0
    end

    # line 6: data extension information
    s = split(readline(io))
    header["extension_switch"] = parse(Int, s[1])
    header["has_so"] = header["extension_switch"] in [2, 3]

    if header["has_so"]
        # line 7: number of projectors for each spin-orbit
        # non-local projectors for each angular momentum (l = 1:l_max)
        s = split(readline(io))
        header["number_of_proj_so"] = [parse(Int, s[i]) for i = 1:header["l_max"]]
    else
        header["number_of_proj_so"] = []
    end

    psp["header"] = header
end

function parse_beta_projector(io, psp)
    header_line = split(readline(io))
    l = parse(Int, header_line[1])
    n_proj_l = psp["header"]["number_of_proj"][l + 1]
    ekb = [parse_fortran(Float64, header_line[i+1]) for i = 1:n_proj_l]
    
    radial_grid = Vector{Float64}(undef, psp["header"]["mesh_size"])
    betas = [Vector{Float64}(undef, psp["header"]["mesh_size"]) for i = 1:(n_proj_l)]
    for i = 1:psp["header"]["mesh_size"]
        s = split(readline(io))
        radial_grid[i] = parse_fortran(Float64, s[2])
        for j = 1:n_proj_l
            betas[j][i] = parse_fortran(Float64, s[2+j])
        end
    end

    return Dict(
        "angular_momentum" => l,
        "radial_grid" => radial_grid,
        "radial_functions" => betas,
        "ekb" => ekb
    )
end

function parse_local(io, psp)
    header_line = split(readline(io))
    l = parse(Int, header_line[1])

    radial_grid = Vector{Float64}(undef, psp["header"]["mesh_size"])
    v_local = Vector{Float64}(undef, psp["header"]["mesh_size"])
    for i = 1:psp["header"]["mesh_size"]
        s = split(readline(io))
        radial_grid[i] = parse_fortran(Float64, s[2])
        v_local[i] = parse_fortran(Float64, s[3])
    end
    return Dict(
        "angular_momentum" => l,
        "radial_grid" => radial_grid,
        "local_potential" => v_local
    )
end

function parse_betas_dij_local!(io, psp)
    beta_blocks = []
    v_local_block = Dict()
    if psp["header"]["l_max"] < psp["header"]["l_local"]
        n_blocks = psp["header"]["l_max"] + 2
    else
        n_blocks = psp["header"]["l_max"] + 1
    end
    for i = 1:n_blocks
        # Record the position at the start of the block so we can
        # read in the first line and go back
        block_head = position(io)
        # Read the block header
        block_header_line = split(readline(io))
        # Go back to the start of the block
        seek(io, block_head)
        # Parse the block's `l`
        block_l = parse(Int, block_header_line[1])

        if block_l == psp["header"]["l_local"]
            v_local_block = parse_local(io, psp)
        else
            beta_block = parse_beta_projector(io, psp)
            push!(beta_blocks, beta_block)
        end
    end

    beta_projectors = [
        Dict(
            "radial_functions" => beta["radial_functions"],
            "angular_momentum" => beta["angular_momentum"],
        ) for beta in beta_blocks
    ]

    Dij = Float64[]
    for beta_block in beta_blocks
        for dii in beta_block["ekb"]
            push!(Dij, dii)
        end
    end
    Dij = collect(Diagonal(Dij))

    psp["radial_grid"] = v_local_block["radial_grid"]
    psp["local_potential"] = v_local_block["local_potential"]
    psp["beta_projectors"] = beta_projectors
    psp["D_ion"] = Dij

    # return Dict(
    #     "radial_grid" => v_local_block["radial_grid"],
    #     "local_potential" => v_local_block["local_potential"],
    #     "beta_projectors" => beta_projectors,
    #     "D_ion" => Dij
    # )
end

function parse_spin_orbit!(io, psp)
    if psp["header"]["has_so"]
        beta_blocks = []
        for i = 1:psp["header"]["l_max"]  # l = 1:l_max
            beta_block = parse_beta_projector(io, psp)
            push!(beta_blocks, beta_block)
        end
    
        beta_projectors = [
            Dict(
                "radial_functions" => beta["radial_functions"],
                "angular_momentum" => beta["angular_momentum"],
            ) for beta in beta_blocks
        ]
    
        Dij = Float64[]
        for beta_block in beta_blocks
            for dii in beta_block["ekb"]
                push!(Dij, dii)
            end
        end
        Dij = collect(Diagonal(Dij))

        psp["spin_orbit"] = Dict(
            "beta_projectors" => beta_projectors,
            "D_ion" => Dij
        )
    else
        psp["spin_orbit"] = Dict()
    end
end

function parse_nlcc!(io, psp)
    if psp["header"]["core_correction"]
        mesh_size = psp["header"]["mesh_size"]
        radial_grid = Vector{Float64}(undef, mesh_size)
        rho = Vector{Float64}(undef, mesh_size)
        drho = Vector{Float64}(undef, mesh_size)
        d2rho = Vector{Float64}(undef, mesh_size)
        d3rho = Vector{Float64}(undef, mesh_size)
        d4rho = Vector{Float64}(undef, mesh_size)
        for i = 1:mesh_size
            s = split(readline(io))
            radial_grid[i] = parse_fortran(Float64, s[2])
            rho[i] = parse_fortran(Float64, s[3]) / (4π)
            drho[i] = parse_fortran(Float64, s[4])
            d2rho[i] = parse_fortran(Float64, s[5])
            d3rho[i] = parse_fortran(Float64, s[6])
            d4rho[i] = parse_fortran(Float64, s[7])
        end

        nlcc = Dict(
            "core_charge_density" => rho,
            "first_derivative" => drho,
            "second_derivative" => d2rho,
            "third_derivative" => d4rho,
            "fourth_derivative" => d4rho
        )
    else
        nlcc = Dict()
    end
    
    psp["nlcc"] = nlcc

    # return Dict(
    #     "radial_grid" => radial_grid,
    #     "rho" => rho,
    #     "drho" => drho,
    #     "d2rho" => d2rho,
    #     "d3rho" => d3rho,
    #     "d4rho" => d4rho
    # )
end

function parse_psp8(io)
    psp = Dict()

    parse_header!(io, psp)
    parse_betas_dij_local!(io, psp)
    parse_spin_orbit!(io, psp)
    parse_nlcc!(io, psp)

    return psp
end
end