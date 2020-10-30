#include <iostream>

#include "Lexer.h"


int main(int argc, char* argv[]) {
	double x = 5.2;
	char ch = '8';
	std::cout << "x = " << x << std::endl;

	Lexer lexer;
	lexer.setExpression("+ 8 + 3");
	lexer.getNextToken();
	
}