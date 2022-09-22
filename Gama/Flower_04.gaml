/**
* Name: Flower
* Based on the internal empty template. 
* Author: caranha
* Tags: 
*/


model Flower

/* Insert your model definition here */


/* Global Information */
global 
{
	// Simulation parameters
	int number_of_flowers <- 10;
	int number_of_bugs <- 10;

	float sun_energy <- 0.05;
	float max_energy <- 5.0;

	init {
		create flower number: number_of_flowers;
		create bug number: number_of_bugs;
	}
}



grid cell width: 50 height: 50 neighbors: 4 
{
}

/* Flower Information */
species flower 
{
	
	// Initial Random Color
	int genered <- rnd(255);
	int genegreen <- rnd(255);
	int geneblue <- rnd(255);
			
	init {
		location <- one_of(cell);
	}

	float energy <- 0.1;	
	reflex photosynthesis {
		list close_area <- cell(location) neighbors_at 5;
		int flower_count <- length(close_area where !(empty (flower inside each)));

		energy <- min(energy + sun_energy / (flower_count + 1), max_energy);
	}

	aspect base {
		draw circle(energy) color: rgb(genered, genegreen, geneblue);
	}
	
	reflex reproduce when: (energy > max_energy*0.9) {
		energy <- energy / 2;
		create flower number: 1 {
			location <- one_of(cell(myself.location) neighbors_at 5);
			genered <- myself.genered;
			geneblue <- myself.geneblue;
			genegreen <- myself.genegreen;
		}
	}
	
}


/* Bug Information */
species bug 
{
	float size <- 1.0;
	rgb color <- #red;
			
	init {
		location <- one_of(cell);
	}

	aspect base {
		draw square(size) color: color;
	}
}


/* Experiment Information */

experiment flower_growth type: gui {
	parameter "Number of Flowers" var: number_of_flowers min: 1 max: 1000 category: "Initialization";
	parameter "Number of Bugs" var: number_of_bugs min: 1 max: 1000 category: "Initialization";
	parameter "Sun Energy" var: sun_energy min: 0.0 max: 0.5 category: "Initialization";
	parameter "Max Energy" var: max_energy min: 1.0 max: 10.0 category: "Initialization";
	output {
		display main_display {
			grid cell border: #black;
			species flower aspect: base;
			species bug aspect: base;			
		}
	}
}




