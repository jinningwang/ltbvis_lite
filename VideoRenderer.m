classdef VideoRenderer < handle
    properties
        coords_file = []
        visdata_file = []
        map_file = []

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

    properties(SetAccess = private, GetAccess = public)
        frames
    end

    properties (Access = private)
        xs
        ys
        cs
        map_img
        interp
        blend
    end

    methods
        function this = VideoRenderer
            this.blend = vision.AlphaBlender('Operation', 'Blend');
        end

        function setup(this)
            %% data info
            % read data
            coords_table = readtable(this.coords_file, 'VariableNamingRule', 'preserve');
            visdata_table = readtable(this.visdata_file, 'VariableNamingRule', 'preserve');
            visdata_table = sortrows(visdata_table, 'time'); % sort the data by time

            x = visdata_table{:, 'time'};
            Y = visdata_table{:, coords_table{:, 'name'}}';

            if this.interpolate_timestamps
                xx = x(1):(1 / this.framerate):x(length(x));
                Y = spline(x, Y, xx);
                x = xx;
            end

            this.frames = length(x);

            this.cs = (Y - this.data_min) / (this.data_max - this.data_min);
            this.xs = coords_table{:, 'xcoord'};
            this.ys = coords_table{:, 'ycoord'};

            %% calculation
            this.map_img = imread(this.map_file);
            [height, width, ~] = size(this.map_file);

            if ~isempty(this.padding)
                xmin = min(this.xs) - this.padding(4);
                xmax = max(this.xs) + this.padding(2);
                ymin = max(this.ys) + this.padding(1);
                ymax = min(this.ys) - this.padding(3);
            elseif ~isempty(this.borders)
                xmin = this.borders(4);
                xmax = this.borders(2);
                ymin = this.borders(1);
                ymax = this.borders(3);
            else
                error('Error: padding and borders can''t both be empty!\n');
            end

            this.xs = (this.xs + 180) * (width / 360);
            this.ys = (-this.ys + 90) * (height / 180);
            xmin = min(max(round((xmin + 180) * (width / 360)), 1), width);
            xmax = min(max(round((xmax + 180) * (width / 360)), 1), width);
            ymin = min(max(round((-ymin + 90) * (width / 360)), 1), height);
            ymax = min(max(round((-ymax + 90) * (width / 360)), 1), height);

            this.map_img = this.map_img(ymin:ymax, xmin:xmax, :);
            [height, width, ~] = size(this.map_img);
            this.xs = this.xs - xmin;
            this.ys = this.ys - ymin;

            desired_ratio = this.max_resolution(2) / this.max_resolution(1);
            ratio = width / height;

            if ratio < desired_ratio
                scale = this.max_resolution(1) / height;
            else
                scale = this.max_resolution(2) / width;
            end

            this.map_img = imresize(this.map_img, scale);
            this.xs = this.xs * scale;
            this.ys = this.ys * scale;

            for i = 1:length(this.xs)
                this.map_img = insertShape(this.map_img, 'FilledCircle', [round(this.xs(i)) round(this.ys(i)) this.bus_radius], 'Color', 'white');
            end

            this.interp = scatteredInterpolant(this.ys, this.xs, zeros(length(this.xs), 1), this.interpolate_method, this.extrapolate_method);
        end

        function img = genframe(this, k)
            this.interp.Values = this.cs(:, k);

            [height, width, ~] = size(this.map_img);
            img = zeros(height, width);

            % "parfor" is more efficient on multi-core systems
            if this.parallelize
                parfor j = 1:width
                    img(:, j) = this.interp(1:height, repelem(j, height));
                end
            else
                for j = 1:width
                    img(:, j) = this.interp(1:height, repelem(j, height));
                end
            end

            img(img > 1) = 1;
            img(img < 0) = 0;
            img(isnan(img)) = 0.5;

            this.blend.Opacity = abs(img - 0.5) * 2 * this.opacity;

            img = im2uint8(ind2rgb(im2uint8(img), jet));
            img = this.blend(this.map_img, img);
            %frame = imfuse(worldmap, frame, 'blend');
        end

        function genvideo(this, video_file, pbar)
            % Infer encoding method from file extension
            [~, ~, ext] = fileparts(video_file);

            if strcmp(ext, '.avi')
                video_encoding = 'Motion JPEG AVI';
            elseif strcmp(ext, '.mp4')
                video_encoding = 'MPEG-4';
            elseif strcmp(ext, '.mj2')
                video_encoding = 'Motion JPEG 2000';
            else
                error('%s does not have a recognized file extension', video_file);
            end

            vw = VideoWriter(video_file, video_encoding);
            vw.FrameRate = this.framerate;
            open(vw);

            if nargin < 3
                pbar = false
            end

            if pbar
                bar = waitbar(0, 'Generating video...');
            end

            for k = 1:this.frames
                if pbar
                    str = ['Generating video... ' num2str(fix(100 * k / this.frames)) '%'];
                    waitbar(k / this.frames, bar, str);
                end

                writeVideo(vw, genframe(this, k));
            end

            close(vw);

            if pbar
                close(bar);
            end
        end
    end
end
