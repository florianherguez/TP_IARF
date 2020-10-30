#pragma once
#include <string>

#include <iostream>

#include "ETokenType.h"


class Lexer
{
private:
	double m_d_number;
	std::string m_s_expression;
	ETokenType m_e_current_token;
public:
	double getNumber() const;
	ETokenType getNextToken();
	ETokenType getCurrentToken();

	void setExpression(std::string const& s_expression);
};

