#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>
 
int main(void) {
    char op[6];
    int  num1, num2;
 
    // Read one line at a time until EOF
    while (scanf("%5s %d %d", op, &num1, &num2) == 3) {
 
        // Build path:  "./lib<op>.so"
        char path[32];
        snprintf(path, sizeof(path), "./lib%s.so", op);
 
        // Load the shared library at runtime
        void *handle = dlopen(path, RTLD_NOW | RTLD_LOCAL);
        if (!handle) {
            fprintf(stderr, "dlopen failed: %s\n", dlerror());
            return 1;
        }
 
        // Look up the function:  int <op>(int, int)
        typedef int (*op_fn)(int, int);
        op_fn fn = (op_fn) dlsym(handle, op);
        if (!fn) {
            fprintf(stderr, "dlsym failed: %s\n", dlerror());
            dlclose(handle);
            return 1;
        }
 
        // Call the function and print the result
        printf("%d\n", fn(num1, num2));
 
        // Unload the library immediately to free memory before next iteration
        dlclose(handle);
    }
 
    return 0;
}
 