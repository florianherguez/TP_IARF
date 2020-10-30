#include "Parser.h"


Parser::Parser(Lexer* lexer) : m_lexer(lexer)
{
}

/*
    E   ->  NUMBER                  ( double )
    E   ->  MINUS E                 ( - expression )
    E   -> LEFT_PARE B RIGHT_PARE   ( ( addSub ) )
*/
double Parser::parsePrimaryExpression()
{
    m_lexer->getNextToken();

    switch (m_lexer->getCurrentToken())
    {
    case ETokenType::NUMBER:
    {
        double d_number = m_lexer->getNumber();
        m_lexer->getNextToken();

        std::cout << "resultat number = " << d_number << std::endl;
        return d_number;
    }

    case ETokenType::MINUS:
        std::cout << "minus " << std::endl;
        return -parsePrimaryExpression();

    case ETokenType::LEFT_PARE:
    {
        std::cout << "parentheses debut" << std::endl;
        double d_result = parseAddSub();

        if (m_lexer->getCurrentToken() != ETokenType::RIGHT_PARE)
        {
            std::cout << "Error : missing bracket";
            throw;
        }
        m_lexer->getNextToken();

        std::cout << "parentheses fin" << std::endl;
        return d_result;
    }

    default:
        std::cout << "Error : expected primary expression";
        throw;
    }
}

/*
    A   ->  E MUL E                 ( double )
    A   ->  E DIV E                 ( - expression )
*/
double Parser::parseMulDiv()
{
    double d_result = parsePrimaryExpression();

    while (true)
    {
        switch (m_lexer->getCurrentToken())
        {
        case ETokenType::MUL:
            std::cout << "multiplication " << std::endl;

            d_result *= parsePrimaryExpression();
            break;

        case ETokenType::DIV:
        {
            std::cout << "division" << std::endl;

            double d_temp = parsePrimaryExpression();
            if (d_temp != 0.0)
            {
                d_result /= d_temp;
                break;
            }
            else
            {
                std::cout << "Error : division by zero";
                throw;
            }
        }

        default:
            return d_result;
        }
    }
}

/*
    B   ->  E PLUS A                ( expression + multDiv )
    B   ->  E MINUS A               ( expression - multDiv )
*/
double Parser::parseAddSub()
{
    double d_result = parseMulDiv();

    while (true)
    {
        switch (m_lexer->getCurrentToken())
        {
        case ETokenType::PLUS:
            std::cout << "addition" << std::endl;

            d_result += parseMulDiv();
            break;

        case ETokenType::MINUS:
            std::cout << "soustraction" << std::endl;

            d_result -= parseMulDiv();
            break;

        default:
            return d_result;
        }
    }
}

double Parser::calculate()
{
    std::cout << "debut du calcule" << std::endl;
    return parseAddSub();
}
