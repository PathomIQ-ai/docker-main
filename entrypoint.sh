#!/bin/bash

# Connect S3
mkdir /home/ec2-user/s3-pathomiq

echo AKIA3EZURXYHQK6C6F52:7Ft04HQBvEJZoTnAgWn7Q86AcetodnNcOrsrkBKT > /home/ec2-user/.passwd-s3fs
chmod 600 /home/ec2-user/.passwd-s3fs
s3fs pathomiq-main /home/ec2-user/s3-pathomiq -o passwd_file=/home/ec2-user/.passwd-s3fs

cd /home/ec2-user/

# aws configure set aws_access_key_id AKIA3EZURXYHQK6C6F52
# aws configure set aws_secret_access_key 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
# aws configure set default.region us-west-2

# git config --global credential.helper '!aws codecommit credential-helper $@'
# git config --global credential.UseHttpPath true

mkdir /home/ec2-user/download/

echo $MODE

if [ ${MODE} == 'train' ] 
then
    git clone https://git-codecommit.us-west-2.amazonaws.com/v1/repos/classification-pytorch-basic /home/ec2-user/download/
    python /home/ec2-user/download/train.py --tissue ${TISSUE} --dataset ${DATASET} --net_type ${NET_TYPE} --batch ${BATCH_SIZE} --lr ${LEARNING_RATE} --train_sample ${TRAIN_SAMPLE} --valid_sample ${VALID_SAMPLE} --milestone ${MILESTONE} --epochs ${EPOCHS} --workers ${WORKERS} --pretrained ${PRETRAINED}
fi

if [ ${MODE} == 'predict' ] 
then
    git clone https://git-codecommit.us-west-2.amazonaws.com/v1/repos/classification-pytorch-basic /home/ec2-user/download/
    python /home/ec2-user/download/predict.py --dataset ${DATASET} --tissue ${TISSUE} --experiment ${EXPERIMENT} --slide ${SLIDE} --checkpoint ${CHECKPOINT} --run ${RUN}
fi

if [ ${MODE} == 'cluster' ] 
then
    git clone --branch development https://git-codecommit.us-west-2.amazonaws.com/v1/repos/pathomiq-pre-processing-dataset /home/ec2-user/download/
    cd /home/ec2-user/download/
    python cluster.py --dataset ${DATASET} --net_type ${NET_TYPE} --experiment ${EXPERIMENT} --checkpoint ${CHECKPOINT} --run ${RUN} --tissue ${TISSUE}
fi

if [ ${MODE} == 'conversion' ]
then
    git clone https://git-codecommit.us-west-2.amazonaws.com/v1/repos/pathomiq-pre-processing-dataset /home/ec2-user/pathomiq-pre-processing-dataset/
    python /home/ec2-user/pathomiq-pre-processing-dataset/run_conversion.py --tissue ${TISSUE} --dataset ${DATASET} --slide_name ${SLIDE_NAME} --label_mode ${LABEL_MODE} --s3_bucket ${S3_BUCKET}
fi

if [ ${MODE} == 'clean_pkl' ]
then
    git clone https://git-codecommit.us-west-2.amazonaws.com/v1/repos/pathomiq-pre-processing-dataset /home/ec2-user/pathomiq-pre-processing-dataset/
    python /home/ec2-user/pathomiq-pre-processing-dataset/run_preprocess_clean.py --tissue ${TISSUE} --dataset ${DATASET} --slide_name ${SLIDE_NAME} --label_mode ${LABEL_MODE} --s3_bucket ${S3_BUCKET}
fi

if [ ${MODE} == 'combine' ]
then
    git clone https://git-codecommit.us-west-2.amazonaws.com/v1/repos/pathomiq-pre-processing-dataset /home/ec2-user/pathomiq-pre-processing-dataset/
    python /home/ec2-user/pathomiq-pre-processing-dataset/run_preprocess_combine.py --tissue ${TISSUE} --dataset ${DATASET} --label_mode ${LABEL_MODE} --s3_bucket ${S3_BUCKET} --scale ${SCALE} --patch_size ${PATCH_SIZE} --default_max_scale ${DEFAULT_MAX_SCALE}
fi

if [ ${MODE} == 'combine_gland_segmentation' ]
then
    git clone https://git-codecommit.us-west-2.amazonaws.com/v1/repos/pathomiq-pre-processing-dataset /home/ec2-user/pathomiq-pre-processing-dataset/
    python /home/ec2-user/pathomiq-pre-processing-dataset/run_preprocess_gland_segmentation_combine.py --tissue ${TISSUE} --dataset ${DATASET} --label_mode ${LABEL_MODE} --s3_bucket ${S3_BUCKET} --scale ${SCALE} --default_max_scale ${DEFAULT_MAX_SCALE} --is_detect_background ${IS_DETECT_BACKGROUND}
fi
