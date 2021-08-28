# LTBVIS Lite

MATLAB 2D geographical visualization tool. It visualizes the data with geographical coordination on a given 2D map and compiles the time-series data into a movie.

## Environment
LTBVIS Lite runs on MATLAB R2021a, and other versions have not beed tested.

## I/O Format

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
 
### coords
`coords` are the sites coordination in csv format. Example file looks like:

|  name  | xcoord  | ycoord |
|  ----  | ----  | ---- |
|  Site 1  |  100.1  |  99.9  |
|  Site 2  | 99.8 | 97.6 |
|...|...|...|...|...|...|
|  Site N  | 96.5 | 93.4 |

* *name* should be consistent with `visdata`.

### map
The predefined map is a world map from:
<https://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73751/world.topo.bathy.200407.3x21600x10800.jpg>

### output
The output will be a video file in avi format.

## Tutorial
In the LTBVIS Lite directory, run the command below:

```
createvideo('wecc_gps.csv', 'wecc_out.csv', 'worldmap.jpg', 'wecc.avi', true)
```

After the program finished, your video is prepared in the same directory.

## Citing LTB
```
[1] F. Li, K. Tomsovic, and H. Cui, “A Large-Scale Testbed as a Virtual Power Grid: For Closed-Loop Controls in Research and Testing,” IEEE Power and Energy Mag., vol. 18, no. 2, pp. 60–68, Mar. 2020, doi: 10.1109/MPE.2019.2959054.
[2] H. Cui, F. Li, and K. Tomsovic, “Cyber‐physical system testbed for power system monitoring and wide‐area control verification,” IET Energy Systems Integration, vol. 2, no. 1, pp. 32–39, Mar. 2020, doi: 10.1049/iet-esi.2019.0084.
```

## Contributors
Nicholas West, Jinning Wang, Hantao Cui, Can Huang, Fangxing Li.