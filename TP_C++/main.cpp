#include <iostream>

#include "Expression.h"


int main(int argc, char* argv[]) {
	Expression e(argv[1]);
	std::cout << "x = " << e.eval() << std::endl;
	e.print();
}