#define CATCH_CONFIG_MAIN
#include "../include/catch2/catch.hpp"
#include "../include/hoshen_kopelman.h"
#include "../include/matrix.h"


TEST_CASE("En arreglo de solo ceros nunca hay percolación, Y en arreglo de unos, siempre la hay.", "[unosceros]"){
	
	int n_muestras = 10;
	int tamanhos[10] = {1, 10, 20, 30, 40, 50, 500, 1000, 5000, 10000};

	for (int L: tamanhos){
		std::vector<int> unos(L*L,1);
		std::vector<int> ceros(L*L,0);


		int percolating_count_unos = 0;
		int total_cluster_size_unos = 0;

		int percolating_count_ceros = 0;
		int total_cluster_size_ceros = 0;

		for (int ii = 0; ii < n_muestras; ii++){
			ClusterInfo hk_unos = hoshen_kopelman(unos, L);
			if (hk_unos.percolates){
				percolating_count_unos += 1;
				total_cluster_size_unos += hk_unos.max_cluster_size;
			}
			ClusterInfo hk_ceros = hoshen_kopelman(ceros, L);
			if (hk_ceros.percolates){
				// No se debería ejecutar
				percolating_count_ceros += 1;
				total_cluster_size_ceros += hk_ceros.max_cluster_size;
			}
		}
		double probability_unos = static_cast<double>(percolating_count_unos) / n_muestras;
		double probability_ceros = static_cast<double>(percolating_count_ceros) / n_muestras;

		double mean_cluster_size_unos = static_cast<double>(total_cluster_size_unos) / n_muestras;
		double mean_cluster_size_ceros = static_cast<double>(total_cluster_size_ceros) / n_muestras;

		REQUIRE(probability_unos == 1.0);
		REQUIRE(mean_cluster_size_unos==L*L);
		REQUIRE(probability_ceros == 0.0);
		REQUIRE(mean_cluster_size_ceros==0);
	}
}

TEST_CASE("Se detectan percolaciones verticales y horizontales","[horizontal_vertical]"){
	int n_muestras = 10;
	int tamanhos[10] = {1, 10, 20};

	for (int L: tamanhos){
		int fila = L/2;
		std::vector<int> horizontal(L*L,0);
		for (int l=0; l < L; l++){
			horizontal[l+L*fila]=1;
		}

		std::vector<int> vertical(L*L,0);
		for(int ll=0; ll<L; ll++){
			vertical[ll*L]= 1;
		}

		int percolating_count_hor = 0;
		int total_cluster_size_hor = 0;

		int percolating_count_ver = 0;
		int total_cluster_size_ver = 0;

		printmatrix(horizontal, L);
		std::cout << "\n";
		printmatrix(vertical,L);
		std::cout << "\n";

		for (int ii = 0; ii < n_muestras; ii++){
			ClusterInfo hk_horizontal = hoshen_kopelman(horizontal, L);
			if (hk_horizontal.percolates){
				percolating_count_hor += 1;
				total_cluster_size_hor += hk_horizontal.max_cluster_size;
			}
			ClusterInfo hk_vertical = hoshen_kopelman(vertical, L);
			if (hk_vertical.percolates){
				percolating_count_ver += 1;
				total_cluster_size_ver += hk_vertical.max_cluster_size;
			}
		}
		double probability_hor = static_cast<double>(percolating_count_hor) / n_muestras;
		double probability_ver = static_cast<double>(percolating_count_ver) / n_muestras;

		double mean_cluster_size_hor = static_cast<double>(total_cluster_size_hor) / n_muestras;
		double mean_cluster_size_ver = static_cast<double>(total_cluster_size_ver) / n_muestras;

		REQUIRE(probability_hor == 1.0);
		REQUIRE(mean_cluster_size_hor==L);
		REQUIRE(probability_ver == 1.0);
		REQUIRE(mean_cluster_size_ver==L);
		
	}
}