// ====================================================================
// This file is part of GM2Calc.
//
// GM2Calc is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// GM2Calc is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GM2Calc.  If not, see
// <http://www.gnu.org/licenses/>.
// ====================================================================

#ifndef MSSMNoFV_onshell_PHYSICAL_H
#define MSSMNoFV_onshell_PHYSICAL_H

#include <Eigen/Core>

#include <iosfwd>

namespace gm2calc {

/**
 * @class MSSMNoFV_onshell_physical
 * @brief MSSMNoFV pole masses and corresponding mixings
 */
struct MSSMNoFV_onshell_physical {
   MSSMNoFV_onshell_physical();
   void clear();
   void convert_to_hk();   ///< converts pole masses to HK convention
   void convert_to_slha(); ///< converts pole masses to SLHA convention
   void print(std::ostream&) const;

   double MVG;
   double MGlu;
   double MVP;
   double MVZ;
   double MFd;
   double MFs;
   double MFb;
   double MFu;
   double MFc;
   double MFt;
   double MFve;
   double MFvm;
   double MFvt;
   double MFe;
   double MFm;
   double MFtau;
   double MSveL;
   double MSvmL;
   double MSvtL;
   Eigen::Array<double,2,1> MSd;
   Eigen::Array<double,2,1> MSu;
   Eigen::Array<double,2,1> MSe;
   Eigen::Array<double,2,1> MSm;
   Eigen::Array<double,2,1> MStau;
   Eigen::Array<double,2,1> MSs;
   Eigen::Array<double,2,1> MSc;
   Eigen::Array<double,2,1> MSb;
   Eigen::Array<double,2,1> MSt;
   Eigen::Array<double,2,1> Mhh;
   Eigen::Array<double,2,1> MAh;
   Eigen::Array<double,2,1> MHpm;
   Eigen::Array<double,4,1> MChi;
   Eigen::Array<double,2,1> MCha;
   double MVWm;

   Eigen::Matrix<double,2,2> ZD;
   Eigen::Matrix<double,2,2> ZU;
   Eigen::Matrix<double,2,2> ZE;
   Eigen::Matrix<double,2,2> ZM;
   Eigen::Matrix<double,2,2> ZTau;
   Eigen::Matrix<double,2,2> ZS;
   Eigen::Matrix<double,2,2> ZC;
   Eigen::Matrix<double,2,2> ZB;
   Eigen::Matrix<double,2,2> ZT;
   Eigen::Matrix<double,2,2> ZH;
   Eigen::Matrix<double,2,2> ZA;
   Eigen::Matrix<double,2,2> ZP;
   Eigen::Matrix<std::complex<double>,4,4> ZN;
   Eigen::Matrix<std::complex<double>,2,2> UM;
   Eigen::Matrix<std::complex<double>,2,2> UP;

};

std::ostream& operator<<(std::ostream&, const MSSMNoFV_onshell_physical&);

} // namespace gm2calc

#endif
