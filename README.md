# LTBVIS Lite

MATLAB 2D geographical visualization tool. It visualizes the data with geographical coordination on a 2D map and compiles the results into a **movie**.

LTBVIS Lite is part of the [CURENT Large-Scale Testbed(LTB)](https://github.com/CURENT/ltb).

## Why LTBVIS Lite

LTBVIS Lite is a **standalone** and **lightweight** visualization tool.

## Installation

LTBVIS Lite runs on **MATLAB R2021a**.

## I/O Format

### coords
`coords` are the sites coordination in csv format. Example file looks like:

|  name  | xcoord  | ycoord |
|  ----  | ----  | ---- |
|  Site 1  |  100.1  |  99.9  |
|  Site 2  | 99.8 | 97.6 |
|...|...|...|...|...|...|
|  Site N  | 96.5 | 93.4 |

* *name* should be consistent with `visdata`.

### visdata
`visdata` is time-series data in csv format. It contains the time stamp and data series on each location. Example file looks like:

|  time  | Site 1 | Site 2 |  ...  | Site N |
|  ----  | ----  | ----  | ----  | ----  |
|  0.00  |  1.00  |  1.00  |  ...  |  1.00  |
|  0.05  | 0.99 | 0.98 |...|0.97|
|...|...|...|...|...|...|
|  1.00  | 0.92 | 0.91 |...|0.89|

* Location names should be consistent with the `coords`.
* The time stamp column should be named as *time*.

### default map
You can get the map source file from:
<https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73751/world.topo.bathy.200407.3x21600x10800.jpg>

### video
The output will be a video file in avi format.

## Tutorial
In the LTBVIS Lite directory, run the command below:

```
createvideo('wecc_gps.csv', 'wecc_out.csv', 'worldmap.jpg', 'wecc.avi')
```

After the program finished, your video is prepared in the same directory.

## Function
The main function is `createvide`, which takes four parameters.

```
createvideo(coords, visdata, map, video)
```

| name    | type   | info                         |
|---------|--------|------------------------------|
| coords  | string | sites coordination csv file. |
| visdata | string | visualized data csv file.    |
| map     | string | base map file.               |
| video   | string | output video file.           |

## Config
Some parameters are stored in `config.mat`. You can modify it manually.

| name       | default value                        | info                                                  |
|------------|--------------------------------------|-------------------------------------------------------|
| framerate  | 30                                   | fps (frames per second).                              |
| padding    | 100                                  | measured in pixels.                                   |
| scale      | 0.0002                               | data transformation range.                            |
| bus_radius | 3                                    | bus point size, in pixels.                            |
| plz        | 1                                    | parallelization enable, set 0 to turn off.            |
| data_max   | 1.0002                               | maximum line of visualized data.                      |
| data_min   | 0.9998                               | minimum line of visualized data.                      |
| area_en    | 0                                    | enable for user selected focus area, set 1 to turn on.|
| borders    | [47.4550 -66.8628 24.3959 -124.8679] | user selected area coords.                            |

* Parallelization can greatly accelerate the video compiling. If your device does not support parallelization, turn off `plz`.
* Make sure `borders` are correctly assigned if `area_en` is enabled.

## Citing LTB
```
[1] F. Li, K. Tomsovic, and H. Cui, “A Large-Scale Testbed as a Virtual Power Grid: For Closed-Loop Controls in Research and Testing,” IEEE Power and Energy Mag., vol. 18, no. 2, pp. 60–68, Mar. 2020, doi: 10.1109/MPE.2019.2959054.
[2] H. Cui, F. Li, and K. Tomsovic, “Cyber‐physical system testbed for power system monitoring and wide‐area control verification,” IET Energy Systems Integration, vol. 2, no. 1, pp. 32–39, Mar. 2020, doi: 10.1049/iet-esi.2019.0084.
```

## Contributors
[Nicholas West](https://github.com/TheHashTableSlasher), [Jinning Wang](https://github.com/jinningwang), [Hantao Cui](https://github.com/cuihantao), Can Huang, Fangxing Li.
