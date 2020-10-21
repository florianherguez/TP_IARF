#pragma once
#include <iostream>
#include <vector>
#include <string>
#include <sstream>

#include "Token.h"


class Expression
{
	public:
		std::vector<Token*> expressionToken;

	public:
		Expression(const char* str);

		int eval();
		void print();

		std::vector<Token*> tokensFromString(const std::string& s, char delim);
};

