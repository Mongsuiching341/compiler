#ifndef CODE_GENERATOR_H
#define CODE_GENERATOR_H

#include <bits/stdc++.h>
using namespace std;

class CodeGenerator
{
private:
    ofstream output;

public:
    CodeGenerator(const string& filename)
    {
        output.open(filename);
    }

    ~CodeGenerator()
    {
        if (output.is_open())
            output.close();
    }

    void emit(string instruction)
    {
        output << instruction << endl;
    }

    void emitLabel(string label)
    {
        output << label << ":" << endl;
    }
};

#endif