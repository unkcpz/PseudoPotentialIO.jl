using PseudoPotentialIO

# cp /home/jyu/Projects/WP-SSSP/sssp-verify-scripts/libraries-pbe/US-GBRV-1.x/Pd.us.z_16.uspp.gbrv.v1.4.upf .
upf1pp = load_psp_file("./Pd.us.z_16.uspp.gbrv.v1.4.upf")
save_psp_file("./Pd.uspp.v2-old.upf", upf1pp, 2)

#new_upf1pp = convert2std(upf1pp)
#save_psp_file("./Pd.uspp.v2-new.upf", new_upf1pp, 2)

## regression v1->v2->v2
#upf12pp = load_psp_file("./Pd.uspp.v2-old.upf")
#save_psp_file("./Pd.uspp.v1-v2-v2.upf", upf12pp, 2)

## cp /home/jyu/Projects/WP-SSSP/sssp-verify-scripts/libraries-pbe/US-PSL1.0.0-high/H.us.z_1.ld1.psl.v1.0.0-high.upf .
#upf2pp = load_psp_file("./H.us.z_1.ld1.psl.v1.0.0-high.upf")
#save_psp_file("./H.psl1.0.0-high.v2-v2.upf", upf2pp, 2)
#using PseudoPotentialIO
#
#upf_my = load_psp_file("./Pd.uspp.v2-new.upf")
#upf_upfconv = load_psp_file("./Pd.us.z_16.uspp.gbrv.v1.4.upfconv000-no-change.upf")
#my_qijls = upf_my.nonlocal.augmentation.qijls
#upfconv_qijls = upf_upfconv.nonlocal.augmentation.qijls
#
#for ii in eachindex(my_qijls)
#    for idx in eachindex(my_qijls[ii].qijl)
#        if !isapprox(my_qijls[ii].qijl[idx], upfconv_qijls[ii].qijl[idx], atol=1e-6)
#            println("Error: qijls[$ii][$idx] is not equal: $(my_qijls[ii].qijl[idx]) vs $(upfconv_qijls[ii].qijl[idx])")
#        end
#    end
#end