classdef VideoRenderer < handle
    properties
        data_min = 0.9998
        data_max = 1.0002
        opacity = 0.9
        
        interpolate_method = 'natural'
        extrapolate_method = 'none'
        interpolate_timestamps = false
        
        max_resolution = [720 1280]
        borders = [47.455 -66.8628 24.3959 -124.8679]
        padding = []
        framerate = 30
        bus_radius = 3
        
        parallelize = true
    end
    
    properties (Access = private)
        coords_table
        visdata_table
        map_image
        interp
        blend
    end
    
    methods
        function this = VideoRenderer
            this.blend = vision.AlphaBlender('Operation', 'Blend');
        end
        
        function load_coords_and_visdata(this, coords_file, visdata_file)
            this.coords_table = readtable(coords_file, 'VariableNamingRule', 'preserve');
            this.visdata_table = readtable(visdata_file, 'VariableNamingRule', 'preserve');
            this.visdata_table = sortrows(this.visdata_table, 'time'); % sort the data by time
            
            this.interp = scatteredInterpolant(this.coords_table{:, 'ycoord'}, this.coords_table{:, 'xcoord'}, zeros(length(xs), 1));
        end
        
        function load_map(this, map_file)
            
        end
    end
end