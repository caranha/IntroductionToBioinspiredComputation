name: title
class: center, middle

# GAMA Tutorial

Claus Aranha, University of Tsukuba

---

# About the report for the lecture


---

# Goals of the Tutorial

Let's develop a Multi-agent model using GAMA.

You can download the following files with intermediate stages of the model:
- [Flower Model 00](Flower_00.gaml)
- [Flower Model 01](Flower_01.gaml)
- [Flower Model 03](Flower_03.gaml)
- [Flower Model 04](Flower_04.gaml)
- [Flower Model 05](Flower_05.gaml)
- [Flower Model 06](Flower_06.gaml)
- [Flower Model 08](Flower_08.gaml)
- [Flower Model 09](Flower_09.gaml)
- [Flower Model 10](Flower_10.gaml)

---

# Part 0: Model Definition

Before we begin to program, it is important to write an outline of the model.

The goal of this model is to study the process of **co-evolution**. To this end, we have two species: A species of **Plants**, and a species of **Bug**.

- The **Plants**:
  - Have a color that is inherited by its genes, and can mutate.
  - Gain energy from the sun, as long as there are not too many other plants nearby.
  - Reproduce when they have enough energy, and create another plant nearby.

- The **Bugs**:
  - Have a favorite plant color, and prefer to eat plants from that color.
  - Gain energy from eating plants. Gain half energy from plants of non-favorite color.
  - Move to the biggest plant nearby.
  - Reproduce when they have enough energy, and create another bug nearby.
  - Die if they reach 0 energy.

---

# Initial Model Reminder

The initial model (Flower_00) defines the two species, as well as our map
(a 50x50 grid).

To define the model, Gama uses a language called **Gama Modeling Language (GAML)**. A few things to remember about GAML:

How to define a new attribute:
```
rgb color <- #red;
```

How to set up a configurable parameter:
```
parameter "Number of Flowers" var: number_of_flowers min: 1 max: 1000 category: "Initialization";
```

---
# Part 1: Random Color for the Plants

First, let's make each plant have a random color.

We add a new attribute to the plant (Genome Color), and set it to a random
value in the beginning of the simulation:

```
int genered <- rnd(255);
int genegreen <- rnd(255);
int geneblue <- rnd(255);
rgb color <- rgb(genered, genegreen, geneblue);
```

The keyword `rnd()` can be used to give us a random value. In this case, we
receive a random value between 0 and 255.

Also remember that colors in computer are composed of three numbers (red, green
and blue), each number between 0 and 255.

---
# Part 2: Plant grow with the sun

We make each plant grow a little bit from the sun.

```
species flower
{
  (...)
	float energy <- 0.1;
	reflex photosynthesis {
		energy <- min(energy + sun_energy, max_energy);
	}
```

The keyword `reflex` tells GAMA that this agent does something every step in the simulaton. We also add two more global parameters:

```
global
  {
    (...)
  	float sun_energy <- 0.05;
  	float max_energy <- 5.0;

experiment flower_growth type: gui {
  (...)
  parameter "Sun Energy" var: sun_energy min: 0.0 max: 0.5 category: "Initialization";
  parameter "Max Energy" var: max_energy min: 1.0 max: 10.0 category: "Initialization";
```

---
# Part 3: Plant multiplies when above a certain amount of energy

When a plant reaches 90% of the maximum energy, it creates a new plant
nearby.

```
reflex reproduce when: (energy > max_energy*0.9) {
  energy <- energy / 2;
  create flower number: 1 {
    location <- one_of(cell(myself.location) neighbors_at 5);
    genered <- myself.genered;
    geneblue <- myself.geneblue;
    genegreen <- myself.genegreen;
  }
}
```

Here, the keyword `reflex` has a condition (`when`) so the plant only reproduces when the energy is bigger than 90% of the max.

In this situation, we divide the energy by 2, and create a new plant,
selecting a nearby location, and copying the colors.

---
# Part 4: Plant stops growing when crowded

When absorbing light, we will reduce the amount of energy by the number of
plants that are nearby.

```
reflex photosynthesis {
  list close_area <- cell(location) neighbors_at 5;
  int flower_count <- length(close_area where !(empty (flower inside each)));

  energy <- min(energy + sun_energy / (flower_count + 1), max_energy);
}
```

The first line defines `close_area` as the nearby cells of the flower.
The second line counts the number of flowers in that area.

The keyword `where` selects the elements of a collection that satisfy some condition. In this case, the elements of `close area` which contain one flower inside:
- `flower inside each`: list of flowers inside of a cell.
- `!(empty (flower inside each)))`: the list of flowers in a cell is not empty
- `length(close_area where !(empty (flower inside each)));`: the number of cells in `close_area` with flowers inside them.

---

# Part 5: Plant color Mutation

To finish the plant, we give them a small probability of mutating each of their colors.

```
global {
  (...)
  float plant_mutation_chance <- 0.05;

reflex reproduce when: (energy > max_energy*0.9) {
  (...)
  genered <- flip(plant_mutation_chance) ? rnd(255) : myself.genered;
  geneblue <- flip(plant_mutation_chance) ? rnd(255) : myself.geneblue;
  genegreen <- flip(plant_mutation_chance) ? rnd(255) : myself.genegreen;

experiment flower_growth type: gui {
  (...)
  parameter "Flower Mutation Chance" var: plant_mutation_chance min: 0.0 max: 1.0 category: "Flower";
```

The keyword `flip` is like flipping a coin with a probability. The number inside the keyword is the probability that the flip happens.

If the flip happens, we choose a new random color. If not, we choose the color of the parent.

---
# Part 6: Bugs move around

First, we add a new `reflex` to the bugs, so that they move every step in the simulation.

```
reflex move {
		location <- one_of(cell(location) neighbors_at 5);
}
```

Remember, we group all neighbors of the location, and select one of them.

---

# Part 7: Bugs eat plants.

If a plant is in the same cell as a bug, the bug will eat some of the energy of the plant.

```
float energy <- 0.5;
reflex eat when: flower inside cell(location) {
  flower eaten <- one_of(flower inside cell(location));
  if (eaten.energy > 1.0) {
    energy <- energy + 0.5;
    eaten.energy <- eaten.energy - 1.0;				
  }
}
```

The `if` keyword indicates that part of the code will only be executed if the condition is satisfied.

---

# Part 08: Bugs Reproduce and die;

The bugs spend some energy every time they move, and die if they run out of energy. They also produce more bugs if well fed.

```
reflex move {
  location <- one_of(cell(location) neighbors_at 5);
  energy <- energy - 0.01;
}

reflex die when: energy <= 0 {
    do die;
  }

reflex reproduce when: (energy > 1) {
energy <- energy / 2;
  create bug number: 1 {
    location <- one_of(cell(myself.location) neighbors_at 5);
  }
}
```

The keyword `die` destroy one agent.

---

# Part 09: Bugs move towards plants:

Right now the bugs are dying too fast, because they cannot find plants.

We will improve the movement so that the bugs try to move towards nearby plants.

```
reflex move {
  list nearplants <- (cell(location) neighbors_at 5) where (! empty (flower inside each));
  location <- length(nearplants) > 0 ? one_of(nearplants) : one_of(cell(location) neighbors_at 10);
  energy <- energy - 0.01;
}
```

Remember: `(cell(location) neighbors_at 5) where (! empty (flower inside each));`
is a list of cells (at distance 5), where the set of flowers inside is not empty.

---

# Part 10: Bugs have a favorite color

Each bug can have a favorite color of red, green or blue. If they eat of their favorite color, they get more energy. If they eat of another color, they get less.

```
species bug
{
	int favorite <- rnd(1,3);
	rgb color <- rgb(favorite=1 ? 255:0, favorite=2 ? 255:0, favorite=3 ? 255:0);

	bool isFavorite(flower plant) {
		if favorite = 1 and plant.genered > plant.genegreen and plant.genered > plant.geneblue {
			return true;
		}
		if favorite = 2 and plant.genegreen > plant.genered and plant.genegreen > plant.geneblue {
			return true;
		}
		if favorite = 3 and plant.geneblue > plant.genegreen and plant.geneblue > plant.genered {
			return true;
		}
		return false;
	}
```

---
# Part 10: Bugs have a favorite color

Each bug can have a favorite color of red, green or blue. If they eat of their favorite color, they get more energy. If they eat of another color, they get less.

```
  reflex eat when: flower inside cell(location) {
    flower eaten <- one_of(flower inside cell(location));
    if (eaten.energy > 1.0) {
      energy <- energy + (isFavorite(eaten) ? 1.0 : 0.0);
      eaten.energy <- eaten.energy - 1.0;				
    }
  }

```

```
reflex reproduce when: (energy > 1) {
energy <- energy / 2;
  create bug number: 1 {
    location <- one_of(cell(myself.location) neighbors_at 5);
    favorite <- myself.favorite;
  }
}
```


---
# Part 10: Bugs have a favorite color

Each bug can have a favorite color of red, green or blue. If they eat of their favorite color, they get more energy. If they eat of another color, they get less.

```
reflex move {
  list nearplants <- (cell(location) neighbors_at 5) where (! empty (flower inside each));
  list nearfavorites;

  loop cell_with_plants over:nearplants {
    if isFavorite(one_of(flower inside cell_with_plants)) {
      nearfavorites <- nearfavorites + cell_with_plants;
    }
  }

  location <- length(nearfavorites) > 0 ? one_of(nearplants) : one_of(cell(location) neighbors_at 10);
  energy <- energy - 0.01;
}
```

---
# More things to do:
- Adjust the value of the parameters (energy usage, reproduction energy, etc)
- Visualize number of bugs and flowers with graphs
- Death of flowers
- Mutation of Bugs
