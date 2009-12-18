#include <stdio.h>
#include <uuid/uuid.h>
#include <tcutil.h>
#include <tcbdb.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) 
{
    TCBDB *bdb;
    BDBCUR *cur;
    int ecode;
    int i;
    int j;
    char *key;
    char *value;
    uuid_t uuid;
    float ZERO = 0.0;
    int NUM_METRICS=10;
    int NUM_BYTES=2049;
    const time_t NOW = time(NULL);

    if (argc > 1 && strncmp(argv[1], "-h", 2) == 0)
    {
        printf("Usage: %s <num_metrics> <document_size>", argv[0]);
        return -1;
    }
    else if (argc > 1)
    {
        NUM_METRICS = atoi(argv[1]);
        if (argc > 2)
        {
            NUM_BYTES = atoi(argv[2]);
        }
    }

    printf("Generating %d UUIDS\n", NUM_METRICS);

    /* create the object */
    bdb = tcbdbnew();

    /* open the database */
    if(!tcbdbopen(bdb, "./huge.tcb", BDBOWRITER | BDBOCREAT | BDBOTRUNC))
    {
        ecode = tcbdbecode(bdb);
        fprintf(stderr, "open error: %s\n", tcbdberrmsg(ecode));
    }

    tcbdbtune(bdb, 1024, 1024, 0, 0, 0, BDBTLARGE);

    value = (char*)malloc(NUM_BYTES);
    memset(value, 0, NUM_BYTES);
    memset(value, 'a', NUM_BYTES-1);
    key = (char*) malloc(47);
    memset(key, 0, 47);

    /* store records */
    for (i=0; i<NUM_METRICS; ++i)
    {
        uuid_generate_random(uuid);
        uuid_unparse(uuid, key);
        if ((i % 1000) == 0)
        {
            printf("Processing metric number %d\n", i);
            fflush(stdout);
        }

        /* Generate entry for each day of year */
        for (j=0; j<365; ++j)
        {
            snprintf(key+36, 10, "/2008-%3i", j+1);
            if(!tcbdbput2(bdb, key, value))
            {
                ecode = tcbdbecode(bdb);
                fprintf(stderr, "put error: %s\n", tcbdberrmsg(ecode));
            }
        }

    }

    free(key);
    free(value);

    /* close the database */
    if(!tcbdbclose(bdb))
    {
        ecode = tcbdbecode(bdb);
        fprintf(stderr, "close error: %s\n", tcbdberrmsg(ecode));
    }

    /* delete the object */
    tcbdbdel(bdb);
                    
    return 0;
}; 

