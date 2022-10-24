#!/bin/bash

# Connect S3
mkdir /home/ec2-user/s3-pathomiq
mkdir /home/ec2-user/scratch

echo AKIA3EZURXYHQK6C6F52:7Ft04HQBvEJZoTnAgWn7Q86AcetodnNcOrsrkBKT > /home/ec2-user/.passwd-s3fs
chmod 600 /home/ec2-user/.passwd-s3fs
s3fs pathomiq-main /home/ec2-user/s3-pathomiq -o passwd_file=/home/ec2-user/.passwd-s3fs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-0aa753efdd24bda45.efs.us-west-2.amazonaws.com:/ /efs

df -h
cd /home/ec2-user/
mkdir /home/ec2-user/download/

if [ ${MODE} == 'train' ] 
then
    git clone https://ml-and-ml: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@github.com/PathomIQ-ai/CNN-train-predict.git /home/ec2-user/download/
    python /home/ec2-user/download/train.py --tissue ${TISSUE} --dataset ${DATASET} --net_type ${NET_TYPE} --batch ${BATCH_SIZE} \
    --lr ${LEARNING_RATE} --train_sample ${TRAIN_SAMPLE} --valid_sample ${VALID_SAMPLE} --milestone ${MILESTONE} --epochs ${EPOCHS} \
    --workers ${WORKERS} --pretrain_experiment ${PRETRAIN_EXPERIMENT} --pretrain_run ${PRETRAIN_RUN} --pretrain_tissue ${PRETRAIN_TISSUE} \
    --pretrain_checkpoint ${PRETRAIN_CHECKPOINT} --split_type ${SPLIT_TYPE} --scheduler ${SCHEDULER} --patch_sizes ${PATCH_SIZES} --waist ${WAIST} \
    --model ${MODEL}
fi

if [ ${MODE} == 'predict' ] 
then
    git clone https://ml-and-ml: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@github.com/PathomIQ-ai/CNN-train-predict.git /home/ec2-user/download/
    python /home/ec2-user/download/predict.py --dataset ${DATASET} --tissue ${TISSUE} --experiment ${EXPERIMENT} --slide ${SLIDE} \
    --checkpoint ${CHECKPOINT} --run ${RUN} --batch ${BATCH} --workers ${WORKERS} --net_type ${NET_TYPE}
fi

if [ ${MODE} == 'predict_full_pipeline' ] 
then
    git clone https://ml-and-ml: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@github.com/PathomIQ-ai/CNN-train-predict.git /home/ec2-user/download/
    python /home/ec2-user/download/predict_pipeline.py --slide ${SLIDE} \
    --stain_net_exp ${STAIN_NET_EXP} --stain_net_run ${STAIN_NET_RUN} --stain_net_epoch ${STAIN_NET_EPOCH} \
    --epithelial_net_exp ${EPITHELIAL_NET_EXP} --epithelial_net_run ${EPITHELIAL_NET_RUN} --epithelial_net_epoch ${EPITHELIAL_NET_EPOCH} \
    --cancer_detect_net_exp ${CANCER_DETECT_NET_EXP} --cancer_detect_net_run ${CANCER_DETECT_NET_RUN} --cancer_detect_net_epoch ${CANCER_DETECT_NET_EPOCH} \
    --procedure ${PROCEDURE} --pretrain_tissue ${PRETRAIN_TISSUE} --dataset ${DATASET}
fi

if [ ${MODE} == 'feature_extract' ] 
then
    git clone https://ml-and-ml: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@github.com/PathomIQ-ai/CNN-train-predict.git /home/ec2-user/download/
    python /home/ec2-user/download/lung_features.py --slide ${SLIDE} --pretrain_epoch ${PRETRAIN_EPOCH} --dataset ${DATASET} --pretrain_run ${PRETRAIN_RUN} --pretrain_exp ${PRETRAIN_EXP}
fi

if [ ${MODE} == 'cluster' ] 
then
    git clone https://ml-and-ml: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@github.com/PathomIQ-ai/CNN-train-predict.git /home/ec2-user/download/
    python /home/ec2-user/download/cluster.py --dataset ${DATASET} --experiment ${EXPERIMENT} --checkpoint ${CHECKPOINT} --run ${RUN} --tissue ${TISSUE}
fi


if [ ${MODE} == 'local_features' ] 
then
    cd /home/ec2-user/download
    git clone https://ml-and-ml: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@github.com/PathomIQ-ai/lung-response.git /home/ec2-user/download/
    python /home/ec2-user/download/features_batch_job.py --radius ${RADIUS}
fi


if [ ${MODE} == 'prostate_features' ] 
then
    git clone https://ml-and-ml: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@github.com/PathomIQ-ai/CNN-train-predict.git /home/ec2-user/download/
    python /home/ec2-user/download/prostate_features.py --pretrain_exp ${PRETRAIN_EXP} --slide ${SLIDE} \
    --pretrain_epoch ${PRETRAIN_EPOCH} --pretrain_run ${PRETRAIN_RUN} --dataset ${DATASET}
fi