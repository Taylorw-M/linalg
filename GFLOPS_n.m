
clear;
clc;
close all;

%% 1. Load benchmark results

projectPath = '\\wsl.localhost\Ubuntu\home\tdogg\linalg';
resultsDir = fullfile(projectPath, 'results');
jsonPath = fullfile(resultsDir, 'matrix_results.json');

data = jsondecode(fileread(jsonPath));
benchmarks = data.benchmarks;

%% 2. Initialize arrays

nValues = [64, 128, 256, 512, 1024];
blockSizes = [16, 32, 64, 128, 256, 512];

naive = NaN(size(nValues));
ikj = NaN(size(nValues));

naiveStd = NaN(size(nValues));
ikjStd = NaN(size(nValues));

% Rows = matrix sizes
% Columns = block sizes
tile = NaN(numel(nValues), numel(blockSizes));
tileStd = NaN(size(tile));

%% 3. Extract benchmark data

for i = 1:numel(benchmarks)

    b = benchmarks(i);
    name = char(b.name);

    if ~isfield(b, 'GFLOPS')
        continue;
    end

    % Convert FLOP/s to GFLOPS
    value = b.GFLOPS / 1e9;

    % Naive multiplication
    tokens = regexp(name, ...
        '^BM_NaiveMultiply/(\d+)_(median|stddev)$', ...
        'tokens', 'once');

    if ~isempty(tokens)

        n = str2double(tokens{1});
        idx = find(nValues == n, 1);

        if ~isempty(idx)
            if strcmp(tokens{2}, 'median')
                naive(idx) = value;
            else
                naiveStd(idx) = value;
            end
        end

        continue;
    end

    % IKJ multiplication
    tokens = regexp(name, ...
        '^BM_ikjMultiply/(\d+)_(median|stddev)$', ...
        'tokens', 'once');

    if ~isempty(tokens)

        n = str2double(tokens{1});
        idx = find(nValues == n, 1);

        if ~isempty(idx)
            if strcmp(tokens{2}, 'median')
                ikj(idx) = value;
            else
                ikjStd(idx) = value;
            end
        end

        continue;
    end

    % Tiled multiplication
    tokens = regexp(name, ...
        '^BM_TilingMultiply/(\d+)/(\d+)_(median|stddev)$', ...
        'tokens', 'once');

    if ~isempty(tokens)

        n = str2double(tokens{1});
        block = str2double(tokens{2});
        statistic = tokens{3};

        row = find(nValues == n, 1);
        col = find(blockSizes == block, 1);

        if ~isempty(row) && ~isempty(col)

            if strcmp(statistic, 'median')
                tile(row, col) = value;
            else
                tileStd(row, col) = value;
            end
        end
    end
end

%% 4. Find best block size for each matrix

bestBlocks = NaN(size(nValues));
bestTile = NaN(size(nValues));
bestTileStd = NaN(size(nValues));

for i = 1:numel(nValues)

    valid = find(~isnan(tile(i, :)));

    if isempty(valid)
        continue;
    end

    [bestValue, localIdx] = max(tile(i, valid));

    col = valid(localIdx);

    bestBlocks(i) = blockSizes(col);
    bestTile(i) = bestValue;
    bestTileStd(i) = tileStd(i, col);
end

%% 5. Display performance results

fprintf('\n===== PERFORMANCE RESULTS =====\n');

resultsTable = table( ...
    nValues', naive', ikj', bestTile', bestBlocks', ...
    'VariableNames', ...
    {'MatrixSize', 'NaiveGFLOPS', 'IKJGFLOPS', ...
     'TiledGFLOPS', 'BestBlockSize'});

disp(resultsTable);

%% 6. GRAPH 1: GFLOPS vs Matrix Size

fig1 = figure(1);
clf(fig1);

set(fig1, 'Color', 'w', ...
    'Position', [100, 100, 1000, 650]);

hold on;

% Naive
valid = ~isnan(naive);
err = naiveStd(valid);
err(isnan(err)) = 0;

errorbar(nValues(valid), naive(valid), err, ...
    '-o', 'LineWidth', 2, 'MarkerSize', 7, ...
    'DisplayName', 'Naive');

% IKJ
valid = ~isnan(ikj);
err = ikjStd(valid);
err(isnan(err)) = 0;

errorbar(nValues(valid), ikj(valid), err, ...
    '-s', 'LineWidth', 2, 'MarkerSize', 7, ...
    'DisplayName', 'IKJ');

% Tiled
valid = ~isnan(bestTile);
err = bestTileStd(valid);
err(isnan(err)) = 0;

errorbar(nValues(valid), bestTile(valid), err, ...
    '-^', 'LineWidth', 2, 'MarkerSize', 7, ...
    'DisplayName', 'Tiled (Best Block)');

% Logarithmic x-axis
set(gca, 'XScale', 'log');

xticks(nValues);
xticklabels(string(nValues));

xlim([60, 1100]);

% Start y-axis at zero with enough room for IKJ
ylim([0, max(18, max([naive, ikj, bestTile], ...
    [], 'omitnan') * 1.1)]);

xlabel('Matrix Dimension (n)');
ylabel('GFLOPS');

title('Matrix Multiplication Performance');

legend('Location', 'best');

grid on;
box on;
hold off;

%% 7. GRAPH 2: GFLOPS vs Block Size

fig2 = figure(2);
clf(fig2);

set(fig2, 'Color', 'w', ...
    'Position', [200, 150, 1000, 650]);

hold on;

plotted = false;

for i = 1:numel(nValues)

    valid = ~isnan(tile(i, :));

    if ~any(valid)
        continue;
    end

    x = blockSizes(valid);
    y = tile(i, valid);

    err = tileStd(i, valid);
    err(isnan(err)) = 0;

    errorbar(x, y, err, ...
        '-o', ...
        'LineWidth', 2, ...
        'MarkerSize', 7, ...
        'DisplayName', sprintf('n = %d', nValues(i)));

    plotted = true;
end

% Logarithmic x-axis
set(gca, 'XScale', 'log');

xticks(blockSizes);
xticklabels(string(blockSizes));

xlim([14, 570]);

% Start y-axis at zero
ylim([0, inf]);

xlabel('Block Size');
ylabel('GFLOPS');

title('Tiled Matrix Multiplication: Block Size Performance');

if plotted
    legend('Location', 'best');
else
    warning(['No tiled benchmark data was found. ', ...
        'Check benchmark names in the JSON file.']);
end

grid on;
box on;
hold off;

%% 8. Export graphs

% Create export directory if it doesn't exist
exportDir = fullfile(projectPath, 'results', 'graphs');

if ~exist(exportDir, 'dir')
    mkdir(exportDir);
end

% Export Graph 1
exportgraphics(fig1, ...
    fullfile(exportDir, 'performance_comparison.png'), ...
    'Resolution', 300);

exportgraphics(fig1, ...
    fullfile(exportDir, 'performance_comparison.pdf'), ...
    'ContentType', 'vector');

savefig(fig1, ...
    fullfile(exportDir, 'performance_comparison.fig'));

% Export Graph 2
exportgraphics(fig2, ...
    fullfile(exportDir, 'block_size_comparison.png'), ...
    'Resolution', 300);

exportgraphics(fig2, ...
    fullfile(exportDir, 'block_size_comparison.pdf'), ...
    'ContentType', 'vector');

savefig(fig2, ...
    fullfile(exportDir, 'block_size_comparison.fig'));

fprintf('All graphs exported successfully!\n');

%% 9. Display optimal block sizes

fprintf('\n===== OPTIMAL BLOCK SIZES =====\n');

bestTable = table( ...
    nValues', bestBlocks', bestTile', bestTileStd', ...
    'VariableNames', ...
    {'MatrixSize', 'BestBlockSize', ...
     'MedianGFLOPS', 'StdDevGFLOPS'});

disp(bestTable);

fprintf('\nGraphs successfully generated.\n');

% Bring Graph 1 to the front.
% Graph 2 remains available as Figure 2.
figure(fig1);
