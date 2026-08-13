% Spike detection for DFF dendritic calcium imaging
% Palmer Lab
% 01 August 2026

% Set values; Default 0
stimulus = 0:0;
baseline = 0:0;
event_duration = 0;
mini_events_gap = 0;


all_ca_event = zeros(1, nTrials);
avg_trial_spk = zeros(1,nRois);
all_Roi_ca_events = cell (1,nRois);
all_jitter = zeros(1, nTrials);

for i = 1:nRois
    for k = 1:nTrials
       rise_edge = 0;
       fall_edge = 0;
       
       ftrace = dffmat{k,i};
      threshold = 2 * (std(ftrace(baseline)));   
       sup_ftrace = ftrace > threshold;
       diff_sup_ftrace = diff(sup_ftrace);
       rise_edge = find(diff_sup_ftrace == 1);
       fall_edge = find(diff_sup_ftrace == -1);
        a = size(rise_edge); a = a(2);
        b = size(fall_edge); b = b(2);
        if a > b
           rise_edge = rise_edge(1:end-1);
        elseif b > a
           fall_edge(1) = [];
        end    
        
       diff_sup_ftrace (rise_edge) = rise_edge;
       diff_sup_ftrace (fall_edge) = fall_edge;            
       detect_event = (fall_edge - rise_edge) > event_duration;

        if sum(detect_event) ~= 0 
            for event = 1:length(detect_event)
                event_peak = detect_event;
                if detect_event(event) == 1
                    onset = rise_edge(event);
                    offset = fall_edge(event);
                    signal_window = ftrace(onset:offset);   
                    [peak, idxs] = sort(signal_window,'descend','MissingPlacement','last');
                    event_peak(event) = onset + find(idxs==1) - 1;
                end
            end

            event = 1;
            pre_peak = 0;
            while event <= length(detect_event)
                if detect_event(event) ~= 0 && pre_peak == 0
                    pre_peak = event_peak(event);
                elseif detect_event(event) == 1
                    if event_peak(event) - pre_peak <= mini_events_gap
                        detect_event(event) = 0;
                    else
                        pre_peak = event_peak(event);
                    end
                end
                event = event + 1;
            end
        end
       
       diff_sup_ftrace(rise_edge) = detect_event;     
       diff_sup_ftrace (fall_edge) = 0 ;

       
        if sum(detect_event) == 0 
           diff_sup_ftrace  = zeros (1,size(ftrace,2));
        end
      
       spk = diff_sup_ftrace;
       jitter = find(spk(stimulus) == 1);
       nspk = sum(spk(stimulus));
       
       h = isempty(jitter); 
       
       if h == 1
           jitter = 0;
       end 
       
       if nspk > nTrials
           disp('-->indexing problem, double check diff_sup_ftrace vector')
       end
       ampl = 0;
       if nspk > 0 
           diff_sup_ftrace(1:290) = ftrace(1:290); 
           ampl = findpeaks(ftrace(stimulus),'MinPeakheight',threshold, 'MinPeakDistance',20);        
            
       end
           
       all_ca_event (1,k) =  nspk;
       all_ampl {1,k} = ampl;
       
    end
    
    all_Roi_ca_events{i} = all_ca_event;
    
    for k= 1:nTrials
        log_all_jitter = all_jitter ~=0;
        jitter = all_jitter(log_all_jitter); 
        jit_std = std (jitter);
        jit_var = var (jitter);
        jit_avg = mean(jitter);
     
    end
     
    all_Roi_jitter{i} = jitter;
        
    all_Roi_ampl{i} = all_ampl;
    
    for k =1:nTrials
        if all_Roi_ampl{1,i}{1,k} == 0
            all_Roi_ampl{1,i}{1,k} = [];
            amp_vec = cell2mat(all_Roi_ampl{1,i})';           
        end
    end     
    all_Roi_ampl{i} = mean(amp_vec);
    
    avg_spk_rate(i) = (sum(all_ca_event)/nTrials);

    %% DATA OUTPUT
    avg_spk_rate = avg_spk_rate';             % GIVES FREQUENCY OF CALCIUM EVENTS FOR EACH ROI
    all_Roi_ampl = all_Roi_ampl;                   % GIVES mean AMPLITUDES OF CALCIUM EVENTS FOR EACH ROI
    all_Roi_ALL_amplitudes{i} =amp_vec;       % GIVES ALL AMPLITUDES OF CALCIUM EVENTS FOR EACH ROI
    

    all_ampl (:) = [];
    all_jitter(:)= [];
end



