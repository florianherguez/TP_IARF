#include <iostream>
#include <string>

#include "Lexer.h"
#include "Parser.h"


int main(int argc, char* argv[]) {

	Lexer* lexer = new Lexer();

	std::string expr = "(2.3+2.7)*(1+6/2)";
	std::cout << "expression = " << expr << std::endl;
	lexer->setExpression(expr);

	Parser* parser = new Parser(lexer);
	std::cout << "resultat = " << parser->calculate() << std::endl;

	/*  
	boolean continue = true; 
	string cmd;
	do
	{
		cmd ="";					//la commande rentré dans l'environneent

		if(cmd= "exit")
			continue = false
		else
			Expression calculatrice = new Expression(cmd0);
			calculatrice.eval();
			calculatrice.print();
	} while (continue);
	*/
}