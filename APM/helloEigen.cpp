#include <iostream>
#include <Eigen/Dense>

#include "boost\filesystem.hpp"

using Eigen::MatrixXd;
int main()
{
  MatrixXd m(2,2);
  m(0,0) = 3;
  m(1,0) = 2.5;
  m(0,1) = -1;
  m(1,1) = m(1,0) + m(0,1);
  std::cout << m << std::endl;

  boost::filesystem::path p("C:\\Developpements\\APM\\APM_build\\HelloEigenProject.sln");

  if (exists(p)){
	  std::cout << "OK" << std::endl;
  }
}