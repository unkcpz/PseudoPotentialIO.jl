module PseudoPotentialIO
using Artifacts
using EzXML
using Interpolations
using LazyArtifacts
using LinearAlgebra
using OffsetArrays
using Polynomials
using Printf
using Statistics
using SHA
using PrettyTables

using PeriodicTable: PeriodicTable
import Base.Broadcast.broadcastable
import Bessels: gamma
import SpecialFunctions: erf

## DocStringExtensions Templates
# TODO they don't seem to be working at the moment
using DocStringExtensions
@template (FUNCTIONS, METHODS, MACROS) = """
                                         $(TYPEDSIGNATURES)
                                         $(DOCSTRING)
                                         $(METHODLIST)
                                         """

@template TYPES = """
                  $(TYPEDEF)
                  $(DOCSTRING)
                  $(TYPEDFIELDS)
                  """

## File datastructures and interface
export PsPFile
export format
export element
export is_norm_conserving
export is_ultrasoft
export is_paw
export formalism
export has_spin_orbit
export relativistic_treatment
export has_core_density
export valence_charge
export max_angular_momentum
export n_projector_radials
export n_chi_function_radials
include("file/file.jl")

export UpfFile
export convert2std
include("file/upf.jl")
include("file/upf1.jl")
include("file/upf2.jl")

export Psp8File
include("file/psp8.jl")

export HghFile
include("file/hgh.jl")

## Pseudopotential datastructures and interface
export AbstractPsP
export identifier
export element
export max_angular_momentum
export n_projector_radials
export n_projector_angulars
export n_chi_function_radials
export n_chi_function_angulars
export valence_charge
export atomic_charge
export is_norm_conserving
export is_ultrasoft
export is_paw
export has_spin_orbit
export has_core_density
export has_valence_density
export has_chi_functions
export projector_coupling
export local_potential_cutoff_radius
export projector_cutoff_radius
export chi_function_cutoff_radius
export valence_charge_density_cutoff_radius
export core_charge_density_cutoff_radius
export pseudo_cutoff_radius
export local_potential_real
export projector_real
export chi_function_real
export valence_charge_density_real
export core_charge_density_real
export local_potential_fourier
export projector_fourier
export chi_function_fourier
export valence_charge_density_fourier
export core_charge_density_fourier
export pseudo_energy_correction
export angular_momenta
export relativistic_treatment
export formalism
export projector_radial_indices
export chi_function_radial_indices
include("psp/psp.jl")

export NumericPsP
include("psp/numeric.jl")

export NormConservingPsP
include("psp/norm_conserving.jl")

export UltrasoftPsP
export augmentation_coupling
export augmentation_real
export augmentation_fourier
include("psp/ultrasoft.jl")

export ProjectorAugmentedWavePsP
include("psp/paw.jl")

export AnalyticalPsP
include("psp/analytical.jl")

export HghPsP
include("psp/hgh.jl")

## Loading/listing functions
export load_psp_file
export load_psp
export list_families
export load_family
export show_family_periodic_table
export show_family_list
include("load.jl")

## Save to file
export save_psp_file
include("save.jl")

## Deprecated loaders
export load_upf
export load_psp8
include("deprecated/upf.jl")
include("deprecated/psp8.jl")

## Miscellaneous
include("common/hankel_transform.jl")
include("common/mesh.jl")
include("common/quadrature.jl")
include("common/spherical_bessel.jl")
include("common/interpolation.jl")
include("common/truncation.jl")
end
