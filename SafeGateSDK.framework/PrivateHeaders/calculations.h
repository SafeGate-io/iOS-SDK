//
//  calculations.h
//  ThermalCamera
//
//  Created by Kirill Budevich on 8/27/20.
//  Copyright © 2020 Yellow Systems. All rights reserved.
//

#ifndef calculations_h
#define calculations_h

#include <stdio.h>

typedef struct {
    uint8_t number_row;    // number of raws
    uint8_t number_col;    // number of column
    uint8_t number_blocks; // number of blocks (top + down)
    uint16_t number_pixel;  // number of pixel
} characteristics;

characteristics sensor;
void setup_eeprom(uint8_t eeprom_dump[]);
uint16_t* get_pixel_temps(uint8_t ptat_dump[], uint8_t pixel_dump[]);
uint16_t get_ambient_temperature(void);

#endif /* calculations_h */
