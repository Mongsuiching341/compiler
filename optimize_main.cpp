#include "optimizer.h"

int main()
{
    PeepholeOptimizer optimizer;
    optimizer.optimize("output.asm", "optimized.asm");
    return 0;
}