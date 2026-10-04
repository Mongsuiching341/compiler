%{
#include <bits/stdc++.h>
#include "parse_tree.h"
#include "SymbolTable.cpp"
#include "code_generator.h"

using namespace std;

/* Global parse tree root */
Node* root = nullptr;

/* Error counter */
int syntaxErrorCount = 0;

FILE *logout;
FILE *errorout;
CodeGenerator* generator;
SymbolTable *table;
int semanticErrorCount = 0;
extern int line;

/* Function declarations */
int yylex();
void yyerror(const char* s);

/* Helper function to print the parse tree */
void printTree(Node* node, ofstream& file, int depth = 0)
{
    if (node == nullptr)
        return;

    for (int i = 0; i < depth; i++)
        file << "  ";

    file << node->name << endl;

    for (Node* child : node->children)
        printTree(child, file, depth + 1);
}

void semanticError(string msg)
{
    semanticErrorCount++;

    fprintf(errorout,
            "Line %d: Semantic Error: %s\n",
            line,
            msg.c_str());

    fprintf(logout,
            "Line %d: Semantic Error: %s\n",
            line,
            msg.c_str());
}

void insertDeclaration(Node* node, string dataType)
{
    if (node == nullptr)
        return;

    if (node->name.find("ID: ") == 0)
    {
        string name = node->name.substr(4);

        if (table->lookupCurrent(name) != nullptr)
        {
            semanticError("Multiple declaration of " + name);
        }
        else
        {
            table->insert(
                new SymbolInfo(name, "ID", dataType)
            );
        }

        return;
    }

    for (Node* child : node->children)
    {
        insertDeclaration(child, dataType);
    }
}

void checkVariable(Node* node)
{
    if (node == nullptr)
        return;

    if (node->name.find("ID: ") == 0)
    {
        string name = node->name.substr(4);

        if (table->lookup(name) == nullptr)
        {
            semanticError("Undeclared variable " + name);
        }

        return;
    }

    for (Node* child : node->children)
    {
        checkVariable(child);
    }
}

string getTypeSpecifier(Node* node)
{
    if (node == nullptr || node->children.empty())
        return "unknown";

    return node->children[0]->name;
}

string getExpressionType(Node* node)
{
    if (node == nullptr)
        return "unknown";

    // Direct integer constant
    if (node->name.find("CONST_INT: ") == 0)
        return "int";

    // Direct float constant
    if (node->name.find("CONST_FLOAT: ") == 0)
        return "float";

    // Direct character constant
    if (node->name.find("CONST_CHAR: ") == 0)
        return "char";

    // constant -> CONST_INT / CONST_FLOAT / CONST_CHAR
    if (node->name == "constant")
    {
        if (node->children.size() == 1)
            return getExpressionType(node->children[0]);
    }

    // variable -> ID
    if (node->name == "variable")
    {
        if (node->children.size() == 1)
        {
            string name = node->children[0]->name.substr(4);

            SymbolInfo* symbol = table->lookup(name);

            if (symbol != nullptr)
                return symbol->getDataType();
        }
    }

    // expression
    if (node->name == "expression")
    {
        // expression -> variable
        // expression -> constant
        if (node->children.size() == 1)
        {
            return getExpressionType(node->children[0]);
        }

        // expression -> left operator right
        if (node->children.size() == 3)
        {
            Node* left = node->children[0];
            Node* op = node->children[1];
            Node* right = node->children[2];

            // Assignment
            if (op->name.find("ASSIGNOP") == 0)
            {
                string leftType = getExpressionType(left);
                string rightType = getExpressionType(right);

                if (leftType != rightType)
                {
                    semanticError(
                        "Type mismatch: cannot assign " +
                        rightType + " to " + leftType
                    );
                }

                return leftType;
            }

            // Arithmetic operation
            string leftType = getExpressionType(left);
            string rightType = getExpressionType(right);

            if (leftType == "float" || rightType == "float")
                return "float";

            if (leftType == "int" && rightType == "int")
                return "int";

            return "unknown";
        }
    }

    return "unknown";
}
string getNodeValue(Node* node)
{
    if (node == nullptr)
        return "";

    string value = node->name;

    size_t pos = value.find(": ");

    if (pos != string::npos)
        return value.substr(pos + 2);

    return value;
}

void generateExpression(Node* node)
{
    if (node == nullptr)
        return;

    // expression -> variable
    if (node->name == "expression" &&
        node->children.size() == 1)
    {
        Node* child = node->children[0];

        if (child->name == "variable")
        {
            string name = getNodeValue(child->children[0]);
            generator->emit("MOV AX, " + name);
        }
        else if (child->name == "constant")
        {
            string value = getNodeValue(child->children[0]);
            generator->emit("MOV AX, " + value);
        }

        return;
    }

    // expression -> left ADDOP right
    if (node->name == "expression" &&
        node->children.size() == 3)
    {
        Node* left = node->children[0];
        Node* op = node->children[1];
        Node* right = node->children[2];

        if (op->name.find("ADDOP") != string::npos)
        {
            generateExpression(left);

            string rightValue = "";

            if (right->name == "expression" &&
                right->children.size() == 1)
            {
                Node* r = right->children[0];

                if (r->name == "variable")
                {
                    rightValue = getNodeValue(r->children[0]);
                }
                else if (r->name == "constant")
                {
                    rightValue = getNodeValue(r->children[0]);
                }
            }

            if (!rightValue.empty())
            {
                if (op->name.find("+") != string::npos)
                    generator->emit("ADD AX, " + rightValue);

                else if (op->name.find("-") != string::npos)
                    generator->emit("SUB AX, " + rightValue);
            }
        }
    }
}
%}

/* Semantic value representation */
%union {
    Node* node;
}

/* Tokens */
%token <node> ID
%token <node> CONST_INT
%token <node> CONST_FLOAT
%token <node> CONST_CHAR
%token <node> STRING

%token <node> INT
%token <node> FLOAT
%token <node> DOUBLE
%token <node> CHAR
%token <node> VOID

%token <node> IF
%token <node> ELSE
%token <node> FOR
%token <node> WHILE
%token <node> RETURN
%token <node> BREAK
%token <node> CONTINUE
%token <node> DO
%token <node> SWITCH
%token <node> CASE
%token <node> DEFAULT

%token <node> INCOP
%token <node> ADDOP
%token <node> MULOP
%token <node> RELOP
%token <node> LOGICOP
%token <node> ASSIGNOP
%token <node> BITOP

%token <node> SEMICOLON
%token <node> COMMA
%token <node> LPAREN
%token <node> RPAREN
%token <node> LBRACE
%token <node> RBRACE
%token <node> LBRACKET
%token <node> RBRACKET

/* Non-terminals */
%type <node> program
%type <node> unit
%type <node> var_declaration
%type <node> type_specifier
%type <node> declaration_list
%type <node> func_definition
%type <node> parameter_list
%type <node> compound_statement
%type <node> statements
%type <node> statement
%type <node> expression_statement
%type <node> return_statement
%type <node> expression
%type <node> variable
%type <node> constant

%start program

/* Operator Precedence and Associativity */
%right ASSIGNOP
%left LOGICOP
%left RELOP
%left ADDOP
%left MULOP

%%

program
    : program unit
      {
          $$ = new Node("program");
          $$->addChild($1);
          $$->addChild($2);
          root = $$;

      }
    | unit
      {
          $$ = new Node("program");
          $$->addChild($1);
          root = $$;

      }
    ;

unit
    : var_declaration
      {
          $$ = new Node("unit");
          $$->addChild($1);
      }
    | func_definition
      {
          $$ = new Node("unit");
          $$->addChild($1);
      }
    ;

var_declaration
    : type_specifier declaration_list SEMICOLON
      {
          $$ = new Node("var_declaration");

          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);

          string dataType = getTypeSpecifier($1);
          insertDeclaration($2, dataType);
      }
    ;

type_specifier
    : INT
      {
          $$ = new Node("type_specifier");
          $$->addChild($1);
      }
    | FLOAT
      {
          $$ = new Node("type_specifier");
          $$->addChild($1);
      }
    | VOID
      {
          $$ = new Node("type_specifier");
          $$->addChild($1);
      }
    ;

declaration_list
    : declaration_list COMMA ID
      {
          $$ = new Node("declaration_list");
          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);
      }
    | ID
      {
          $$ = new Node("declaration_list");
          $$->addChild($1);
      }
    ;

func_definition
    : type_specifier ID LPAREN parameter_list RPAREN compound_statement
      {
          $$ = new Node("func_definition");
          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);
          $$->addChild($4);
          $$->addChild($5);
          $$->addChild($6);
      }
    ;

parameter_list
    : parameter_list COMMA type_specifier ID
      {
          $$ = new Node("parameter_list");
          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);
          $$->addChild($4);
      }
    | type_specifier ID
      {
          $$ = new Node("parameter_list");
          $$->addChild($1);
          $$->addChild($2);
      }
    | /* empty */
      {
          $$ = new Node("parameter_list");
      }
    ;

compound_statement
    : LBRACE
      {
          table->enterScope();
      }
      statements
      RBRACE
      {
          $$ = new Node("compound_statement");
          $$->addChild($1);
          $$->addChild($3);
          $$->addChild($4);

          table->exitScope();
      }
    ;

statements
    : statements statement
      {
          $$ = new Node("statements");
          $$->addChild($1);
          $$->addChild($2);
      }
    | /* empty */
      {
          $$ = new Node("statements");
      }
    ;

statement
    : var_declaration
      {
          $$ = new Node("statement");
          $$->addChild($1);
      }
    | expression_statement
      {
          $$ = new Node("statement");
          $$->addChild($1);
      }
    | compound_statement
      {
          $$ = new Node("statement");
          $$->addChild($1);
      }
    | return_statement
      {
          $$ = new Node("statement");
          $$->addChild($1);
      }
    ;

expression_statement
    : expression SEMICOLON
      {
          $$ = new Node("expression_statement");
          $$->addChild($1);
          $$->addChild($2);
      }
    | SEMICOLON
      {
          $$ = new Node("expression_statement");
          $$->addChild($1);
      }
    ;

return_statement
    : RETURN expression SEMICOLON
      {
          $$ = new Node("return_statement");
          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);
      }
    ;

expression
    : variable
      {
          $$ = new Node("expression");
          $$->addChild($1);
      }
    | constant
      {
          $$ = new Node("expression");
          $$->addChild($1);
      }
    | expression ADDOP expression
      {
          $$ = new Node("expression");
          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);

      }
    | expression MULOP expression
      {
          $$ = new Node("expression");
          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);
      }
    | expression RELOP expression
      {
          $$ = new Node("expression");
          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);
      }
    | expression LOGICOP expression
      {
          $$ = new Node("expression");
          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);
      }
    | variable ASSIGNOP expression
{
    $$ = new Node("expression");

    $$->addChild($1);
    $$->addChild($2);
    $$->addChild($3);

    getExpressionType($$);

    string variableName = getNodeValue($1->children[0]);

    generateExpression($3);

    generator->emit("MOV " + variableName + ", AX");
}
    | LPAREN expression RPAREN
      {
          $$ = new Node("expression");
          $$->addChild($1);
          $$->addChild($2);
          $$->addChild($3);
      }
    ;

variable
    : ID
      {
          $$ = new Node("variable");
          $$->addChild($1);

          checkVariable($1);
      }
    ;

constant
    : CONST_INT
      {
          $$ = new Node("constant");
          $$->addChild($1);
      }
    | CONST_FLOAT
      {
          $$ = new Node("constant");
          $$->addChild($1);
      }
    | CONST_CHAR
      {
          $$ = new Node("constant");
          $$->addChild($1);
      }
    ;

%%

void yyerror(const char* s)
{
    syntaxErrorCount++;
    fprintf(stderr, "Syntax Error: %s\n", s);
}

int main()
{
    logout = fopen("log.txt", "w");
    errorout = fopen("error.txt", "w");
    generator = new CodeGenerator("output.asm");
    ofstream parseTreeFile("parse_tree.txt");

    table = new SymbolTable(11, logout);

    if (yyparse() == 0)
{
    cout << "\nParsing successful!\n\n";

    parseTreeFile << "Parse Tree:\n";
    printTree(root, parseTreeFile);

    cout << "Parse tree written to parse_tree.txt\n";
}else
    {
        cout << "\nParsing failed!\n";
    }

    cout << "\nTotal Syntax Errors: "
         << syntaxErrorCount << endl;

    parseTreeFile.close();
    delete table;
    fclose(logout);
    fclose(errorout);
    delete generator;

    return 0;
}