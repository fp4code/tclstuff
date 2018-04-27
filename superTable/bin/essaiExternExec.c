#include<unistd.h>
#include<stdio.h>

main(int argc, char *argv[]) {
    char buf[100];
    int i=0;
    
    while (!feof(stdin)) {
        char *ret;
        
        ret = fgets(buf, 100, stdin);
        if (ret == NULL) {
            perror("lecture sur stdin ");
            exit(22);
        }
        if (*buf == '\n') {
            break;
        }
        i++;
        fprintf(stderr, "%d %s", i, buf); /* le \n est laissé par fgets */
    }

    fprintf(stderr, "J'ai lu %d lignes\n", i);
    fflush(stderr);
    fprintf(stdout, "pr \"gnuplot: lu %d lignes\n\"", i);
    fflush(stdout);
    fclose(stdout);
    /* usleep(1);       /* une microseconde, ça a l'air de suffire pour éviter "broken pipe" */
    fprintf(stderr, "fin de roupilon\n");
    fclose(stderr);
    exit(0);
}
