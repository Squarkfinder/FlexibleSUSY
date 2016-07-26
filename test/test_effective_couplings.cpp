
#define BOOST_TEST_DYN_LINK
#define BOOST_TEST_MODULE test_effective_couplings

#include <boost/test/unit_test.hpp>
#include <boost/test/floating_point_comparison.hpp>

#include "effective_couplings.hpp"
#include "wrappers.hpp"

using namespace flexiblesusy;
using namespace effective_couplings;

BOOST_AUTO_TEST_CASE( test_scaling_function )
{
   BOOST_CHECK_EQUAL(Re(scaling_function(0.)), 0.);
   BOOST_CHECK_EQUAL(Im(scaling_function(0.)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(scaling_function(0.5)), 0.616850275068085, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(scaling_function(0.5)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(scaling_function(0.75)), 1.0966227112321507, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(scaling_function(0.75)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(scaling_function(1.)), 2.4674011002723395, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(scaling_function(1.)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(scaling_function(1.5)), 2.0338065747041805, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Im(scaling_function(1.5)), 2.0686726270330347, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Re(scaling_function(2.)), 1.6905817003766437, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Im(scaling_function(2.)), 2.7689167860486803, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Re(scaling_function(10.)), -0.8393464248213007, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Im(scaling_function(10.)), 5.712818037269832, 1.0e-14);
}

BOOST_AUTO_TEST_CASE( test_AS0 )
{
   BOOST_CHECK_CLOSE_FRACTION(Re(AS0(0.5)), 0.46740110027233994, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(AS0(0.5)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(AS0(0.95)), 0.9526716202288444, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(AS0(0.95)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(AS0(1.)), 1.4674011002723395, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(AS0(1.)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(AS0(1.02)), 1.3721001820578436, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Im(AS0(1.02)), 0.4256252450396851, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Re(AS0(3.2)), -0.20877378813795655, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Im(AS0(3.2)), 0.363685421601937, 1.0e-14);
}

BOOST_AUTO_TEST_CASE( test_AS12 )
{
   BOOST_CHECK_CLOSE_FRACTION(Re(AS12(0.2)), 1.4012357867134255, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(AS12(0.2)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(AS12(0.8)), 1.7338885729293136, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(AS12(0.8)), 0.);
   BOOST_CHECK_EQUAL(Re(AS12(1.)), 2.);
   BOOST_CHECK_EQUAL(Im(AS12(1.)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(AS12(1.3)), 2.317171235447624, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Im(AS12(1.3)), 0.5838721970979124, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Re(AS12(4.)), 0.7748836242498889, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Im(AS12(4.)), 1.5515044702747753, 1.0e-14);
}

BOOST_AUTO_TEST_CASE( test_AS1 )
{
   BOOST_CHECK_CLOSE_FRACTION(Re(AS1(0.05)), -7.075200061042707, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(AS1(0.05)), 0.);
   BOOST_CHECK_EQUAL(Re(AS1(0.5)), -8.);
   BOOST_CHECK_EQUAL(Im(AS1(0.5)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(AS1(0.95)), -10.57221337461788, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(AS1(0.95)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(AS1(1.)), -12.402203300817018, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(AS1(1.)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(AS1(1.4)), -9.960646594444304, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Im(AS1(1.4)), -5.162564739778429, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Re(AS1(6.7)), -2.3587910058759363, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Im(AS1(6.7)), -4.177455742756774, 1.0e-14);
}

BOOST_AUTO_TEST_CASE( test_AP12 )
{
   BOOST_CHECK_CLOSE_FRACTION(Re(AP12(0.3)), 1.119940762029675, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(AP12(0.3)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(AP12(1.)), 2.4674011002723395, 1.0e-14);
   BOOST_CHECK_EQUAL(Im(AP12(1.)), 0.);
   BOOST_CHECK_CLOSE_FRACTION(Re(AP12(1.1)), 2.1550612079680067, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Im(AP12(1.1)), 0.8887315770636819, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Re(AP12(9.8)), -0.08170543420654755, 1.0e-14);
   BOOST_CHECK_CLOSE_FRACTION(Im(AP12(9.8)), 0.5795253251779525, 1.0e-14);
}