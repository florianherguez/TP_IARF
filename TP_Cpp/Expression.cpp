#include "Expression.h"

Expression::Expression(const char* expression)
{
	m_lexer = new Lexer();
	m_lexer->setExpression(expression);
	m_parser = new Parser(m_lexer);
}

double Expression::eval()
{
	return m_parser->calculate();
}

void Expression::print()
{
	std::cout << "str = " << m_lexer->getNumber() << std::endl;
}
