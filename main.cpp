#include <bits/stdc++.h>
#include "SymbolTable.cpp"

using namespace std;

int main()
{
    FILE *inputFile = fopen("input.txt", "r");
    FILE *outputFile = fopen("output.txt", "w");

    if (inputFile == nullptr)
    {
        cout << "Cannot open input file." << endl;
        return 1;
    }

    int bucketSize;
    fscanf(inputFile, "%d", &bucketSize);

    SymbolTable table(bucketSize, outputFile);

    char command;

    while (fscanf(inputFile, " %c", &command) != EOF)
    {
        if (command == 'I')
        {
            char name[100], type[100];

            fscanf(inputFile, "%s %s", name, type);

            SymbolInfo *symbol = new SymbolInfo(name, type);

            table.insert(symbol);
        }
        else if (command == 'L')
        {
            char name[100];

            fscanf(inputFile, "%s", name);

            table.lookup(name);
        }
        else if (command == 'D')
        {
            char name[100];

            fscanf(inputFile, "%s", name);

            table.remove(name);
        }
        else if (command == 'P')
        {
            char subCommand;

            fscanf(inputFile, " %c", &subCommand);

            if (subCommand == 'C')
            {
                table.printCurrent(outputFile);
            }
            else if (subCommand == 'A')
            {
                table.printAll(outputFile);
            }
        }
        else if (command == 'S')
        {
            table.enterScope();
        }
        else if (command == 'E')
        {
            table.exitScope();
        }
    }   // <-- This closes the while loop

    fclose(inputFile);
    fclose(outputFile);

    return 0;
}