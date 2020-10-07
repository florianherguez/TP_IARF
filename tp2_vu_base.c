/*
 * IRIT/UPS
 * Gestion des acces a une voie unique
*/
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <pthread.h>

#define NB_VEH_MAX 20 
#define NB_PASSAGES_MAX 30

int nbPassages; /* Valeur commune à tous */

/* A compléter pour assurer la synchronisation souhaitée */

/*---------------------------------------------------------------------*/
void thdErreur(int codeErr, char *msgErr, void *codeArret) {
  fprintf(stderr, "%s: %d soit %s \n", msgErr, codeErr, strerror(codeErr));
  pthread_exit(codeArret);
}

/*---------------------------------------------------------------------*/
void demanderAccesVU (int monSens) {
  /* A compléter pour assurer la synchronisation souhaitée */
}

/*---------------------------------------------------------------------*/
int oppose (int sens) {
  return (sens + 1) % 2;
}

/*---------------------------------------------------------------------*/
void libererAccesVU (void) { 
  /* A compléter pour assurer la synchronisation souhaitée */
}

/*---------------------------------------------------------------------*/
// Thread qui veut acceder a la VU

/*---------------------------------------------------------------------*/
// Perdre du temps sur la voie double ou unique
void roulerVD (int monSens, int numPassage) {
  printf("Vehicule %lu, de sens %d passe pour la %d fois sur la voie double\n", pthread_self(), monSens, numPassage);
  usleep(rand()%100);
}

/*---------------------------------------------------------------------*/
void roulerVU (int monSens, int numPassage) {
  printf("Vehicule %lu, de sens %d passe pour la %d fois sur la VU\n", pthread_self(), monSens, numPassage);
  usleep(rand()%100);
}

/*---------------------------------------------------------------------*/
void *vehicule (void *arg) {
  int i, etat;
  int monSens = *(int *)arg;

  srand((int)pthread_self());
  for (i = 0; i < nbPassages; i++) {
    roulerVD(monSens, i);
    demanderAccesVU(monSens);
    printf("   Vehicule %lu, de sens %d rentre sur la VU\n", pthread_self(), monSens);
    roulerVU(monSens, i);
    libererAccesVU();   
    printf("   Vehicule %lu, de sens %d est sorti de la VU\n", pthread_self(), monSens);
  }
  printf("   Vehicule %lu, de sens %d termine\n", pthread_self(), monSens);
  return(NULL);
}

/*---------------------------------------------------------------------*/
int main(int argc, char*argv[]) {
  pthread_t idThd[2][NB_VEH_MAX];
  int       nbVeh[2], sensVeh[2][NB_VEH_MAX], i, s, etat;

  if (argc != 4) {
    printf("Usage : %s <Nb vehicules sens O> <Nb vehicules sens 1> <Nb passages sur VU>>\n", argv[0]);
    exit(1);
  }

  nbVeh[0] = atoi(argv[1]);
  if (nbVeh[0] > NB_VEH_MAX) 
    nbVeh[0] = NB_VEH_MAX;
  nbVeh[1] = atoi(argv[2]);
  if (nbVeh[1] > NB_VEH_MAX) 
    nbVeh[1] = NB_VEH_MAX;
  nbPassages = atoi(argv[3]);
  if (nbPassages > NB_PASSAGES_MAX) 
    nbPassages = NB_PASSAGES_MAX;

  /* A compléter pour assurer la synchronisation souhaitée */

  /* Lancer les threads vehicules */
  for (s = 0; s < 2; s++)
    for (i = 0; i < nbVeh[s]; i++) {
      sensVeh[s][i] = s;
        if ((etat = pthread_create(&idThd[s][i], NULL,
                               vehicule, &sensVeh[s][i])) != 0)
          thdErreur(etat, "Creation threads vehicules", NULL);
  }

  /* Attente de la fin des threads */
  for (s = 0; s < 2; s++)
    for (i = 0; i < nbVeh[s]; i++) {
       if ((etat = pthread_join(idThd[s][i], NULL)) != 0)
         thdErreur(etat, "Join threads vehicules", NULL);
  }

  /* A compléter pour assurer la synchronisation souhaitée */

  printf ("\nFin de l'execution du main \n");
  exit(0);
}
