init;
calib_cfg;
for i=1:3
    disp(i)
    target_lens = i;
    
    if (target_lens - 1 > 0)
        left_lens = target_lens - 1;
    else
        left_lens = 6;
    end
    
    if (target_lens + 1 <= 6)
        right_lens = target_lens + 1;
    else
        right_lens = 1;
    end
    
    target_pair = sprintf('%d_%d', left_lens, target_lens);
    next_pair = sprintf('%d_%d', target_lens, right_lens);
    
    base = fullfile(root, 'data', 'ov_plane');
    
    % Data: Boards
    dsc_path = fullfile(base, 'checkerboard10x14_a0_1.dsc');
    tp_path = fullfile(base, 'ov_plane.tp');
    board_idxs = [];
    
    % Data: Corners
    train.orpc = glob(fullfile(base, '20220609/', target_pair, ...
        'output', 'right'), {'*.orpc'});
    if exist(strcat(base, '/20220609/', next_pair), 'dir')
         train.orpc = [train.orpc, glob(fullfile(base, '20220609', next_pair, ...
             'output', 'left'), {'*.orpc'})];
    end
    train.img = cellfun(@(x) [x(1:end-20) x(end-12:end-4) 'png'], train.orpc, 'UniformOutput',0);
    
    % test.orpc = glob(fullfile(base, 'corners', 'test'), {'*.orpc'});
    % test.img = cellfun(@(x) [x(1:end-4) 'png'], test.orpc, 'UniformOutput',0);
    
    [train.corners, train.boards, train.imgsize] = import_ODT(...
                                        train.orpc, dsc_path, tp_path,...
                                        'img_paths', train.img,...
                                        'board_idxs', board_idxs);
    
    % [test.corners, test.boards, test.imgsize] = import_ODT(...
    %                                     test.orpc, dsc_path, tp_path,...
    %                                     'img_paths', test.img,...
    %                                     'board_idxs', board_idxs);
    
    % Calibration
    output = sprintf('train_%d_%s', target_lens, cfg{2});
    train_model = calibrate(train.corners, train.boards, train.imgsize, cfg{:},...
                           'img_paths', train.img, 'board_idxs', board_idxs,...
                           'save_results', fullfile(base, 'results', output));
    
    % Evaluation (camera pose estimation)
%     output = sprintf('pose_%d_%s', target_lens, cfg{2});
%     pose = get_poses(train_model, train.corners, train.boards,...
%                            train.imgsize, cfg{:},...
%                            'img_paths', train.img, 'board_idxs', board_idxs,...
%                            'save_results', fullfile(base, 'results', output));
end

