Block MODSEL                 # Select model
#   12    1000                # DRbar parameter output scale (GeV)
Block FlexibleSUSY
    0   1.000000000e-04      # precision goal
    1   0                    # max. iterations (0 = automatic)
    2   0                    # algorithm (0 = two_scale, 1 = lattice)
    3   1                    # calculate SM pole masses
    4   2                    # pole mass loop order
    5   2                    # EWSB loop order
    6   3                    # beta-functions loop order
    7   2                    # threshold corrections loop order
    8   1                    # Higgs 2-loop corrections O(alpha_t alpha_s)
    9   1                    # Higgs 2-loop corrections O(alpha_b alpha_s)
   10   1                    # Higgs 2-loop corrections O((alpha_t + alpha_b)^2)
   11   1                    # Higgs 2-loop corrections O(alpha_tau^2)
   12   0                    # force output
   13   1                    # Top quark 2-loop corrections QCD
   14   1.000000000e-11      # beta-function zero threshold
   15   0                    # calculate observables (a_muon, ...)
   16   0                    # force positive majorana masses
Block FlexibleSUSYInput
    0   0.00729735           # alpha_em(0)
    1   125.09               # Mh pole
Block SMINPUTS               # Standard Model inputs
    1   1.279340000e+02      # alpha^(-1) SM MSbar(MZ)
    2   1.166370000e-05      # G_Fermi
    3   1.176000000e-01      # alpha_s(MZ) SM MSbar
    4   9.118760000e+01      # MZ(pole)
    5   4.200000000e+00      # mb(mb) SM MSbar
    6   1.733000000e+02      # mtop(pole)
    7   1.777000000e+00      # mtau(pole)
    8   0.000000000e+00      # mnu3(pole)
    9   80.404               # MW pole
   11   5.109989020e-04      # melectron(pole)
   12   0.000000000e+00      # mnu1(pole)
   13   1.056583570e-01      # mmuon(pole)
   14   0.000000000e+00      # mnu2(pole)
   21   4.750000000e-03      # md(2 GeV) MS-bar
   22   2.400000000e-03      # mu(2 GeV) MS-bar
   23   1.040000000e-01      # ms(2 GeV) MS-bar
   24   1.270000000e+00      # mc(mc) MS-bar
Block MINPAR                 # Input parameters 
    1  -1.2700000E-01        # Lambda1INPUT
    2  -7.2000000E-05        # Lambda2INPUT
    3   0.0000000E+00        # Lambda3INPUT
   10   5.0000000E-01        # g1pINPUT
   11   1.0000000E-01        # g1p1INPUT
   12  -1.0000000E-01        # g11pINPUT
   20   6.0000000E+01        # vXinput
Block YVIN
    1 1   0.000000E+00       # Yv(1,1)
    1 2   0.000000E+00       # Yv(1,2)
    1 3   0.000000E+00       # Yv(1,3)
    2 1   0.000000E+00       # Yv(2,1)
    2 2   0.000000E+00       # Yv(2,2)
    2 3   0.000000E+00       # Yv(2,3)
    3 1   0.000000E+00       # Yv(3,1)
    3 2   0.000000E+00       # Yv(3,2)
    3 3   0.000000E+00       # Yv(3,3)
Block YXIN
    1 1   3.2000000E-01      # Yx(1,1)
    1 2   0.000000E+00       # Yx(1,2)
    1 3   0.000000E+00       # Yx(1,3)
    2 1   0.000000E+00       # Yx(2,1)
    2 2   3.2000000E-01      # Yx(2,2)
    2 3   0.000000E+00       # Yx(2,3)
    3 1   0.000000E+00       # Yx(3,1)
    3 2   0.000000E+00       # Yx(3,2)
    3 3   3.2000000E-01      # Yx(3,3)
