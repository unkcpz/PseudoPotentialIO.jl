"""
UPF `<PP_HEADER>`
"""
struct UpfHeader <: PsPFile
    "Generation code"
    generated::Union{Nothing,String}
    author::Union{Nothing,String}
    "Generation date"
    date::Union{Nothing,String}
    comment::Union{Nothing,String}
    "A valid chemical symbol: `{H, He, Li, ..., Og}`"
    element::String
    "A valid type of pseudopotential: `{NC, SL, 1/r, US, PAW, USPP}`"
    pseudo_type::String
    "A valid relativistic treatment: `{scalar, full, relativistic}`"
    relativistic::Union{Nothing,String}
    is_ultrasoft::Bool
    is_paw::Bool
    "True of the pseudopotential is just a bare Coulomb potential (all-electron)"
    is_coulomb::Bool
    "True if fully-relativistic with spin-orbit terms"
    has_so::Bool
    "True if all-electron wavefunctions present"
    has_wfc::Bool
    "True if data for GIPAW reconstruction is present"
    has_gipaw::Bool
    "True if data for GIPAW reconstruction is present"
    paw_as_gipaw::Union{Nothing,Bool}
    "True if non-linear core correction is included"
    core_correction::Bool
    "QuantumEspresso exchange-correlation identifier"
    functional::String
    "Pseudo-atomic charge"
    z_valence::Float64
    "Total pseudo-valence energy of the pseudopotential"
    total_psenergy::Union{Nothing,Float64}
    "Suggested plane wave cutoff for expansion of Kohn-Sham orbitals"
    wfc_cutoff::Union{Nothing,Float64}
    "Suggested plane wave cutoff for expansion of charge density"
    rho_cutoff::Union{Nothing,Float64}
    "Maximum angular momentum channel in the pseudopotential"
    l_max::Int
    "Maximum angular momentum channel in the atomic charge density (PAW only)"
    l_max_rho::Union{Nothing,Int}
    "Angular momentum chosen to be the local potential (-1 if none)"
    l_local::Union{Nothing,Int}
    "Number of points in the radial grid"
    mesh_size::Int
    "Number of chi-functions"
    number_of_wfc::Int
    "Number of Kleinman-Bylander nonlocal projectors"
    number_of_proj::Int
end

"""
UPF `<PP_MESH>`
"""
struct UpfMesh
    "Radial mesh"
    r::Vector{Float64}
    "Integration factors for integrating quantities on the radial mesh"
    rab::Vector{Float64}
    "Number of points in the radial mesh"
    mesh::Union{Nothing,Int}
    "Maximum value of the radial mesh"
    rmax::Union{Nothing,Float64}
    # Mesh generation parameters
    dx::Union{Nothing,Float64}
    xmin::Union{Nothing,Float64}
    zmesh::Union{Nothing,Float64}
end

"""
UPF `<PP_NONLOCAL/PP_AUGMENTATION/PP_QIJ.[i].[j]>`
"""
struct UpfQij
    qij::Vector{Float64}
    first_index::Union{Nothing,Int}
    second_index::Union{Nothing,Int}
    composite_index::Union{Nothing,Int}
    is_null::Union{Nothing,Bool}
end

"""
UPF `<PP_NONLOCAL/PP_AUGMENTATION/PP_QIJL.[i].[j].[l]>`
"""
struct UpfQijl
    qijl::Vector{Float64}
    angular_momentum::Int
    first_index::Union{Nothing,Int}
    second_index::Union{Nothing,Int}
    composite_index::Union{Nothing,Int}
    is_null::Union{Nothing,Bool}
end

struct UpfQfcoef
    qfcoef::Vector{Float64}
    first_index::Union{Nothing,Int}
    second_index::Union{Nothing,Int}
    composite_index::Union{Nothing,Int}
end

"""
UPF `<PP_NONLOCAL/PP_AUGMENTATION>`
"""
struct UpfAugmentation
    """Integrals of the augmentation functions 4π ∫ Qij(r) r^2 dr.
    NB: `q = 0` does _not_ guarantee that the corresponding augmentation function is
    zero."""
    q::Matrix{Float64}
    """(PAW) Electronic multipoles of the corresponding augmentation channel. If the
    absolute value of a multipole is less than `augmentation_epsilon`, the corresponding
    augmentation function should be considered zero"""
    multipoles::Union{Nothing,Vector{Float64}}
    """Coefficients used to perform a Taylor expansion of the augmentation functions at
    small radii (NB: compulsory if `nqf > 0`, ignored otherwise)"""
    qfcoefs::Union{Nothing,Vector{UpfQfcoef}}
    rinner::Union{Nothing,Vector{Float64}}
    "If `q_with_l` is false, the augmentation functions for `i,j in 1:number_of_proj`"
    qijs::Union{Nothing,Vector{UpfQij}}
    """If `q_with_l` is true, the angular-momentum dependent augmentation functions for
    `i,j in 1:number_of_proj` and `l in 0:l_max_rho`"""
    qijls::Union{Nothing,Vector{UpfQijl}}
    "True if augmentation charge functions are decomposed into angular momentum components"
    q_with_l::Bool
    """Number of expansion coefficients for analytical expansion of the augmentation
    charge at small radius."""
    nqf::Int
    "Number of angular momenta terms in the augmentation charge, unused if `nqf = 0`"
    nqlc::Union{Nothing,Float64}
    """(UNUSED) (PAW) Shape of the augmentation function: `{PSQ, GAUSS, BESSEL}`, could
    be used for analyical overlap of PAW augmentation charge"""
    shape::Union{Nothing,String}
    "(PAW) Radial grid index beyond which augmentation charge is zero"
    iraug::Union{Nothing,Int}
    "(PAW) Radial distance beyond which augmentation charge is zero"
    raug::Union{Nothing,Float64}
    "(PAW): Maximum angular momentum appearing in augmentation charge"
    l_max_aug::Union{Nothing,Float64}
    """(PAW): Augmentation functions whose norms are less than `augmentation_epsilon` are
    considered zero"""
    augmentation_epsilon::Union{Nothing,Float64}
    "(DEPRECATED?)"
    cutoff_r::Union{Nothing,Float64}
    "(DEPRECATED?)"
    cutoff_r_index::Union{Nothing,Float64}
end

"""
UPF `<PP_NONLOCAL/PP_BETA.[i]>`
"""
struct UpfBeta
    "Kleinman-Bylander nonlocal projector multiplied by the radial mesh, on the radial mesh"
    beta::Vector{Float64}
    index::Union{Nothing,Int}
    angular_momentum::Int
    cutoff_radius_index::Union{Nothing,Int}
    cutoff_radius::Union{Nothing,Float64}
    norm_conserving_radius::Union{Nothing,Float64}
    ultrasoft_cutoff_radius::Union{Nothing,Float64}
    label::Union{Nothing,String}
end

"""
UPF `<PP_NONLOCAL>`
"""
struct UpfNonlocal
    """Kleinman-Bylander nonlocal projectors multiplied by the radial mesh,
    on the radial mesh"""
    betas::Vector{UpfBeta}
    "Kleinman-Bylander energies"
    dij::Matrix{Float64}
    "Agumentation data for ultrasoft and PAW pseudopotentials"
    augmentation::Union{Nothing,UpfAugmentation}
end

"""
Convert Q_IJ to Q_IJL

QE do this convertion internally. SIRIUS requires the Q_IJL format.
We use the process same as QE to convert Q_IJ to Q_IJL.
https://github.com/QEF/q-e/blob/57a97fe3ac56c6862ee083bf10d27505835c092a/upflib/upf_to_internal.f90#L64-L157
"""
function convert2std(nonlocal::UpfNonlocal, mesh::UpfMesh)::UpfNonlocal
    aug = nonlocal.augmentation

    if aug.q_with_l
        return nonlocal
    end

    @assert aug.qijs !== nothing "Q_IJ is not defined"
    @assert aug.qijls === nothing "Q_IJL is already defined"
    @assert aug.nqf != 0 "nqf is zero that means rinner/qfcoefs are not defined"

    # Convert Q_IJ to Q_IJL in augmentation field
    qijls = UpfQijl[]

    for (idx, qij) in enumerate(aug.qijs)
        first_index = qij.first_index
        second_index = qij.second_index
        composite_index = qij.composite_index
        qfcoef = aug.qfcoefs[idx]
        @assert qfcoef.first_index === first_index "first_index mismatch: $(qfcoef.first_index) != $first_index"
        @assert qfcoef.second_index === second_index "second_index mismatch: $(qfcoef.second_index) != $second_index"
        @assert qfcoef.composite_index === composite_index "composite_index mismatch: $(qfcoef.composite_index) != $composite_index"

        l1 = nonlocal.betas[first_index].angular_momentum
        l2 = nonlocal.betas[second_index].angular_momentum
        # duplicate q(r) for each l
        for l in abs(l1-l2):2:l1+l2
            qijl = UpfQijl(zeros(length(qij.qij)), l, first_index, second_index, composite_index, false)
            qijl.qijl .= qij.qij

            # inner value modified if nqf and rinner are defined
            for ir in eachindex(qijl.qijl)
                x = mesh.r[ir]
                if x ≥ aug.rinner[l+1]
                    # only modified if x < rinner
                    break
                end
                # Poly expansion of q(r) at small radii
                xx = x^2

                qijl.qijl[ir] = qfcoef.qfcoef[1] # init
                for _i in 2:aug.nqf
                    qijl.qijl[ir] += qfcoef.qfcoef[_i] * xx ^ (_i-1)
                end 
                qijl.qijl[ir] *= x^(l+2)
            end
            push!(qijls, qijl)
        end
    end

    q_with_l = true
    nqf = 0
    qfcoefs = nothing
    rinner = nothing
    qijs = nothing

    return UpfNonlocal(nonlocal.betas, nonlocal.dij, UpfAugmentation(aug.q, aug.multipoles, qfcoefs, rinner, qijs, qijls, q_with_l, nqf, aug.nqlc, aug.shape, aug.iraug, aug.raug, aug.l_max_aug, aug.augmentation_epsilon, aug.cutoff_r, aug.cutoff_r_index))

end


"""
UPF `<PP_PSWFC/PP_CHI>`
"""
struct UpfChi
    "Pseudo-atomic valence wavefunction on the radial mesh"
    chi::Vector{Float64}
    "Angular momentum"
    l::Int
    occupation::Float64
    index::Union{Nothing,Int}
    label::Union{Nothing,String}
    "Principal quantum number"
    n::Union{Nothing,Int}
    pseudo_energy::Union{Nothing,Float64}
    cutoff_radius::Union{Nothing,Float64}
    ultrasoft_cutoff_radius::Union{Nothing,Float64}
end

"""
UPF `<PP_SPIN_ORB/PP_RELWFC.[i]>`
"""
struct UpfRelWfc
    jchi::Float64
    index::Union{Nothing,Int}
    els::Union{Nothing,String}
    nn::Union{Nothing,Int}
    lchi::Union{Nothing,Int}
    oc::Union{Nothing,Float64}
end

"""
UPF `<PP_SPIN_ORB/PP_RELBETA.[i]>`
"""
struct UpfRelBeta
    index::Union{Nothing,Int}
    jjj::Float64
    lll::Union{Nothing,Int}
end

"""
UPF `<PP_SPIN_ORB>`
"""
struct UpfSpinOrb
    relwfcs::Vector{UpfRelWfc}
    relbetas::Vector{UpfRelBeta}
end

"""
UPF `<//PP_(AE|PS)WFC.[i]>`
"""
struct UpfWfc
    wfc::Vector{Float64}
    index::Int
    l::Int
    label::Union{Nothing,String}
end

"""
UPF `<PP_FULL_WFC>`
"""
struct UpfFullWfc
    aewfcs::Vector{UpfWfc}
    pswfcs::Vector{UpfWfc}
end

"""
UPF `<PP_PAW>`
"""
struct UpfPaw
    paw_data_format::Union{Nothing,Int}
    core_energy::Union{Nothing,Float64}
    occupations::Vector{Float64}
    ae_nlcc::Vector{Float64}
    ae_vloc::Vector{Float64}
    aewfcs::Vector{UpfWfc}
    pswfcs::Vector{UpfWfc}
end

"""
UPF `<PP_GIPAW/PP_GIPAW_CORE_ORBITALS/PP_GIPAW_CORE_ORBITAL.[i]>`
"""
struct UpfGipawCoreOrbital
    index::Int
    label::Union{Nothing,String}
    "Principal quantum number"
    n::Int
    "Angular momentum"
    l::Int
    core_orbital::Vector{Float64}
end

"""
UPF `<PP_GIPAW>`
"""
struct UpfGipaw
    gipaw_data_format::Int
    core_orbitals::Vector{UpfGipawCoreOrbital}
end

"""
Universal Pseudopotential Format file contents.
"""
struct UpfFile <: PsPFile
    "SHA1 Checksum"
    checksum::Vector{UInt8}
    "UPF format version"
    version::String
    "Optional general information about the pseudopotential, often generation input"
    info::Union{Nothing,String}
    "Various pseudopotential metadata"
    header::UpfHeader
    "Radial mesh, mesh integration factors, and other mesh information"
    mesh::UpfMesh
    "Pseudized core charge on the radial grid, (ignored if `core_correction` is false)"
    nlcc::Union{Nothing,Vector{Float64}}  # Σ_{i} 4π r_{i}^2 nlcc_{i}
    "Local part of the pseudopotential on the radial grid (ignored if `is_coulomb`)"
    local_::Union{Nothing,Vector{Float64}}
    "Nonlocal part of the pseudopotential"
    nonlocal::UpfNonlocal
    "Pseudo-atomic valence wavefunctions"
    pswfc::Union{Nothing,Vector{UpfChi}}
    "All-electron wavefunctions"
    full_wfc::Union{Nothing,UpfFullWfc}
    "Pseudo-atomic valence charge density on the radial grid"
    rhoatom::Vector{Float64}
    "Spin-orbit coupling data, (ignored if `has_so` is false)"
    spin_orb::Union{Nothing,UpfSpinOrb}
    "PAW data, (ignored if `is_paw` is false)"
    paw::Union{Nothing,UpfPaw}
    "GIPAW data"
    gipaw::Union{Nothing,UpfGipaw}
end

function convert2std(upffile::UpfFile)::UpfFile
    mesh = upffile.mesh
    nonlocal = upffile.nonlocal
    new_nonlocal = convert2std(nonlocal, mesh)
    return UpfFile(upffile.checksum, upffile.version, upffile.info, upffile.header, mesh, upffile.nlcc, upffile.local_, new_nonlocal, upffile.pswfc, upffile.full_wfc, upffile.rhoatom, upffile.spin_orb, upffile.paw, upffile.gipaw)
end

function UpfFile(path::AbstractString)
    open(path, "r") do io
        return UpfFile(io)
    end
end

function UpfFile(io::IO)
    version = _get_upf_version(io)
    if version == 1
        return upf1_parse_psp(io)
    end
    if version == 2
        return upf2_parse_psp(io)
    end
    error("Unknown UPF version.")
end

"""
write UPF file to `io`

note: no matter what version the file is, it will be written as UPF v2.0.1
"""
function save_psp(io::IO, psp::UpfFile, version::Int)
    if version == 2
        root_node = upf2_dump_psp(psp)
        prettyprint(io, root_node)
    else
        error("UPF version $version not supported yet.")
    end
end

function save_psp_file(path::AbstractString, psp::UpfFile, version::Int)
    open(path, "w") do io
        save_psp(io, psp, version)
    end
end

function _get_upf_version(io::IO)::Int
    seek(io, 0)
    line1 = readline(io)
    line2 = readline(io)
    if occursin("<PP_INFO>", line1)
        # Old UPF files start with the `<PP_INFO>` section
        return 1
    elseif occursin("UPF version=\"2.0.1\"", line1)
        # New UPF files with schema are in XML and start with a version tag
        return 2
    elseif occursin("xml version=\"1.0\"", line1) && occursin("UPF version=\"2.0.1\"", line2)
        # dumped UPF files start with a xml declaration
        return 2
    else
        error("Unknown UPF version")
    end
end

function _get_upf_version(path::AbstractString)::Int
    open(path, "r") do io
        return _get_upf_version(io)
    end
end

identifier(psp::UpfFile)::String = bytes2hex(psp.checksum)
format(file::UpfFile)::String = "UPF v$(file.version)"
element(file::UpfFile)::String = file.header.element
element(h::UpfHeader)::String = h.element
is_norm_conserving(file::UpfFile)::Bool = file.header.pseudo_type == "NC"
is_ultrasoft(file::UpfFile)::Bool = file.header.pseudo_type in ("US", "USPP")
is_paw(file::UpfFile)::Bool = file.header.pseudo_type == "PAW"
has_spin_orbit(file::UpfFile)::Bool = file.header.has_so
has_core_density(file::UpfFile)::Bool = file.header.core_correction
valence_charge(file::UpfFile)::Float64 = file.header.z_valence
max_angular_momentum(file::UpfFile)::Int = file.header.l_max
function n_projector_radials(file::UpfFile, l::Int)::Int
    return count(beta -> beta.angular_momentum == l, file.nonlocal.betas)
end
function n_chi_function_radials(file::UpfFile, l::Int)::Int
    return file.header.number_of_wfc == 0 ? 0 : count(chi -> chi.l == l, file.pswfc)
end
