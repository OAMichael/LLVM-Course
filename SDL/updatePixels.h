#include "lib/sim.h"

#define CELL_DEAD_STATUS    0
#define CELL_ALIVE_STATUS   1
#define CELL_MAX_GENERATION 10

#define CELL_PIXEL_SIZE     16
#define CELL_WIDTH_COUNT    (SIM_X_SIZE / CELL_PIXEL_SIZE)
#define CELL_HEIGHT_COUNT   (SIM_Y_SIZE / CELL_PIXEL_SIZE)
#define CELL_TOTAL_NUMBER   (CELL_WIDTH_COUNT * CELL_HEIGHT_COUNT)


typedef struct Cell {
    unsigned int lifeStatus;
    unsigned int generation;
} Cell;


static inline int makeColor(const int r, const int g, const int b) {
    const int a = 255;
    int outColor = 
          ((a & 0xFF) << 24)
        | ((r & 0xFF) << 16)
        | ((g & 0xFF) <<  8)
        | ((b & 0xFF) <<  0);

    return outColor;
}


static void paintCellPixels(const int cellX, const int cellY, const int color) {
    // +1 and -1 made for cell border
    const int winXStart = cellX * CELL_PIXEL_SIZE + 1;
    const int winYStart = cellY * CELL_PIXEL_SIZE + 1;
    const int winXEnd   = cellX * CELL_PIXEL_SIZE + CELL_PIXEL_SIZE - 1;
    const int winYEnd   = cellY * CELL_PIXEL_SIZE + CELL_PIXEL_SIZE - 1;

    for (int winY = winYStart; winY < winYEnd; ++winY) {
        for (int winX = winXStart; winX < winXEnd; ++winX) {
            simPutPixel(winX, winY, color);
        }
    }
}


static void initCells(Cell allCells[CELL_TOTAL_NUMBER]) {
    for (int j = 0; j < CELL_HEIGHT_COUNT; ++j) {
        for (int i = 0; i < CELL_WIDTH_COUNT; ++i) {
            int val = simRand() % 31;

            if (!val) {
                allCells[i + j * CELL_WIDTH_COUNT].lifeStatus = CELL_ALIVE_STATUS;
                allCells[i + j * CELL_WIDTH_COUNT].generation = 1;

                const int cellColor = makeColor(0, 255, 0);
                paintCellPixels(i, j, cellColor);
            }
        }
    }
}


static void updatePixels(Cell allCells[CELL_TOTAL_NUMBER]) {

    // Used for updating cells' data after main loop. Yes, it is slow but no alternative
    static Cell swapCells[CELL_TOTAL_NUMBER] = {};

    // Loop over all cells
    for (int j = 0; j < CELL_HEIGHT_COUNT; ++j) {
        for (int i = 0; i < CELL_WIDTH_COUNT; ++i) {
            const int currentCellIdx = i + j * CELL_WIDTH_COUNT;

            const int idxLeft   = (i - 1 + CELL_WIDTH_COUNT) % CELL_WIDTH_COUNT;
            const int idxMidX   = (i + 0) % CELL_WIDTH_COUNT;
            const int idxRight  = (i + 1) % CELL_WIDTH_COUNT;

            const int idxBottom = (j - 1 + CELL_HEIGHT_COUNT) % CELL_HEIGHT_COUNT;
            const int idxMidY   = (j + 0) % CELL_HEIGHT_COUNT;
            const int idxUp     = (j + 1) % CELL_HEIGHT_COUNT;


            const int neighbStates[8] = {
                allCells[idxLeft  + idxBottom * CELL_WIDTH_COUNT].lifeStatus,
                allCells[idxLeft  + idxMidY   * CELL_WIDTH_COUNT].lifeStatus,
                allCells[idxLeft  + idxUp     * CELL_WIDTH_COUNT].lifeStatus,

                allCells[idxMidX  + idxBottom * CELL_WIDTH_COUNT].lifeStatus,
                allCells[idxMidX  + idxUp     * CELL_WIDTH_COUNT].lifeStatus,

                allCells[idxRight + idxBottom * CELL_WIDTH_COUNT].lifeStatus,
                allCells[idxRight + idxMidY   * CELL_WIDTH_COUNT].lifeStatus,
                allCells[idxRight + idxUp     * CELL_WIDTH_COUNT].lifeStatus
            };

            int numNeighbourAlive = 0;
            for(int k = 0; k < 8; ++k)
                if(neighbStates[k] == CELL_ALIVE_STATUS)
                    ++numNeighbourAlive;


            // Birth if 2 / Survival if 0 or 3 or 4 or 5
            // Handle 4 technical cases by nested if's
            if (allCells[currentCellIdx].lifeStatus == CELL_ALIVE_STATUS) {
                if (numNeighbourAlive == 0 || numNeighbourAlive == 3 || numNeighbourAlive == 4 || numNeighbourAlive == 5) {
                    swapCells[currentCellIdx].lifeStatus = CELL_ALIVE_STATUS;
                    swapCells[currentCellIdx].generation = allCells[currentCellIdx].generation + 1;
                }
                else {
                    swapCells[currentCellIdx].lifeStatus = CELL_DEAD_STATUS;
                    swapCells[currentCellIdx].generation = 0;
                }
            }
            else {
                if (numNeighbourAlive == 2) {
                    swapCells[currentCellIdx].lifeStatus = CELL_ALIVE_STATUS;
                    swapCells[currentCellIdx].generation = 1;
                }
                else {
                    swapCells[currentCellIdx].lifeStatus = CELL_DEAD_STATUS;
                    swapCells[currentCellIdx].generation = 0;
                }
            }
        }
    }

    // Usage of swap cells
    for (int j = 0; j < CELL_HEIGHT_COUNT; ++j) {
        for (int i = 0; i < CELL_WIDTH_COUNT; ++i) {
            const int currentCellIdx = i + j * CELL_WIDTH_COUNT;

            allCells[currentCellIdx].lifeStatus = swapCells[currentCellIdx].lifeStatus;
            allCells[currentCellIdx].generation = swapCells[currentCellIdx].generation;

            int cellColor = 0;
            if (allCells[currentCellIdx].generation == CELL_MAX_GENERATION) {
                allCells[currentCellIdx].lifeStatus = CELL_DEAD_STATUS;
                allCells[currentCellIdx].generation = 0;
            }

            if (allCells[currentCellIdx].lifeStatus == CELL_ALIVE_STATUS) {
                int currGeneration = allCells[currentCellIdx].generation;

                int r = 0, g = 0, b = 0;
                if (currGeneration > CELL_MAX_GENERATION - 4)
                    r = 127 - 2 * (CELL_MAX_GENERATION - currGeneration);

                if (currGeneration < CELL_MAX_GENERATION / 2)
                    g = 255 / allCells[currentCellIdx].generation;
    
                if (currGeneration >= CELL_MAX_GENERATION / 2 && currGeneration <= CELL_MAX_GENERATION - 4)
                    b = 127;

                cellColor = makeColor(r, g, b);
            }
            paintCellPixels(i, j, cellColor);
        }
    }
}
