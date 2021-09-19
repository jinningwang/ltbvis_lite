function createvideo(coords, visdata, map, video)
    %% program info
    % disp program info
    version = 'v1.2';
    fprintf('LTBVIS Lite \nVersion: [%s]\n', version)

    % disp I/O info
    fprintf('\nCoordination data: [%s]\n', coords)
    fprintf('Visualized data: [%s]\n', visdata)
    fprintf('Map file: [%s]\n', map)
    fprintf('Output file: [%s]\n', video)

    config_path = 'config.mat';
    load(config_path);
    fprintf('Load config from: [%s]\n', config_path)

    framerate = config.framerate;                          % fps (frames per second)
    scale = config.scale;                                        % data transformation range
    bus_radius = config.bus_radius;                     % in pixels
    plz = config.plz;                                              % parallazition enable
    area_en = config.area_en;                                % user selected area enable

    interpolate_timestamps = false;
    interpolate_method = 'natural';
    extrapolate_method = 'none';
    max_resolution = [720 1280];

    % check configure consistancy
    if area_en 
        if isempty(config.borders)
            msg1 = 'User selected area is enabled, but no area coordination is given!';
            error(msg1);
        end

        if (size(config.borders, 1) ~= 1 || size(config.borders, 2) ~= 4)
            msg2 = 'Area coordination format is wrong! Please input a 1 by 4 array.';
            error(msg2);
        end
        
        padding = [];
        borders = config.borders;
        fprintf('Focus area is user selected.\n')
        
    else
        fprintf('Focus area is auto selected.\n')
        padding = config.padding;
        borders = [];
    end
    
    
    % Amount of padding between the video's borders and the minimum/maximum
    % buses, in units of latitude/longitude, going from top, to right, to
    % bottom, to left. Either use this, or make it an empty matrix and use
    % borders instead.

    % Absolute borders of the video, in units of latitude/longitude, going
    % from top, to right, to bottom, to left. Either use this, or make it an
    % empty matrix and use padding instead.
    
    % Opacity of the countour layer
    opacity = 0.9;

    %% data info
    % read data
    gpstable = readtable(coords, 'VariableNamingRule', 'preserve');
    outtable = readtable(visdata, 'VariableNamingRule', 'preserve');
    outtable = sortrows(outtable, 'time'); % sort the data by time

    x = outtable{:, 'time'};
    Y = outtable{:, gpstable{:, 'name'}}';

    % Most extreme minimum/maximum values for the contour layer. Values
    % above/below this range will be clamped to it in the final video.
    contourmin = config.data_min;
    contourmax = config.data_max;
    
    if interpolate_timestamps
        xx = x(1):(1 / framerate):x(length(x));
        Y = spline(x, Y, xx);
        x = xx;
    end

    frames = length(x);

    cs = (Y - contourmin) / (contourmax - contourmin);
    xs = gpstable{:, 'xcoord'};
    ys = gpstable{:, 'ycoord'};

    % disp data info
    fprintf('\nData info\n')
    fprintf('There are %s sites, and %s time stamps.\n', num2str(size(xs, 1)), num2str(size(x, 1)))

    %% calculation
    worldmap = imread(map);
    [height, width, ~] = size(worldmap);

    if ~isempty(padding)
        xmin = min(xs) - padding(4);
        xmax = max(xs) + padding(2);
        ymin = max(ys) + padding(1);
        ymax = min(ys) - padding(3);
    elseif ~isempty(borders)
        xmin = borders(4);
        xmax = borders(2);
        ymin = borders(1);
        ymax = borders(3);
    else
        fprintf('Error: padding and borders can''t both be empty!\n');
        return
    end

    xs = (xs + 180) * (width / 360);
    ys = (-ys + 90) * (height / 180);
    xmin = min(max(round((xmin + 180) * (width / 360)), 1), width);
    xmax = min(max(round((xmax + 180) * (width / 360)), 1), width);
    ymin = min(max(round((-ymin + 90) * (width / 360)), 1), height);
    ymax = min(max(round((-ymax + 90) * (width / 360)), 1), height);

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
        worldmap = insertShape(worldmap, 'FilledCircle', [round(xs(i)) round(ys(i)) bus_radius], 'Color', 'white');
    end

    vw = VideoWriter(video, 'Motion JPEG AVI');
    vw.FrameRate = framerate;
    open(vw);

    F = scatteredInterpolant(ys, xs, zeros(length(xs), 1), interpolate_method, extrapolate_method);
    blend = vision.AlphaBlender('Operation', 'Blend');
    ff = zeros(height, width);

    fprintf('\nCalculation done!\n')

    %% video compilation
    bar = waitbar(0, 'video compiling...');

    for k = 1:frames
        str = ['video compiling... ', num2str(fix(100 * k / frames)), '%'];
        waitbar(k / frames, bar, str)

        F.Values = cs(:, k);

        % "parfor" is more efficient on multi-core systems
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

        frame(frame > 1) = 1;
        frame(frame < 0) = 0;
        frame(isnan(frame)) = 0.5;

        blend.Opacity = abs(frame - 0.5) * 2 * opacity;

        frame = im2uint8(ind2rgb(im2uint8(frame), jet));
        frame = blend(worldmap, frame);
        %frame = imfuse(worldmap, frame, 'blend');

        writeVideo(vw, frame);
    end

    close(bar);
    close(vw);

    fprintf('Save video to : [%s]\n', video)
end
