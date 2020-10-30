#pragma once
#include "Lexer.h"


class Parser
{
private:
	Lexer* m_lexer = nullptr;

public:
	Parser(Lexer* lexer);

	double parsePrimaryExpression();
	double parseMulDiv();
	double parseAddSub();
	double calculate();
};


