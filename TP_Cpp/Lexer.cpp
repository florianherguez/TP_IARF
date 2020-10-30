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
	m_s_expression.erase(0, 1);
	std::cout << "expression dans le lexer  = " << m_s_expression << std::endl;
	std::cout << "lexer getNextToken character = " << ch << std::endl;

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
		s_number += ch;
		while (!m_s_expression.empty() && (std::isdigit(m_s_expression.front()) || m_s_expression.front() == '.'))
		{
			s_number += m_s_expression.front();
			m_s_expression.erase(0, 1);
		}
		m_d_number = std::stof(s_number);
		return m_e_current_token = ETokenType::NUMBER;
	}
	else
	{
		std::cout << "Synthax Error";
		throw;
	}
}

ETokenType Lexer::getCurrentToken()
{
	return m_e_current_token;
}

void Lexer::setExpression(std::string const& s_expression)
{
	std::string exp_temp = s_expression;
	exp_temp.erase(std::remove(exp_temp.begin(), exp_temp.end(), ' '), exp_temp.end());
	m_s_expression = exp_temp;
}