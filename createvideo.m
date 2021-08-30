function createvideo(coords, visdata, map, video, plz)

    %% program info
    % disp program info
    version = 'v1.1';
    fprintf('LTBVIS Lite \nVersion: [%s]\n', version)
    
    % disp I/O info
    fprintf('\nCoordination data: [%s]\n', coords)
    fprintf('Visualized data: [%s]\n', visdata)
    fprintf('Map file: [%s]\n', map)
    fprintf('Parallelization: [%s]\n', num2str(plz))

    framerate = 30; % fps (frames per second)
    padding = 100; % Measured in pixels
    scale = 0.001; % data transformation range
    
    interpolate_timestamps = false;
    interpolate_method = 'natural';
    extrapolate_method = 'none';
    max_resolution = [720 1280];

    %% data info
    % read data
    gpstable = readtable(coords, 'VariableNamingRule', 'preserve');
    outtable = readtable(visdata, 'VariableNamingRule', 'preserve');
    outtable = sortrows(outtable, 'time'); % sort the data by time

    x = outtable{:, 'time'};
    Y = outtable{:, gpstable{:, 'name'}}';

    if interpolate_timestamps
        xx = (x(1)* framerate):(1 / framerate):x(length(x));
        Y = spline(x, Y, xx);
        x = xx;
    end

    frames = length(x); 

    cs = (Y - 1 + scale) / (2 * scale);
    xs = gpstable{:, 'xcoord'};
    ys = gpstable{:, 'ycoord'};

    % disp data info
    fprintf('\nData info\n')
    fprintf('There are %s sites, and %s time stamps.\n', num2str(size(xs, 1)), num2str(size(x, 1)))
    
    %% calcualtion
    worldmap = imread(map);
    [height, width, ~] = size(worldmap);

    xs = (xs + 180) * (width / 360);
    ys = (-ys + 90) * (height / 180);

    xmin = round(min(xs) - padding);
    xmax = round(max(xs) + padding);
    ymin = round(min(ys) - padding);
    ymax = round(max(ys) + padding);

    worldmap = worldmap(ymin:ymax, xmin:xmax, :);
    [height, width, ~] = size(worldmap);
    xs = xs - xmin;
    ys = ys - ymin;
    
    desired_ratio = max_resolution(2) / max_resolution(1);
    ratio = width / height;
    
    if ratio < desired_ratio
        scale = max_resolution(1) / height;
    else
        scale = max_resolution(2) / width;
    end
    
    worldmap = imresize(worldmap, scale);
    [height, width, ~] = size(worldmap);
    xs = xs * scale;
    ys = ys * scale;

    for i = 1:length(xs)
        worldmap = insertShape(worldmap, 'FilledCircle', [round(xs(i)) round(ys(i)) 8], 'Color', 'white');
    end

    vw = VideoWriter(video, 'Motion JPEG AVI');
    vw.FrameRate = framerate;
    open(vw);

    F = scatteredInterpolant(ys, xs, zeros(length(xs), 1), interpolate_method, extrapolate_method);
    ff = zeros(height, width);

    fprintf('\nCalculation done!\n')
    
    %% video compilation
    bar = waitbar(0, 'video compiling...');
            
    for k = 1:frames

        str=['video compiling...', num2str(fix(100 * k / frames)), '%'];
        waitbar(k / frames, bar, str)
        
        F.Values = cs(:, k);

        % "parfor" is more efficient
        if plz
            
            parfor j = 1:width
                ff(:, j) = F(1:height, repelem(j, height));
            end
            
        else
            
            for j = 1:width
                ff(:, j) = F(1:height, repelem(j, height));
            end
            
        end

        frame = ff;
        frame(isnan(frame)) = 0.5;
        frame = ind2rgb(uint8(frame * 255), jet);
        frame = imfuse(worldmap, frame, 'blend');

        writeVideo(vw, frame);
        
    end
    close(bar);
    close(vw);
    
    fprintf('Save video to : [%s] \n', video)
    
end
