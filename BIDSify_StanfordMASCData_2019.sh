# BASH SCRIPT TO PUT STANFORD MASC DATA INTO BIDS
# written by Marianne, July 2019 @ Stanford
# heavily commented for the sanity of my future self, and you too, reader
#
# resources:
# validator: http://bids-standard.github.io/bids-validator/
# https://openneuro.org/
# https://bids-specification.readthedocs.io/
# https://cni.flywheel.io/#/login
# https://docs.google.com/spreadsheets/d/1MYNeEjRWpd-iUNDUbXYfCWEf1I4uFyijbg5vWISyHeA/edit#gid=1541408125
#
# dependencies:
# brew install dcm2niix
# fsl

#######################################
# WHAT ARE THESE DATA?
# These are 2 functional runs and 1 T1 anatomical of neurotypicals at 
# Stanford completeing the MASC empathic accuracy task. In addition to
# neuroimaging we have (1) behav ratings (live & post) (2) body maps (3) some SCR & HR??s


#######################################
# WHERE IS MARIANNE STORING THESE DATA?
# at this time they are on a 4 TB Portable External name LaCie
# after BIDS spec they will be moved to Sherlock
cd /Volumes/LaCie/MASC/current/Stanford_MASC
# specifically the raw data downloaded right off Flywheel are in
# https://cni.flywheel.io/#/login
cd /Volumes/LaCie/MASC/current/Stanford_MASC/sourcedata/zaki_chan

#######################################
# WHAT IS THE GOAL HERE?
# put flywheel dl into BIDS format which will look like:
# Nifti
#	> dataset_description.json
#	> sub-005
#		> ses-1
#			> anat
#				> sub-005_ses-1_run-01_T1w.json
#				> sub-005_ses-1_run-01_T1w.nii.gz
#			> func
#				> sub-005_ses-1_task-empacc_run-01_bold.json
#				> sub-005_ses-1_task-empacc_run-01_bold.nii.gz
#				> sub-005_ses-1_task-empacc_run-02_bold.json
#				> sub-005_ses-1_task-empacc_run-02_bold.nii.gz
#
# Flywheel uses dcm2nii for us so no reason to convert
# because of this I decided not to use anything like 'bidskit' and just made my own code

#######################################
# START 
sourcedir="/Volumes/LaCie/MASC/current/Stanford_MASC/sourcedata/zaki_chan"
bidsdir="/Volumes/LaCie/MASC/current/Stanford_MASC/Nifti"

#######################################
# STEP 1: Fix weirdo subject
# there was a subj folder S049_20180925 
# in /Volumes/LaCie/MASC/current/Stanford_MASC/sourcedata/zaki_chan
# which was renamed 049 by hand

#######################################
# STEP 2: copy func and anat files from sourcedata folder to BIDS folder with new naming struct
for filename in ${sourcedir}/*; do
	subname=sub-$(echo $filename | rev | cut -d "/" -f1 | rev)

	# copy the t1 folder contents into new ses-1/anat folder
	mkdir -p $bidsdir/$subname/ses-1/anat/
	cp -R -v $filename/*/*T1*/ $bidsdir/$subname/ses-1/anat/

	# copy the BOLD folder(s) contents into new ses-1/func folder
	mkdir -p $bidsdir/$subname/ses-1/func/
	cp -R -v $filename/*/*BOLD*/ $bidsdir/$subname/ses-1/func/

done

# now we have
# Nifti
#	> dataset_description.json
#	> sub-*
#		> ses-1
#			> anat
#				> a mess
#			> func
#				> a mess
# Next: fix the mess of files within the anat and func folders

#######################################
# STEP 3: Visually inspect and rename anatomicals
# first consider the scan log notes made by Matt & Isabella here:
# https://docs.google.com/spreadsheets/d/1MYNeEjRWpd-iUNDUbXYfCWEf1I4uFyijbg5vWISyHeA/edit#gid=1541408125
# the "graded" tab has notes about the scan quality
# The following subjects are not useable (grade = red)
# 003 013 012 045 038 047
# Several have missing scans
# Because there are a lot of inconsistencies across scans we should really go through each one and plot
# from matt: HOS is higher order shim which if done after epi sequence means the sequence isn't very trustworthy I think. This happened in the earlier scans bc protocol had this order when we started

for filename in ${bidsdir}/*/ses-1/anat/*dicom*; do
	# convert the dicom with dcm2niix
	cd ${filename%/*}
	# dcmname=$(echo $filename | rev | cut -d "/" -f1 | cut -c5- | rev)
	subname=$(echo $filename | rev | cut -d "/" -f4 | rev)
	unzip $filename
	dcm2niix ${filename%.*} 
	# or
	# dcm2niix $(echo $filename | rev | cut -c5- | rev)
	
	# remove everything but the dicoms
	rm *.zip
	rm *.gz
	rm *.json

	mv ${filename%.*}/*.json  ${filename%/*}/${subname}_ses-1_run-01_T1w.json
	mv ${filename%.*}/*.nii  ${filename%/*}/${subname}_ses-1_run-01_T1w.nii

	# plot the nii with fsleyes
	fsleyes ${filename%/*}/${subname}_ses-1_run-01_T1w.nii
	# take notes in here https://docs.google.com/spreadsheets/d/1MYNeEjRWpd-iUNDUbXYfCWEf1I4uFyijbg5vWISyHeA/edit#gid=1541408125
	# in the col "anat fsleyes review"

	# remove the dicoms
	rm -rf ${filename%.*}

done


#######################################
# STEP 4: Visually inspect and rename functionals

# run 1 = 5
for filename in ${bidsdir}/*/ses-1/func/*5_1*dicom*; do
	# convert the dicom with dcm2niix
	cd ${filename%/*}
	# dcmname=$(echo $filename | rev | cut -d "/" -f1 | cut -c5- | rev)
	subname=$(echo $filename | rev | cut -d "/" -f4 | rev)

	unzip $filename
	dcm2niix ${filename%.*} 

	# remove old jsons
	rm *.json

	mv ${filename%.*}/*.json  ${filename%/*}/${subname}_ses-1_task-empacc_run-01_bold.json
	mv ${filename%.*}/*.nii  ${filename%/*}/${subname}_ses-1_task-empacc_run-01_bold.nii


	# remove the dicoms
	rm -rf ${filename%.*}

done

# run 2 = 6
for filename in ${bidsdir}/*/ses-1/func/*6_1*dicom*; do
	# convert the dicom with dcm2niix
	cd ${filename%/*}
	# dcmname=$(echo $filename | rev | cut -d "/" -f1 | cut -c5- | rev)
	subname=$(echo $filename | rev | cut -d "/" -f4 | rev)

	unzip $filename
	dcm2niix ${filename%.*} 
	
	# remove everything but the dicoms
	rm *.zip
	rm *.gz
	rm *.png

	mv ${filename%.*}/*.json  ${filename%/*}/${subname}_ses-1_task-empacc_run-02_bold.json
	mv ${filename%.*}/*.nii  ${filename%/*}/${subname}_ses-1_task-empacc_run-02_bold.nii

	# remove the dicoms
	rm -rf ${filename%.*}
	
done

# MAKE SURE ALL DICOMS DELETED ***


# visually inspect them and mark on the sheet
# https://docs.google.com/spreadsheets/d/1MYNeEjRWpd-iUNDUbXYfCWEf1I4uFyijbg5vWISyHeA/edit#gid=1541408125
for filename in ${bidsdir}/*/ses-1/func/*bold.nii*; do
	fsleyes $filename
done

#######################################
# STEP 5: G ZIP ALL THEM Niftis
for filename in ${bidsdir}/sub*/ses*/*/*.nii; do
	gzip $filename; done




#######################################
# STEP 6: Moment of truth
# use the validator
# http://bids-standard.github.io/bids-validator/



#######################################
# MAKE BIDSIGNORE FOLDER -- NOT IDEAL BUT QUICKER THAN FIGURING THAT OUT RN
#######################################
for filename in ${basedir}/sub*/ses*/anat/*.log; do
	b=/Users/maus/Desktop/Projects/Disserations/MASC/current/Stanford_MASC/bidsignore/$(basename $filename);mv $filename $b; done


# define repetition time and task name

#######################################
# DEFINE REPTITION TIME
#######################################
# Have to append "RepetitionTime" Parameter to the json files, TR=2
# change this one /sub-005/ses-18621/func/sub-005_ses-18621_task-empacc_bold.json, 
#######################################
# DEFINE SLICE TIMING
# You should define 'SliceTiming' for this file. 
# If you don't provide this information slice time correction will not be possible.
# SEE HERE FOR HOW IT WAS CALCULATED 
# https://docs.google.com/spreadsheets/d/192S02wqey8niyBes2a5ZPeM_YuSax8OAgj9Go2QnJfA/edit?usp=sharing
# "interleaved by default, with odd slices first, then even slices"
# 46 slices
# https://cni.stanford.edu/wiki/Data_Processing
#######################################

# look into atom
brew install jq

for filename in ${basedir}/sub*/ses*/func/*.json; do
	jq '. + {"RepetitionTime": 2.0,"EchoTime": 0.025,"FlipAngle": 77,"SliceTiming": [0, 0.989, 0.043, 1.032, 0.086, 1.075, 0.129, 1.118, 0.172, 1.161, 0.215, 1.204, 0.258, 1.247, 0.301, 1.29, 0.344, 1.333, 0.387, 1.376, 0.43, 1.419, 0.473, 1.462, 0.516, 1.505, 0.559, 1.548, 0.602, 1.591, 0.645, 1.634, 0.688, 1.677, 0.731, 1.72, 0.774, 1.763, 0.817, 1.806, 0.86, 1.849, 0.903, 1.892, 0.946, 1.935],"SliceEncodingDirection": "k","Instructions": "Watch videos and give ratings","InstitutionName": "Stanford University"}' $filename > output && mv output $filename;done

#######################################
# # MAKE EVENTS FILE
#######################################
# Task scans should have a corresponding events.tsv file. 
# If this is a resting state scan you can ignore this warning 
# or rename the task to include the word "rest".

#######################################
# TO RUN FMRI PREP ON BLANCA
#######################################
# rsync to blanca
cd /Users/maus/Desktop/Projects/Disserations/MASC/current/Stanford_MASC
rsync -auvR . mare8532@blogin01.rc.colorado.edu:/work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/Nifti/

# see which singularity images of fmriprep exist
ls /work/ics/data/projects/wagerlab/Singularity_Images/


module load singularity
module load gcc
module load python/3.5.1
#sbatch -p blanca-ics -t 0-24:00 -n 3 --mem=40G singularity run /work/ics/data/projects/wagerlab/Singularity_Images/fmriprep_1.2.4-2018-12-03 /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/Nifti/ /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/preprocessed participant --participant-label sub-007 --low-mem --fs-license-file /work/ics/data/projects/wagerlab/Resources/licenses/FreeSurfer/license.txt -w /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/work
sbatch -p blanca-ics -t 0-24:00 -n 3 --mem=40G singularity run /work/ics/data/projects/wagerlab/Singularity_Images/poldracklab_fmriprep-2018-04-23.img /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/Nifti/ /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/preprocessed participant --participant-label sub-007 --low-mem --fs-license-file /work/ics/data/projects/wagerlab/Resources/licenses/FreeSurfer/license.txt -w /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/work
sbatch -p blanca-ics -t 0-24:00 -n 3 --mem=40G singularity run /work/ics/data/projects/wagerlab/Singularity_Images/poldracklab_fmriprep-2018-04-23.img /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/Nifti/ /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/preprocessed participant --participant-label sub-008 --low-mem --fs-license-file /work/ics/data/projects/wagerlab/Resources/licenses/FreeSurfer/license.txt -w /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/work

basedir=/work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/Nifti
for filename in ${basedir}/sub-01*/; do
	b=$(basename $filename)
	sbatch -p blanca-ics -t 0-38:00 -n 3 --mem=40G singularity run /work/ics/data/projects/wagerlab/Singularity_Images/poldracklab_fmriprep-2018-04-23.img /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/Nifti/ /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/preprocessed participant --participant-label $b --low-mem --fs-license-file /work/ics/data/projects/wagerlab/Resources/licenses/FreeSurfer/license.txt -w /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/work
done

# to check job status
squeue -u mare8532

# SCRATCH

sbatch -p blanca-ics -t 0-40:00 -n 3 --mem=40G singularity run /work/ics/data/projects/wagerlab/Singularity_Images/poldracklab_fmriprep-2018-04-23.img /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/Nifti/ /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/preprocessed participant --participant-label sub-021 --low-mem --fs-license-file /work/ics/data/projects/wagerlab/Resources/licenses/FreeSurfer/license.txt -w /work/ics/data/projects/wagerlab/labdata/data/MASC_Stanford/work

sbatch -p blanca-ics -n 3 --mem=80G singularity run /work/ics/data/projects/wagerlab/Singularity_Images/fmriprep_1.2.4-2018-12-03 /work/ics/data/projects/wagerlab/labdata/data/OLP4CBP/Imaging/raw/bids /work/ics/data/projects/wagerlab/labdata/data/OLP4CBP/Imaging/preprocessed participant --participant-label sub-M80309434 --fs-no-reconall --ignore slicetiming --fs-license-file ~/misc/license.txt -w /work/ics/data/projects/wagerlab/labdata/data/OLP4CBP/Imaging/fmriprep_work
# sbatch -p blanca-ics -t 0-24:00 -n 3 --mem=40G singularity run /work/ics/data/projects/wagerlab/Singularity_Images/poldracklab_fmriprep_1.1.8-2018-10-04-0a8572d49858.simg /work/ics/data/projects/wagerlab/labdata/data/OLP4CBP/Imaging/raw/bids_format/ /projects/zaan8774/preprocessed participant --participant-label sub-M80395602 --low-mem --fs-no-reconall --ignore slicetiming --fs-license-file ~/misc/license.txt -w /projects/zaan8774/work


# fmriprep-docker /Users/maus/Desktop/Projects/Disserations/MASC/current/Stanford_MASC/Nifti /Users/maus/Desktop/Projects/Disserations/MASC/current/Stanford_MASC/preprocessed participant
# RUNNING: docker run --rm -it -v /path/to/data/dir:/data:ro \
#     -v /path/to_output/dir:/out poldracklab/fmriprep:1.0.0 \
#     /data /out participant


# docker run -ti --rm \
#     -v /Users/maus/Desktop/Projects/Disserations/MASC/current/Stanford_MASC/Nifti:/data:ro \
#     -v /Users/maus/Desktop/Projects/Disserations/MASC/current/Stanford_MASC/preprocessed:/out \
#     poldracklab/fmriprep:latest \
#     /data /out/out \
#     participant
#     --fs-license-file /Applications/freesurfer/license.txt
#######################################
# Rename task data files
basedir=/Users/maus/Desktop/Projects/Disserations/MASC/current/Stanford_MASC/Task_data/ScanTaskData
for filename in ${basedir}/order*/S*; do
	b=$(basename $filename);addthis=$(echo $b | cut -c2-)
	newname=$(echo $filename | rev | cut -c5- | rev)sub-$addthis;
	mv $filename $newname; done



