#ifndef PARSE_TREE_H
#define PARSE_TREE_H

#include <bits/stdc++.h>
using namespace std;

class Node {
public:
    string name;
    vector<Node*> children;

    Node(string name) {
        this->name = name;
    }

    void addChild(Node* child) {
        if (child != nullptr)
            children.push_back(child);
    }
};

#endif