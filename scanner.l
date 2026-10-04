%option noyywrap

%{
#include <bits/stdc++.h>
using namespace std;

#include "parse_tree.h"
#include "parser.tab.h"

int line = 1;
extern FILE *logout;
extern FILE *errorout;

void logToken(const char* type)
{
    if (logout != nullptr) {
        fprintf(logout,
                "Line %d: Token <%s> Lexeme %s\n",
                line,
                type,
                yytext);
    }
}
%}

LETTER      [A-Za-z_]
DIGIT       [0-9]

ID          {LETTER}({LETTER}|{DIGIT})*
INT_CONST   {DIGIT}+
FLOAT_CONST ({DIGIT}+\.{DIGIT}*|{DIGIT}*\.{DIGIT}+)

WS          [ \t\r]+

%%

"int"       {
    logToken("KEYWORD");
    yylval.node = new Node("int");
    return INT;
}
"float"     { logToken("KEYWORD"); yylval.node = new Node("float"); return FLOAT; }
"double"    { logToken("KEYWORD"); yylval.node = new Node("double"); return DOUBLE; }
"char"      { logToken("KEYWORD"); yylval.node = new Node("char"); return CHAR; }
"void"      { logToken("KEYWORD"); yylval.node = new Node("void"); return VOID; }

"if"        { logToken("KEYWORD"); yylval.node = new Node("if"); return IF; }
"else"      { logToken("KEYWORD"); yylval.node = new Node("else"); return ELSE; }
"for"       { logToken("KEYWORD"); yylval.node = new Node("for"); return FOR; }
"while"     { logToken("KEYWORD"); yylval.node = new Node("while"); return WHILE; }
"return"    { logToken("KEYWORD"); yylval.node = new Node("return"); return RETURN; }
"break"     { logToken("KEYWORD"); yylval.node = new Node("break"); return BREAK; }
"continue"  { logToken("KEYWORD"); yylval.node = new Node("continue"); return CONTINUE; }
"do"        { logToken("KEYWORD"); yylval.node = new Node("do"); return DO; }
"switch"    { logToken("KEYWORD"); yylval.node = new Node("switch"); return SWITCH; }
"case"      { logToken("KEYWORD"); yylval.node = new Node("case"); return CASE; }
"default"   { logToken("KEYWORD"); yylval.node = new Node("default"); return DEFAULT; }

{FLOAT_CONST} {
    logToken("CONST_FLOAT");
    yylval.node = new Node(string("CONST_FLOAT: ") + yytext);
    return CONST_FLOAT;
}

{INT_CONST} {
    logToken("CONST_INT");
    yylval.node = new Node(string("CONST_INT: ") + yytext);
    return CONST_INT;
}

\'([^\\\n]|\\.)\' {
    logToken("CONST_CHAR");
    yylval.node = new Node(string("CONST_CHAR: ") + yytext);
    return CONST_CHAR;
}

\"([^\"\\\n]|\\.)*\" {
    logToken("STRING");
    yylval.node = new Node(string("STRING: ") + yytext);
    return STRING;
}

{ID} {
    logToken("ID");
    yylval.node = new Node(string("ID: ") + yytext);
    return ID;
}

"++"|"--" {
    logToken("INCOP");
    yylval.node = new Node(string("INCOP: ") + yytext);
    return INCOP;
}

"==" {
    logToken("RELOP");
    yylval.node = new Node("RELOP: ==");
    return RELOP;
}

"!=" {
    logToken("RELOP");
    yylval.node = new Node("RELOP: !=");
    return RELOP;
}

"<=" {
    logToken("RELOP");
    yylval.node = new Node("RELOP: <=");
    return RELOP;
}

">=" {
    logToken("RELOP");
    yylval.node = new Node("RELOP: >=");
    return RELOP;
}

"<"|">" {
    logToken("RELOP");
    yylval.node = new Node(string("RELOP: ") + yytext);
    return RELOP;
}

"&&"|"||"|"!" {
    logToken("LOGICOP");
    yylval.node = new Node(string("LOGICOP: ") + yytext);
    return LOGICOP;
}

"+="|"-="|"*="|"/="|"%="|"=" {
    logToken("ASSIGNOP");
    yylval.node = new Node(string("ASSIGNOP: ") + yytext);
    return ASSIGNOP;
}

"+"|"-" {
    logToken("ADDOP");
    yylval.node = new Node(string("ADDOP: ") + yytext);
    return ADDOP;
}

"*"|"/"|"%" {
    logToken("MULOP");
    yylval.node = new Node(string("MULOP: ") + yytext);
    return MULOP;
}

"&"|"|"|"^"|"~" {
    logToken("BITOP");
    yylval.node = new Node(string("BITOP: ") + yytext);
    return BITOP;
}

";"         { logToken("SEMICOLON"); yylval.node = new Node(";"); return SEMICOLON; }
","         { logToken("COMMA"); yylval.node = new Node(","); return COMMA; }
"("         { logToken("LPAREN"); yylval.node = new Node("("); return LPAREN; }
")"         { logToken("RPAREN"); yylval.node = new Node(")"); return RPAREN; }
"{"         { logToken("LBRACE"); yylval.node = new Node("{"); return LBRACE; }
"}"         { logToken("RBRACE"); yylval.node = new Node("}"); return RBRACE; }
"["         { logToken("LBRACKET"); yylval.node = new Node("["); return LBRACKET; }
"]"         { logToken("RBRACKET"); yylval.node = new Node("]"); return RBRACKET; }

"//".*      { /* Ignore single-line comment */ }

"/*"([^*]|\*+[^*/])*\*+"/" {
    for (int i = 0; yytext[i] != '\0'; i++)
    {
        if (yytext[i] == '\n')
            line++;
    }
}

{WS}        { /* Ignore whitespace */ }

\n          { line++; }

. {
    printf("Lexical error at line %d: %s\n", line, yytext);
}

%%