# Game of life
An implementation of [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) for iOS.

There is no real objective in "Game of Life". The player sets up a "seed" and then the algorithm takes over and creates generations from theat initial seed, based on a few rules.

* Any live cell with fewer than two live neighbours dies, as if caused by under-population.
* Any live cell with two or three live neighbours lives on to the next generation.
* Any live cell with more than three live neighbours dies, as if by over-population.
* Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.

# Todo
* Optimze the rendering to allow for bigger matrices
* Have the grid be way bigger
* Implement save/load functionality
* Implement a few "stock seeds"
* Implement a fancier rendering
* Create app icon
