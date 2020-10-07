#include <stdlib.h>
#include <stdio.h>
#include <time.h>

#include <stdbool.h>

//*************** Structure des tas binaire ******************

typedef struct Heap {
    int *array;
    int length; // max size
    int size;
} Heap;


//*************** Fonctions données ******************

//**** Fonctions pour le temps d'execution ****
clock_t ti,tf;
double duree_ms;

void startMeasuringTime()
{
    ti = clock();
}

void stopMeasuringTime()
{
    tf = clock() - ti;
    duree_ms = tf/(double)CLOCKS_PER_SEC*1000 ;
}

void showElapsedTime()
{
    printf("duree (ms): ~%f\n",duree_ms);
}




//**** Fonction lecture des donnees ****
void read_data( FILE *datain, int **dataout, int *n, int *k ) {
	int *data;

	fscanf(datain, "%d", n);
	fscanf(datain, "%d", k);
	*dataout = (int *)malloc( (*n) * sizeof(int) );
	data=*dataout;

	for ( int i=0; i< *n; ++i, ++data )
		fscanf( datain, "%d", data );
}


//**** Affichage des donnees ****
void print_array(int * array, int length) {
    for (int i=0; i<length; ++i)
        printf("%d ", array[i]);
    printf("\n");
}

//**** Permutation ****
void permut(int* a, int* b) {
    int tmp = *a;
    *a = *b;
    *b = tmp;
}

//**** Permutation entre deux indices d'un tas binaire ****
void permut_heap(Heap heap, int ind1, int ind2) {
    permut(&heap.array[ind1], &heap.array[ind2]);
}








//*************** Exercice 1 ******************

//Affichage des données en reverse et prenant les k derniers elements
void print_array_bubble_sort(int* array, int length, int k_aff) {

    for (int i = 1; i < k_aff+1; i++)
        printf("%d ", array[length - i]);
    printf("\n");
}

void bubble_sort(int * array, int n, int k) {
	// TO DO
    printf("To Do bubble_sort \n");
    int k_aff = k;
    while (k > 0)
    {
        for (int i = 0; i < n - 1; i++)
        {
            if (array[i] > array[i+1])
            {
                permut(&array[i], &array[i + 1]);
            }
        }

        k--;
    }
    //Affichage
    print_array_bubble_sort(array, n, k_aff);
}





//*************** Exercice 2 ******************


int left(int i) {
    // TO DO
    return 2 * i + 1;
}

int right(int i) {
    // TO DO    
    return 2*(i+ 1);
}

void percolate_down(Heap heap, int i){
    // TO DO
    int l = left(i);
    int r = right(i);

    int m;

    if ((l < heap.size) && (heap.array[i] < heap.array[l]))
    {
        m = l;
    }
    else
    {
        m = i;
    }
    if ((r < heap.size) && (heap.array[m] < heap.array[r]))
    {
        m = r;
    }
    if (m != i)
    {
        permut_heap(heap, i, m);
        percolate_down(heap, m);
    }
}

void build_heap(Heap heap) {
    // TO DO
    printf("To Do build_heap \n");

    heap.size = heap.length;
    for (int i = heap.size/2; i >= 0; i--)
    {
        percolate_down(heap, i);
    }

    //Affichage
    //print_array(heap.array, heap.length);
}





int parent(int i) {
    // TO DO
    return 0;   
}

void percolate_up(Heap heap, int i) {
    // TO DO
}

void add(Heap * heap, int element) {
    // TO DO
    printf("To Do add \n");

}





int remove_max(Heap * heap) {
    // TO DO
    printf("To Do remove_max \n");
    return 0;
}





//*************** Exercice 3 ******************

int remove_bis(Heap * heap) {
    // TO DO
    return 0;
}

void heap_sort(int * array, int lenght) {
    // TO DO
    printf("To Do heap_sort \n");
}

void quick_sort(int * array, int firstIndex, int lastIndex) {
    // TO DO
    printf("To Do quick_sort \n");
}

void merge(int * array, int p, int q, int r) {
	// avant: array est tel que array[p..q] et array[q+1..r] sont tries
    // apres: array[p..q] trie'
    // TO DO
    printf("To Do merge \n");
}

void merge_sort(int * array, int firstIndex, int lastIndex) {
    // recursif relance merge_sort sur les deux moities de tableau
    // puis merge les deux resultats
    // TO DO
    printf("To Do merge_sort \n");
}





/* Main Program*/

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// En fonction de l'exercice, adaptez le main
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

int main( int argc, char **argv ) {
	int *data;
	int n, k;
	FILE *f_in;

	if ( argc > 1 )
		f_in = fopen(argv[1], "r");
	else
		f_in = stdin;

	/* read the data from the file given in arg or from stdin */
	read_data( f_in, &data, &n, &k );
    fclose(f_in);

    startMeasuringTime();

    Heap heap = {data, n, n};

    printf("Données initiales:\n");
    print_array(data, n);
    
    // ***** Exercice 1 *****
    bubble_sort(data, n, k);
    
    // ***** Exercice 2 *****
    build_heap(heap);
    print_array(heap.array, n);

    int array[n];
    Heap heap2={array,n,0}; int element;
    add(&heap2, element);

    int max;
    max = remove_max(&heap);
    
    // ***** Exercice 3 *****

    heap_sort(data, n);

    int firstIndex, lastIndex;

    quick_sort(data, firstIndex, lastIndex);
    
    merge_sort(heap.array, firstIndex, lastIndex);

    

    // ******** Affichage du temps d'execution ********

    stopMeasuringTime();

    showElapsedTime();

	/* end of the program*/
    free(data);
	return 0;
}

