package require critcl
package provide mymath 1.0

critcl::cproc noop {} void {}

critcl::cproc add {int x int y} int {
    return x + y;
}
critcl::cproc cube {int x} int {
    return x * x * x;
}

