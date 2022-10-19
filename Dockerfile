# Build from CUDA-Optimized Pytorch Base Image
FROM nvcr.io/nvidia/pytorch:22.08-py3

# Sync Timezone
RUN \
    ln -snf /usr/share/zoneinfo/$CONTAINER_TIMEZONE /etc/localtime && \
    echo $CONTAINER_TIMEZONE > /etc/timezone

# Install Basics
RUN apt-get update && apt-get install -y \
    curl ca-certificates rsync git bzip2 tzdata libx11-6 \
	autoconf automake libtool pkg-config libgtk2.0-dev fuse \
    libtiff-dev libxml2-dev libsqlite3-dev libcurl4-openssl-dev \
    libssl-dev libfuse-dev parallel sudo zip unzip libopenjp2-7 nfs-common && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI
WORKDIR /tmp/awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN sudo ./aws/install

# Install OpenJPEG for OpenSlide
WORKDIR /tmp/openjpeg
RUN \
    git clone https://github.com/uclouvain/openjpeg.git ./ && \
    git checkout tags/version.2.1 && \
    cmake . && make && make install

# Install Patched OpenSlide
WORKDIR /tmp/openslide
RUN \
    git clone https://github.com/ml-and-ml/openslide-patched.git ./ && \
    autoreconf -i ./configure.ac && \
    ./configure --prefix=/opt/openslide && \
    make && \
    make install
ENV PATH=/opt/openslide/bin:/opt/openslide/lib:$PATH
ENV LD_LIBRARY_PATH=/opt/openslide/lib:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=/opt/openslide/lib:$LIBRARY_PATH

# Install s3fs
WORKDIR /tmp/fuse
RUN wget https://github.com/s3fs-fuse/s3fs-fuse/archive/v1.86.tar.gz && \
    tar -xzvf v1.86.tar.gz && \
    cd s3fs-fuse-1.86 && \
    ./autogen.sh && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    rm -rf s3fs-fuse-1.86 v1.86.tar.gz

# Install Oracle JVM 8 for QuPath
COPY jdk-8u321-linux-x64.tar.gz /opt
WORKDIR /opt
RUN tar xzf jdk-8u321-linux-x64.tar.gz
RUN rm jdk-8u321-linux-x64.tar.gz
ENV JAVA_HOME=/opt/jdk1.8.0_321
ENV PATH=$PATH:$JAVA_HOME/bin

# Install QuPath 0.3.2
WORKDIR /opt/qupath
RUN wget https://github.com/qupath/qupath/releases/download/v0.3.2/QuPath-0.3.2-Linux.tar.xz && \
    tar -xf QuPath-0.3.2-Linux.tar.xz 
ENV QUPATH_EXE=/opt/qupath/QuPath/bin/QuPath
RUN chmod u+x /opt/qupath/QuPath/bin/QuPath

# Install SDKMan and Groovy
RUN curl -s get.sdkman.io | bash
RUN /bin/bash -c "source /root/.sdkman/bin/sdkman-init.sh; sdk version; sdk install groovy"

# Upgrade Numpy
RUN pip install --upgrade numpy

# Install Theano GPU Dependencies
WORKDIR /tmp/theano
RUN \
    git clone https://github.com/Theano/libgpuarray.git && \
    cd libgpuarray && \
    mkdir Build && \
    cd Build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make && \
    make install && \
    cd .. && \
    python setup.py build && \
    python setup.py install

# Install Python Addons
COPY requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt
RUN pip install histomicstk --find-links https://girder.github.io/large_image_wheels
RUN pip install --upgrade https://github.com/Lasagne/Lasagne/archive/master.zip

# Cleanup Install Folders
RUN sudo rm -r /workspace/*
RUN sudo rm -r /tmp/*
RUN sudo mkdir /efs
RUN sudo chmod 777 /efs

# Create Local User and Directory
RUN useradd -ms /bin/bash ec2-user
# USER ec2-user
WORKDIR /home/ec2-user/


# Configure Credentials
# RUN aws configure set aws_access_key_id AKIA3EZURXYHQK6C6F52
# RUN aws configure set aws_secret_access_key 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
# RUN aws configure set default.region us-west-2
# RUN git config --global credential.helper '!aws codecommit credential-helper $@'
# RUN git config --global credential.UseHttpPath true


COPY initiate.sh /home/ec2-user/initiate.sh

ENTRYPOINT ["bash"]
