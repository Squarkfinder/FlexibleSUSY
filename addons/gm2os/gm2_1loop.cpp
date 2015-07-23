// ====================================================================
// This file is part of FlexibleSUSY.
//
// FlexibleSUSY is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// FlexibleSUSY is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with FlexibleSUSY.  If not, see
// <http://www.gnu.org/licenses/>.
// ====================================================================

#include "gm2_1loop.hpp"
#include "MSSMNoFV_onshell.hpp"
#include "ffunctions.hpp"
#include "wrappers.hpp"

#include <complex>

namespace flexiblesusy {
namespace gm2os {

/**
 * Calculates full 1-loop SUSY contribution to (g-2), Eq. (45) of
 * arXiv:hep-ph/0609168.
 */
double calculate_gm2_1loop(const MSSMNoFV_onshell& model) {

   return amuChi0(model) + amuChipm(model);
}

/**
 * Calculates 1-loop neutralino contribution to (g-2), Eq. (46) of
 * arXiv:hep-ph/0609168.
 */
double amuChi0(const MSSMNoFV_onshell& model) {
   double result = 0.;
   const Eigen::Array<double,2,1> m_smu(model.get_MSmu());
   const Eigen::Matrix<double,2,2> u_smu(model.get_USmu());
   const Eigen::Matrix<double,4,2> AAN_(AAN(model));
   const Eigen::Matrix<double,4,2> BBN_(BBN(model));
   const Eigen::Matrix<double,4,2> x__im(x_im(model));
   const Eigen::Array<double,4,1> MChi(model.get_MChi());

   for(int i=0; i<4; ++i) {
      for(int m=0; m<2; ++m) {
         result += ( - AAN_(i, m) * F1N(x__im(i, m)) / (12. * sqr(m_smu(m)))
                     + MChi(i) * BBN_(i, m) * F2N(x__im(i, m))
                      / (3. * sqr(m_smu(m))) );
      }
   }

   return result * sqr(model.get_MM()) * oneOver16PiSqr;
}

/**
 * Calculates 1-loop chargino contribution to (g-2), Eq. (47) of
 * arXiv:hep-ph/0609168.
 */
double amuChipm(const MSSMNoFV_onshell& model) {
   double result = 0.;
   const Eigen::Array<double,2,1> x__k(x_k(model));
   const double MSvm(model.get_MSvmL());
   const Eigen::Array<double,2,1> AAC_(AAC(model));
   const Eigen::Array<double,2,1> BBC_(BBC(model));
   const Eigen::Array<double,2,1> MCha(model.get_MCha());

   for(int k=0; k<2; ++k) {
      result += ( AAC_(k) * F1C(x__k(k)) / (12. * sqr(MSvm))
                 + 2. * MCha(k) * BBC_(k) * F2C(x__k(k))
                  / (3. * sqr(MSvm)) );
   }

   return result * sqr(model.get_MM()) * oneOver16PiSqr;
}

/**
 * Calculates \f$n^L_{im}\f$, Eq. (48) of arXiv:hep-ph/0609168.  This
 * expression is equal to the complex conjugate of Eq. (2.5o) of
 * arXiv:1311.1775.
 */
Eigen::Matrix<std::complex<double>,4,2> n_L(const MSSMNoFV_onshell& model) {
   Eigen::Matrix<std::complex<double>,4,2> result;
   const double gY(model.get_gY());
   const double g2(model.get_g2());
   const double ymu(model.get_Ye()(1, 1));
   const Eigen::Matrix<std::complex<double>,4,4> ZN(model.get_ZN());
   const Eigen::Array<double,2,1> m_smu(model.get_MSmu());
   const Eigen::Matrix<double,2,2> u_smu(model.get_USmu());

   for(int i=0; i <4; ++i) {
      for(int m=0; m <2; ++m) {
         result(i, m) = ( (1. / sqrt(2.) * ( gY * ZN(i, 0)
                           + g2 * ZN(i, 1) ) * Conj(u_smu(m, 0)))
                         - ymu * ZN(i, 2) * Conj(u_smu(m, 1)) );
      }
   }

   return result;
}

/**
 * Calculates \f$n^R_{im}\f$, Eq. (49) of arXiv:hep-ph/0609168.  This
 * expression is the negative of Eq. (2.5p) of arXiv:1311.1775.
 */
Eigen::Matrix<std::complex<double>,4,2> n_R(const MSSMNoFV_onshell& model) {
   Eigen::Matrix<std::complex<double>,4,2> result;
   const double gY(model.get_gY());
   const double ymu(model.get_Ye()(1, 1));
   const Eigen::Matrix<std::complex<double>,4,4> ZN(model.get_ZN());
   const Eigen::Array<double,2,1> m_smu(model.get_MSmu());
   const Eigen::Matrix<double,2,2> u_smu(model.get_USmu());

   for(int i=0; i <4; ++i) {
      for(int m=0; m <2; ++m) {
         result(i, m) = ( sqrt(2.) * gY * ZN(i, 0) * u_smu(m, 1)
                       + ymu * ZN(i, 2) * u_smu(m, 0) );
      }
   }

   return result;
}

/**
 * Calculates \f$c^L_k\f$, Eq. (50) of arXiv:hep-ph/0609168.  This
 * expression is the complex conjugate Eq. (2.5a) of arXiv:1311.1775
 * for \f$l=\mu\f$.
 */
Eigen::Array<std::complex<double>,2,1> c_L(const MSSMNoFV_onshell& model) {
   Eigen::Array<std::complex<double>,2,1> result;
   const double g2 = model.get_g2();
   const Eigen::Matrix<std::complex<double>,2,2> UP(model.get_UP());

   for(int k=0; k<2; ++k) {
      result(k) = - g2 * UP(k, 0);
   }

   return result;
}

/**
 * Calculates \f$c^R_k\f$, Eq. (51) of arXiv:hep-ph/0609168.  This
 * expression is equal to Eq. (2.5b) of arXiv:1311.1775 for
 * \f$l=\mu\f$.
 */
Eigen::Array<std::complex<double>,2,1> c_R(const MSSMNoFV_onshell& model) {
   Eigen::Array<std::complex<double>,2,1> result;
   const double ymu = model.get_Ye()(1, 1);
   const Eigen::Matrix<std::complex<double>,2,2> UM(model.get_UM());

   for(int k=0; k<2; ++k) {
      result(k) = ymu * UM(k, 1);
   }

   return result;
}

/**
 * Calculates \f$|c^L_k|^2 + |c^R_k|^2\f$, which appears in Eq. (47)
 * of arXiv:hep-ph/0609168.
 */
Eigen::Array<double,2,1> AAC(const MSSMNoFV_onshell& model) {
   Eigen::Array<double,2,1> result;
   const Eigen::Array<std::complex<double>,2,1> c__L(c_L(model));
   const Eigen::Array<std::complex<double>,2,1> c__R(c_R(model));

   for(int k=0; k<2; ++k) {
      result(k) = norm(c__L(k)) + norm(c__R(k));
   }

   return result;
}

/**
 * Calculates \f$|n^L_{im}|^2 + |n^R_{im}|^2\f$, which appears in
 * Eq. (46) of arXiv:hep-ph/0609168.
 */
Eigen::Matrix<double,4,2> AAN(const MSSMNoFV_onshell& model) {
   Eigen::Matrix<double,4,2> result;
   const Eigen::Matrix<std::complex<double>,4,2> n__L(n_L(model));
   const Eigen::Matrix<std::complex<double>,4,2> n__R(n_R(model));

   for(int i=0; i<4; ++i) {
      for(int m=0; m<2; ++m) {
         result(i, m) = norm(n__L(i, m)) + norm(n__R(i, m));
      }
   }

   return result;
}

/**
 * Calculates \f$c^L_k c^R_k\f$, which appears in Eq. (47) of
 * arXiv:hep-ph/0609168.
 */
Eigen::Array<double,2,1> BBC(const MSSMNoFV_onshell& model) {
   Eigen::Array<double,2,1> result;
   const Eigen::Array<std::complex<double>,2,1> c__L(c_L(model));
   const Eigen::Array<std::complex<double>,2,1> c__R(c_R(model));

   for(int k=0; k<2; ++k) {
      result(k) = real(c__L(k) * c__R(k)) / model.get_MM();
   }

   return result;
}

/**
 * Calculates \f$n^L_{im} n^R_{im}\f$, which appears in Eq. (46) of
 * arXiv:hep-ph/0609168.
 */
Eigen::Matrix<double,4,2> BBN(const MSSMNoFV_onshell& model) {
   Eigen::Matrix<double,4,2> result;
   const Eigen::Matrix<std::complex<double>,4,2> n__L = n_L(model);
   const Eigen::Matrix<std::complex<double>,4,2> n__R = n_R(model);

   for(int i=0; i<4; ++i) {
      for(int m=0; m<2; ++m) {
         result(i, m) = real(n__L(i, m) * n__R(i, m)) / model.get_MM();
      }
   }

   return result;
}

/**
 * Calculates \f$x_{im} = m^2_{\chi_i^0} / m^2_{\tilde{\mu}_m}\f$,
 * which appears in Eq. (46) of arXiv:hep-ph/0609168.
 */
Eigen::Matrix<double,4,2> x_im(const MSSMNoFV_onshell& model) {
   Eigen::Matrix<double,4,2> result;
   const Eigen::Array<double,2,1> m_smu(model.get_MSmu());
   const Eigen::Matrix<double,2,2> u_smu(model.get_USmu());
   const Eigen::Array<double,4,1> MChi(model.get_MChi());

   for(int i=0; i <4; ++i) {
      for(int m=0; m <2; ++m) {
         result(i, m) = sqr(MChi(i) / m_smu(m));
      }
   }

   return result;
}

/**
 * Calculates \f$x_k = m^2_{\chi_k^\pm} / m^2_{\tilde{\nu}_\mu}\f$,
 * which appears in Eq. (47) of arXiv:hep-ph/0609168.
 */
Eigen::Array<double,2,1> x_k(const MSSMNoFV_onshell& model) {
   Eigen::Array<double,2,1> result;

   for(int k=0; k<2; ++k) {
      result(k) = sqr(model.get_MCha()(k) / model.get_MSvmL()); // !!!
   }

   return result;
}

// === approximations ===

/**
 * Calculates the 1-loop leading log approximation: Wino--Higgsino,
 * muon-sneutrino, Eq. (6.2a) arXiv:1311.1775
 */
double amuWHnu(const MSSMNoFV_onshell& model) {
   const double tan_beta = model.get_TB();
   const double M2 = model.get_MassWB();
   const double MUE = model.get_Mu();
   const double MSv_2 = model.get_MSvmL();

   return ( sqr(model.get_g2()) * 2. * oneOver16PiSqr
            * (sqr(model.get_MM()) * M2 * MUE * tan_beta)
            / sqr(sqr(MSv_2))
            * Fa(sqr(M2 / MSv_2), sqr(MUE / MSv_2)) );
}

/**
 * Calculates the 1-loop leading log approximation: Wino--Higgsino,
 * left-handed smuon, Eq. (6.2b) arXiv:1311.1775
 */
double amuWHmuL(const MSSMNoFV_onshell& model) {
   const double tan_beta = model.get_TB();
   const double M2 = model.get_MassWB();
   const double MUE = model.get_Mu();
   const double MSL_2 = sqrt(model.get_ml2()(1, 1));

   return ( - sqr(model.get_g2()) * oneOver16PiSqr
            * (sqr(model.get_MM()) * M2 * MUE * tan_beta)
            / sqr(sqr(MSL_2))
            * Fb(sqr(M2 / MSL_2), sqr(MUE / MSL_2)) );
}

/**
 * Calculates the 1-loop leading log approximation: Bino--Higgsino,
 * left-handed smuon, Eq. (6.2c) arXiv:1311.1775
 */
double amuBHmuL(const MSSMNoFV_onshell& model) {
   const double tan_beta = model.get_TB();
   const double M1 = model.get_MassB();
   const double MUE = model.get_Mu();
   const double MSL_2 = sqrt(model.get_ml2()(1, 1));
   const double gY = model.get_gY();

   return ( sqr(gY) * oneOver16PiSqr
            * (sqr(model.get_MM()) * M1 * MUE * tan_beta)
            / sqr(sqr(MSL_2))
            * Fb(sqr(M1 / MSL_2), sqr(MUE / MSL_2)) );
}

/**
 * Calculates the 1-loop leading log approximation: Bino--Higgsino,
 * right-handed smuon, Eq. (6.2d) arXiv:1311.1775
 */
double amuBHmuR(const MSSMNoFV_onshell& model) {
   const double tan_beta = model.get_TB();
   const double M1 = model.get_MassB();
   const double MUE = model.get_Mu();
   const double MSE_2 = sqrt(model.get_me2()(1, 1));
   const double gY = model.get_gY();

   return ( - sqr(gY) * 2. * oneOver16PiSqr
            * (sqr(model.get_MM()) * M1 * MUE * tan_beta)
            / sqr(sqr(MSE_2))
            * Fb(sqr(M1 / MSE_2), sqr(MUE / MSE_2)) );
}

/**
 * Calculates the 1-loop leading log approximation: Bino, left-handed
 * smuon, right-handed smuon, Eq. (6.2e) arXiv:1311.1775
 */
double amuBmuLmuR(const MSSMNoFV_onshell& model) {
   const double tan_beta = model.get_TB();
   const double M1 = model.get_MassB();
   const double MUE = model.get_Mu();
   const double MSL_2 = sqrt(model.get_ml2()(1, 1));
   const double MSE_2 = sqrt(model.get_me2()(1, 1));
   const double gY = model.get_gY();

   return ( sqr(gY) * 2. * oneOver16PiSqr
            * (sqr(model.get_MM()) * MUE * tan_beta)
            / (M1 * sqr(M1))
            * Fb(sqr(MSL_2 / M1), sqr(MSE_2 / M1)) );
}

/**
 * Calculates the full 1-loop leading log approximation, Eq. (6.1)
 * arXiv:1311.1775
 */
double amu1Lapprox(const MSSMNoFV_onshell& model) {

   return ( amuWHnu(model) + amuWHmuL(model) + amuBHmuL(model)
            + amuBHmuR(model) + amuBmuLmuR(model) );
}

} // namespace gm2os
} // namespace flexiblesusy
