%% MASC Analysis
% This analysis compares sentiment decoding from visual, auditory, 
% and text based features with subject ratings
%
% by marianne, march 2018

%% Observer Ratings
% Load in & plot mean valence ratings from video only condition (no sounds)
% load sentiment_setup
mean_obs_ratings=filenames('/Users/maus/Desktop/dissertation/FacialDecoding/labmeetinganalysis/rating/*.csv','absolute');
for s = 1:length(mean_obs_ratings)
    dat = dlmread(mean_obs_ratings{s},',',2,1);
    sub_num=mean_obs_ratings{s}(end-8:end-6);
    sub_vid=mean_obs_ratings{s}(end-8:end-4);
%     plot(dat);title(sub_vid);
%     pause;close;
end

%% Compare Emotient Sentiment with Mean Observer Ratings
emotient_decoding=filenames('/Users/maus/Desktop/dissertation/FacialDecoding/labmeetinganalysis/emotient/*.csv','absolute');
% subject agnositic
% saved in emotient_headers
% headers: Frametime	Face X	Face Y	Face Width	Face Height	AU1	AU2	AU4	AU5	AU6	AU7	AU9	AU10	AU12	AU14	AU15	AU17	AU18	AU20	AU23	AU24	AU25	AU26	AU28	AU43	angerEvidence	contemptEvidence	disgustEvidence	joyEvidence	fearEvidence	sadnessEvidence	surpriseEvidence
% last col: angerEvidence	contemptEvidence	disgustEvidence	joyEvidence	fearEvidence	sadnessEvidence	surpriseEvidence
for s = 1:length(emotient_decoding)
    rate_dat = dlmread(mean_obs_ratings{s},',',2,1);
    emotient_dat = dlmread(emotient_decoding{s},',',2,1);

    % downsample emotient by 15 frames
    emotient_dat_interp = interp1(emotient_dat,v,xq,'spline');
    M = movmean(emotient_dat_interp,15);
    emotient_dat_preproc = downsample(M,15);
    % make sure emotient and rating same size
    
    sub_num=mean_obs_ratings{s}(end-8:end-6);
    sub_vid=mean_obs_ratings{s}(end-8:end-4);
%     plot(dat);title(sub_vid);
%     pause;close;
end

%% exemplar 163 vid5 (134 r)
exemplar=134;
sub_num=mean_obs_ratings{exemplar}(end-8:end-6);
sub_vid=mean_obs_ratings{exemplar}(end-8:end-4);

rate_dat = dlmread(mean_obs_ratings{exemplar},',',2,1);
emotient_dat = dlmread(emotient_decoding{exemplar},',',2,1);
% downsample emotient by 15 frames
M = movmean(emotient_dat,15);
emotient_dat = downsample(M,15);
% make sure emotient and rating same size

emo_len=size(emotient_dat,1);
rate_len=size(rate_dat,1);

emotient_emo=emotient_dat(:,25:end);
rate_emo=rate_dat(1:emo_len);

subplot(2,1,1);
% title('Exemplar: Emotient Predictions Compared to mean observer ratings');
plot(rate_emo);legend('Mean Observer Rating');
subplot(2,1,2);
plot(emotient_emo);
legend('Anger', 'Contempt',	'disgust',	'joy',	'fear',	'sadness',	'surprise');
% linkaxes;


%% choices
% interpolate or keep nans?