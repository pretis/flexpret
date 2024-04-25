# Loader

This is a warning to the developer.

The loader program is extremely brittle due to how the application start location is calculated. It is done in the following manner:

1. The loader program is compiled.
2. The size of the loader program is checked.
3. The loader program is recompiled, but this time the size of its previous compilation is passed to it.

Since we don't know the size of the loader program for the first compilation, it is passed some default value.

However, if the difference between the values passed is big enough, it might trigger some optimizations by the compiler.

Therefore: Be very careful with compiling this program with optimizations flags set. 

There is a high reward to getting this program well optimized. However, it can be quite difficult to get right. If you cannot seem to do it, you should just set the compiler flag to `-O0`.

## The solution

Compile the program three times instead.
