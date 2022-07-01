init;
calib_cfg;
for i=1:5
    disp(i)
    target_lens = i;
    
    if (target_lens - 1 > 0)
        left_lens = target_lens - 1;
    else
        left_lens = 6;
    end
    
    target_pair = sprintf('%d_%d', left_lens, target_lens);
    
    base = fullfile(root, 'data', 'ov_plane');
    
    % Data: Boards
    dsc_path = fullfile(base, 'checkerboard10x14_a0_1.dsc');
    tp_path = fullfile(base, 'ov_plane.tp');
    board_idxs = [];
    
    % Data: Corners
    left.orpc = glob(fullfile(base, '20220609', target_pair, ...
        'output', 'left'), {'*.orpc'}); 
    right.orpc = glob(fullfile(base, '20220609', target_pair, ...
        'output', 'right'), {'*.orpc'});
    left.img = cellfun(@(x) [x(1:end-20) x(end-12:end-4) 'png'], left.orpc, 'UniformOutput',0);
    right.img = cellfun(@(x) [x(1:end-20) x(end-12:end-4) 'png'], right.orpc, 'UniformOutput',0);
    
    % test.orpc = glob(fullfile(base, 'corners', 'test'), {'*.orpc'});
    % test.img = cellfun(@(x) [x(1:end-4) 'png'], test.orpc, 'UniformOutput',0);
    
    [left.corners, left.boards, left.imgsize] = import_ODT(...
                                        left.orpc, dsc_path, tp_path,...
                                        'img_paths', left.img,...
                                        'board_idxs', board_idxs);
    [right.corners, right.boards, right.imgsize] = import_ODT(...
                                        right.orpc, dsc_path, tp_path,...
                                        'img_paths', right.img,...
                                        'board_idxs', board_idxs);

    left_file = sprintf('data/ov_plane/results/pose_%d_kb_poses_20220623.mat', left_lens);
    left_model = load(left_file);
    right_file = sprintf('data/ov_plane/results/pose_%d_kb_poses_20220623.mat', target_lens);
    right_model = load(right_file);
    
    % [test.corners, test.boards, test.imgsize] = import_ODT(...
    %                                     test.orpc, dsc_path, tp_path,...
    %                                     'img_paths', test.img,...
    %                                     'board_idxs', board_idxs);
    
    % Evaluation (camera pose estimation)
    left_output = sprintf('pose_left_%d_%s', left_lens, cfg{2});
    left_pose = get_poses(left_model.model, left.corners, left.boards,...
                           left.imgsize, cfg{:},...
                           'img_paths', left.img, 'board_idxs', board_idxs,...
                           'save_results', fullfile(base, 'results', left_output));
    right_output = sprintf('pose_right_%d_%s', target_lens, cfg{2});
    right_pose = get_poses(right_model.model, right.corners, right.boards,...
                            right.imgsize, cfg{:},...
                            'img_paths', right.img, 'board_idxs', board_idxs,...
                            'save_results', fullfile(base, 'results', right_output));
    
%     disp(size(left_pose.Rt, 3));
%     disp(size(right_pose.Rt, 3));

    for j=1:size(left_pose.Rt, 3)
        Rt = [right_pose.Rt(:, :, j); [0 0 0 1]] / [left_pose.Rt(:, :, j); [0 0 0 1]];
        axang = rotm2axang(Rt(1:3, 1:3));
        translation = Rt(1:3, 4:4);
        disp(Rt);
        disp(axang);
        disp(sqrt(translation(1).^2 + translation(2).^2 + translation(3).^2))
        disp(axang(4) * 180 / pi);
    end
end

