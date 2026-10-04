#include "optimizer.h"

void PeepholeOptimizer::optimize(const string& inputFile,
                                 const string& outputFile)
{
    ifstream in(inputFile);
    ofstream out(outputFile);

    vector<string> code;
    string line;

    while (getline(in, line))
    {
        code.push_back(line);
    }

    for (int i = 0; i < code.size(); i++)
    {
        // Rule 1: Remove MOV AX, AX
        if (code[i] == "MOV AX, AX")
        {
            continue;
        }

        // Rule 2: Remove ADD AX, 0
        if (code[i] == "ADD AX, 0")
        {
            continue;
        }

        // Rule 3: Remove SUB AX, 0
        if (code[i] == "SUB AX, 0")
        {
            continue;
        }

        // Rule 4: Remove redundant store-load pair
        // MOV y, AX
        // MOV AX, y
        if (i + 1 < code.size())
        {
            string current = code[i];
            string next = code[i + 1];

            if (current.rfind("MOV ", 0) == 0 &&
                next.rfind("MOV AX, ", 0) == 0)
            {
                string variable =
                    current.substr(4, current.find(",") - 4);

                string expected =
                    "MOV AX, " + variable;

                if (next == expected)
                {
                    out << current << endl;
                    i++;
                    continue;
                }
            }
        }

        // Rule 5: ADD AX, 1 -> INC AX
        if (code[i] == "ADD AX, 1")
        {
            out << "INC AX" << endl;
            continue;
        }

        // Rule 6: SUB AX, 1 -> DEC AX
        if (code[i] == "SUB AX, 1")
        {
            out << "DEC AX" << endl;
            continue;
        }

        // Rule 7: MOV AX, 0 followed by ADD AX, X
        // MOV AX, 0
        // ADD AX, x
        // becomes:
        // MOV AX, x
        if (i + 1 < code.size())
        {
            if (code[i] == "MOV AX, 0" &&
                code[i + 1].rfind("ADD AX, ", 0) == 0)
            {
                string value = code[i + 1].substr(8);

                out << "MOV AX, " << value << endl;

                i++;
                continue;
            }
        }

        // Rule 8: Remove duplicate MOV instructions only
        // MOV AX, X
        // MOV AX, X
        if (i + 1 < code.size())
        {
            if (code[i].rfind("MOV AX, ", 0) == 0 &&
                code[i] == code[i + 1])
            {
                out << code[i] << endl;
                i++;
                continue;
            }
        }

        // Normal instruction
        out << code[i] << endl;
    }

    in.close();
    out.close();
}