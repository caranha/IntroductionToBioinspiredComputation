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
	int number_of_flowers <- 10;
	int number_of_bugs <- 10;
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
	float size <- 1.0;
	
	// Initial Random Color
	int genered <- rnd(255);
	int genegreen <- rnd(255);
	int geneblue <- rnd(255);
	rgb color <- rgb(genered, genegreen, geneblue);
			
	init {
		location <- one_of(cell);
	}

	aspect base {
		draw circle(size) color: color;
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
	output {
		display main_display {
			grid cell border: #black;
			species flower aspect: base;
			species bug aspect: base;			
		}
	}
}




