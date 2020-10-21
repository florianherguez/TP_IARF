#pragma once
#include <string>


class Token
{
	public :
		std::string tokentype;

	public :
		Token(std::string element);
		int eval();
};

