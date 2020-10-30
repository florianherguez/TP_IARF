#pragma once
#include <string>
#include <iostream>

#include "ETokenType.h"


class Lexer
{
private:
	double m_d_number = 0.0;
	std::string m_s_expression = "";
	ETokenType m_e_current_token = ETokenType::END;

public:
	double getNumber() const;
	ETokenType getNextToken();
	ETokenType getCurrentToken();

	void setExpression(std::string const& s_expression);
};
