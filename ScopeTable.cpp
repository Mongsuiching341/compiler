#include "SymbolInfo.cpp"
#include <bits/stdc++.h>
using namespace std;

class ScopeTable {
private:
    SymbolInfo **table;
    ScopeTable *parentScope;
    int bucketSize;
    string uniqueId;
    FILE* logFile;

public:
    ScopeTable(int bucketSize, FILE* logFile = nullptr) {
        this->bucketSize = bucketSize;
        this->logFile = logFile;
        table = new SymbolInfo*[bucketSize];
        for (int i = 0; i < bucketSize; i++) {
            table[i] = nullptr;
        }
        parentScope = nullptr;
    }

    ~ScopeTable() {
        for (int i = 0; i < bucketSize; i++) {
            delete table[i];
        }
        delete[] table;
    }

    string getUniqueId() { return uniqueId; }
    void setUniqueId(string uniqueId) { this->uniqueId = uniqueId; }

    ScopeTable* getParentScope() { return parentScope; }
    void setParentScope(ScopeTable* parentScope) { this->parentScope = parentScope; }

    int getBucketSize() { return bucketSize; }
    FILE* getLogFile() { return logFile; }

    unsigned long long hashFunction(string str) {
        unsigned long long hash = 0;
        for (auto ch : str) {
            int c = ch;
            hash = c + (hash << 6) + (hash << 16) - hash;
        }
        return hash % getBucketSize();
    }

    bool insert(SymbolInfo *symbol) {
        unsigned long long hash = hashFunction(symbol->getName());
        int position = 0;
        if (table[hash] == nullptr) {
            table[hash] = symbol;
            position++;
            if (logFile) {
                fprintf(logFile, "\tInserted  at position <%llu, %d> of ScopeTable# %s\n",
                    hash + 1, position, getUniqueId().c_str());
            }
            return true;
        } else {
            SymbolInfo *temp = table[hash];
            while (temp->getNext() != nullptr) {
                if (temp->getName() == symbol->getName()) {
                    if (logFile) {
                        fprintf(logFile, "\t'%s' already exists in the current ScopeTable# %s\n",
                            symbol->getName().c_str(), getUniqueId().c_str());
                    }
                    return false;
                }
                temp = temp->getNext();
                position++;
            }
            if (temp->getName() == symbol->getName()) {
                if (logFile) {
                    fprintf(logFile, "\t'%s' already exists in the current ScopeTable# %s\n",
                        symbol->getName().c_str(), getUniqueId().c_str());
                }
                return false;
            }
            temp->setNext(symbol);
            position++;
            position++;
            if (logFile) {
                fprintf(logFile, "\tInserted  at position <%llu, %d> of ScopeTable# %s\n",
                    hash + 1, position, getUniqueId().c_str());
            }
            return true;
        }
    }

    SymbolInfo* lookup(string name) {
        int count = 0;
        unsigned long hash = hashFunction(name);
        if (table[hash] == nullptr) {
            return nullptr;
        } else {
            SymbolInfo *temp = table[hash];
            while (temp != nullptr) {
                if (temp->getName() == name) {
                    count++;
                    if (logFile) {
                        fprintf(logFile, "\t'%s' found at position <%lu, %d> of ScopeTable# %s\n",
                            name.c_str(), hash + 1, count, getUniqueId().c_str());
                    }
                    return temp;
                }
                temp = temp->getNext();
                count++;
            }
            return temp;
        }
    }

    bool deleteSymbol(string name) {
        int counter = 0;
        unsigned long hash = hashFunction(name);
        if (table[hash] == nullptr) {
            if (logFile) {
                fprintf(logFile, "\tNot found in the current ScopeTable# %s\n", getUniqueId().c_str());
            }
            return false;
        } else {
            SymbolInfo *temp = table[hash];
            SymbolInfo *prev = nullptr;
            while (temp != nullptr) {
                if (temp->getName() == name) {
                    if (prev == nullptr) {
                        table[hash] = temp->getNext();
                    } else {
                        prev->setNext(temp->getNext());
                    }
                    temp->setNext(nullptr);
                    counter++;
                    if (logFile) {
                        fprintf(logFile, "\tDeleted '%s' from position <%lu, %d> of ScopeTable# %s\n",
                            name.c_str(), hash + 1, counter, getUniqueId().c_str());
                    }
                    delete temp;
                    return true;
                }
                prev = temp;
                temp = temp->getNext();
                counter++;
            }
            if (logFile) {
                fprintf(logFile, "\tNot found in the current ScopeTable# %s\n", getUniqueId().c_str());
            }
            return false;
        }
    }

    // Print using FILE* (for Assignment-01 and Assignment-02)
    void print(FILE* outFile) {
        fprintf(outFile, "\tScopeTable# %s\n", getUniqueId().c_str());
        for (int i = 1; i <= getBucketSize(); i++) {
            fprintf(outFile, "\t%d", i);
            SymbolInfo* cur = table[i - 1];
            while (cur != nullptr) {
                fprintf(outFile, " --> (%s,%s)", cur->getName().c_str(), cur->getType().c_str());
                cur = cur->getNext();
            }
            fprintf(outFile, "\n");
        }
    }

    // Print using ofstream (for Assignment-03 and Assignment-04 with dataType/symbolType info)
    void print(std::ofstream& outFile) {
        outFile << "\tScopeTable# " << getUniqueId() << "\n";
        for (int i = 1; i <= getBucketSize(); i++) {
            SymbolInfo* cur = table[i - 1];
            if (cur == nullptr) {
                continue;
            }
            if (cur->getName() == "") {
                continue;
            }
            outFile << "\t" << i;
            if (cur->getSymbolType() == "VARIABLE") {
                outFile << "--> <" << cur->getName() << "," << cur->getDataType() << "> ";
            } else if (cur->getSymbolType() == "ARRAY") {
                outFile << "--> <" << cur->getName() << "," << cur->getSymbolType() << "> ";
            } else {
                outFile << "--> <" << cur->getName() << "," << cur->getSymbolType() << "," << cur->getDataType() << "> ";
            }
            cur = cur->getNext();
            while (cur != nullptr && cur->getName() != "") {
                if (cur->getSymbolType() == "VARIABLE") {
                    outFile << "<" << cur->getName() << "," << cur->getDataType() << "> ";
                } else if (cur->getSymbolType() == "ARRAY") {
                    outFile << "<" << cur->getName() << "," << cur->getSymbolType() << "> ";
                } else {
                    outFile << "<" << cur->getName() << "," << cur->getSymbolType() << "," << cur->getDataType() << "> ";
                }
                cur = cur->getNext();
            }
            outFile << "\n";
        }
    }
};
