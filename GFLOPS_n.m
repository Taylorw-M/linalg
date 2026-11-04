
clear;
clc;
close all;

%% 1. Load benchmark JSON

projectPath = '\\wsl.localhost\Ubuntu\home\tdogg\linalg';
jsonPath = fullfile(projectPath, 'results', 'matrix_results.json');

data = jsondecode(fileread(jsonPath));
benchmarks = data.benchmarks;

%% 2. Initialize arrays

nValues = [64, 128, 256, 512, 1024];
blockSizes = [16, 32, 64, 128, 256, 512];

naiveGFLOPS = NaN(size(nValues));
ikjGFLOPS = NaN(size(nValues));

% Rows = matrix sizes, columns = block sizes
tileGFLOPS = NaN(length(nValues), length(blockSizes));

%% 3. Extract median benchmark results

for i = 1:numel(benchmarks)

    b = benchmarks(i);
    name = b.name;

    % Only use median measurements
    if ~endsWith(name, '_median')
        continue;
    end

    if ~isfield(b, 'GFLOPS')
        continue;
    end

    gflops = b.GFLOPS / 1e9;

    % Naive multiplication
    tokens = regexp(name, ...
        '^BM_NaiveMultiply/(\d+)_median$', ...
        'tokens', 'once');

    if ~isempty(tokens)
        n = str2double(tokens{1});
        idx = find(nValues == n, 1);

        if ~isempty(idx)
            naiveGFLOPS(idx) = gflops;
        end
        continue;
    end

    % IKJ multiplication
    tokens = regexp(name, ...
        '^BM_ikjMultiply/(\d+)_median$', ...
        'tokens', 'once');

    if ~isempty(tokens)
        n = str2double(tokens{1});
        idx = find(nValues == n, 1);

        if ~isempty(idx)
            ikjGFLOPS(idx) = gflops;
        end
        continue;
    end

    % Tiled multiplication
    tokens = regexp(name, ...
        '^BM_TilingMultiply/(\d+)/(\d+)_median$', ...
        'tokens', 'once');

    if ~isempty(tokens)
        n = str2double(tokens{1});
        block = str2double(tokens{2});

        row = find(nValues == n, 1);
        col = find(blockSizes == block, 1);

        if ~isempty(row) && ~isempty(col)
            tileGFLOPS(row, col) = gflops;
        end
    end
end

%% 4. Find optimal block size for each matrix

bestBlocks = NaN(size(nValues));
bestTileGFLOPS = NaN(size(nValues));

for i = 1:length(nValues)

    performance = tileGFLOPS(i, :);

    if all(isnan(performance))
        continue;
    end

    % Find maximum GFLOPS, ignoring missing data
    valid = find(~isnan(performance));
    [bestGFLOPS, localIdx] = max(performance(valid));

    bestIdx = valid(localIdx);

    bestBlocks(i) = blockSizes(bestIdx);
    bestTileGFLOPS(i) = bestGFLOPS;
end

%% 5. Display results in MATLAB

fprintf('\n===== OPTIMAL BLOCK SIZES =====\n');

resultsTable = table( ...
    nValues', ...
    bestBlocks', ...
    bestTileGFLOPS', ...
    'VariableNames', ...
    {'MatrixSize', 'BestBlockSize', 'GFLOPS'});

disp(resultsTable);

%% 6. Plot GFLOPS vs matrix size

figure;

plot(nValues, naiveGFLOPS, '-o', ...
    'LineWidth', 2, 'MarkerSize', 7);
hold on;

plot(nValues, ikjGFLOPS, '-s', ...
    'LineWidth', 2, 'MarkerSize', 7);

plot(nValues, bestTileGFLOPS, '-^', ...
    'LineWidth', 2, 'MarkerSize', 7);

xlabel('Matrix Dimension (n)');
ylabel('GFLOPS');
title('Matrix Multiplication Performance');

legend('Naive', 'IKJ', 'Tiled (Best Block)', ...
    'Location', 'best');

grid on;
hold off;

%% 7. Plot GFLOPS vs block size

figure;
hold on;

for i = 1:length(nValues)

    if all(isnan(tileGFLOPS(i, :)))
        continue;
    end

    plot(blockSizes, tileGFLOPS(i, :), '-o', ...
        'LineWidth', 2, ...
        'DisplayName', sprintf('n = %d', nValues(i)));
end

xlabel('Block Size');
ylabel('GFLOPS');
title('Tiled Multiplication: Block Size Performance');

legend('Location', 'best');
grid on;
hold off;

%% 8. Print best block for largest matrix

validRows = find(~isnan(bestBlocks));

if ~isempty(validRows)

    idx = validRows(end);

    fprintf('\nLargest tested matrix:\n');
    fprintf('Matrix size: %d x %d\n', ...
        nValues(idx), nValues(idx));

    fprintf('Best block size: %d\n', bestBlocks(idx));

    fprintf('Performance: %.3f GFLOPS\n', ...
        bestTileGFLOPS(idx));

else
    warning('No tiled median results found. Check JSON names.');
end
