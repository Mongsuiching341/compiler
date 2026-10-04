#include <bits/stdc++.h>
using namespace std;

class SymbolInfo {
private:
    string name;
    string type;
    SymbolInfo* next;
    int lineNo;
    string dataType;
    string symbol;
    string status;
    vector<SymbolInfo*>* parameterList;

public:
    SymbolInfo() : name(""), type(""), next(nullptr), lineNo(0), symbol("VARIABLE") {
        parameterList = new vector<SymbolInfo*>();
    }

    SymbolInfo(string name, string type)
        : name(name), type(type), next(nullptr), lineNo(0), symbol("VARIABLE") {
        parameterList = new vector<SymbolInfo*>();
    }

    SymbolInfo(string name, string type, string dataType)
        : name(name), type(type), next(nullptr), lineNo(0), symbol("VARIABLE"), dataType(dataType) {
        parameterList = new vector<SymbolInfo*>();
    }

    SymbolInfo(string name, string type, string dataType, string symbol)
        : name(name), type(type), next(nullptr), lineNo(0), dataType(dataType), symbol(symbol) {
        parameterList = new vector<SymbolInfo*>();
    }

    SymbolInfo(string name, string type, string dataType, string symbol, string status)
        : name(name), type(type), next(nullptr), lineNo(0), dataType(dataType), symbol(symbol), status(status) {
        parameterList = new vector<SymbolInfo*>();
    }

    SymbolInfo(string name, string type, string dataType, string symbol, string status, int lineNo)
        : name(name), type(type), next(nullptr), lineNo(lineNo), dataType(dataType), symbol(symbol), status(status) {
        parameterList = new vector<SymbolInfo*>();
    }

    void setName(string name) { this->name = name; }
    void setType(string type) { this->type = type; }
    void setNext(SymbolInfo* next) { this->next = next; }
    void setLineNo(int lineNo) { this->lineNo = lineNo; }
    void setDataType(string dataType) { this->dataType = dataType; }
    void setSymbolType(string symbol) { this->symbol = symbol; }
    void setFunctionStatus(string status) { this->status = status; }

    string getName() { return name; }
    string getType() { return type; }
    SymbolInfo* getNext() { return next; }
    int getLineNo() { return lineNo; }
    string getDataType() { return dataType; }
    string getSymbolType() { return symbol; }
    string getFunctionStatus() { return status; }

    void setParameterList(vector<SymbolInfo*>* parameterList) {
        delete this->parameterList;
        this->parameterList = parameterList;
    }

    void addParameter(SymbolInfo* data) {
        parameterList->push_back(data);
    }

    vector<SymbolInfo*>* getParameterList() {
        if (parameterList == nullptr) {
            return new vector<SymbolInfo*>();
        }
        return parameterList;
    }

    ~SymbolInfo() {
        if (next != nullptr) {
            delete next;
        }
        if (parameterList != nullptr) {
            for (int i = 0; i < parameterList->size(); i++) {
                delete parameterList->at(i);
            }
            delete parameterList;
        }
    }
};
