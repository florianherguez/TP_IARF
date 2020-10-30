#pragma once
#include <iostream>

#include "Lexer.h"
#include "Parser.h"


class Expression
{
private:
	Lexer* m_lexer;
	Parser* m_parser;

public:
	Expression(const char* expression);

	double eval();
	void print();
};

