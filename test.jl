using PseudoPotentialIO

# cp /home/jyu/Projects/WP-SSSP/sssp-verify-scripts/libraries-pbe/US-GBRV-1.x/Pd.us.z_16.uspp.gbrv.v1.4.upf .
upf1pp = load_psp_file("./Pd.us.z_16.uspp.gbrv.v1.4.upf")
save_psp_file("./Pd.uspp.v1-v2.upf", upf1pp, 2)

# regression v1->v2->v2
upf12pp = load_psp_file("./Pd.uspp.v1-v2.upf")
save_psp_file("./Pd.uspp.v1-v2-v2.upf", upf1pp, 2)

## cp /home/jyu/Projects/WP-SSSP/sssp-verify-scripts/libraries-pbe/US-PSL1.0.0-high/H.us.z_1.ld1.psl.v1.0.0-high.upf .
#upf2pp = load_psp_file("./H.us.z_1.ld1.psl.v1.0.0-high.upf")
#save_psp_file("./H.psl1.0.0-high.v2-v2.upf", upf2pp, 2)

