#include <stdio.h>

int main()
{

    int i,j;
	// choose a random country
	char *prefC[]= { "Indonesia", "New Guinea", "Western Australia", "Eastern Australia", "" };
	


	    for (j=0; *prefC[j] != '\0' ; j++) {
		if (strcmp(prefC[j], "aa") != 0) 
		    {
		    fprintf( stderr, "found %s to be free, taking it now.\n", prefC[j] );
		}
	    }
	    return 0;
}
