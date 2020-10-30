#include "Lexer.h"

double Lexer::getNumber() const
{
	return m_d_number;
}

ETokenType Lexer::getNextToken()
{
	if (m_s_expression.empty())
	{
		return m_e_current_token = ETokenType::END;
	}

	char ch = m_s_expression.front();

	switch (ch)
	{
	case '(':
		return m_e_current_token = ETokenType::LEFT_PARE;
	case ')':
		return m_e_current_token = ETokenType::RIGHT_PARE;
	case '+':
		return m_e_current_token = ETokenType::PLUS;
	case '-':
		return m_e_current_token = ETokenType::MINUS;
	case '*':
		return m_e_current_token = ETokenType::MUL;
	case '/':
		return m_e_current_token = ETokenType::DIV;
	}

	std::string s_number = "";

	if (std::isdigit(ch)) {
		std::cout << "x = " << ch << std::endl;
	}
	return ETokenType();
}

ETokenType Lexer::getCurrentToken()
{
	return m_e_current_token;
}

void Lexer::setExpression(std::string const& s_expression)
{
	std::cout << "exp = " << s_expression << std::endl;
	std::remove(s_expression.begin(), s_expression.end(), 'a');
	std::cout << "exp = " << s_expression << std::endl;

	m_s_expression = s_expression;
}
