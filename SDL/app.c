#include "updatePixels.h"


void app() {
    Cell allCells[CELL_TOTAL_NUMBER] = {};

    initCells(allCells);
    simFlush();

    while (1) {        
        updatePixels(allCells);
        simFlush();
    }
}
