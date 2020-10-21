#include "Expression.h"


Expression::Expression(const char* str) {
	this->expressionToken = tokensFromString(str, '+');
}

int Expression::eval() {

}

void Expression::print() {

}

std::vector<Token*> Expression::tokensFromString(const std::string& s, char delim) {
	std::vector<Token*> tokens;
	std::string token_str;
	std::istringstream tokenStream(s);

	while (std::getline(tokenStream, token_str, delim)) {
		Token token = Token(token_str);
		Token* token_ptr = &token;
		tokens.push_back(token_ptr);
	}
}