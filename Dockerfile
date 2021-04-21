From nvidia/cuda:10.0-devel-ubuntu18.04
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS yes
ENV TZ Asia/Tokyo 

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    libopencv-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root
RUN wget -q https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh && \
    bash Anaconda3-5.2.0-Linux-x86_64.sh -b -p /root/anaconda3 && \
    rm /root/Anaconda3-5.2.0-Linux-x86_64.sh && \
    echo "export PATH=/root/anaconda3/bin:$PATH" >> /root/.bashrc

ENV PATH $PATH:/root/anaconda3/bin
WORKDIR /root
RUN conda install pytorch=1.3.1 torchvision=0.4.2 cudatoolkit=10.0.130 -c pytorch

RUN pip install cython && \
    pip install -U \
    'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'

RUN mkdir /root/TraDeS
COPY ./requirements.txt /root/TraDeS/
WORKDIR /root/TraDeS
RUN pip install -r requirements.txt

COPY ./src/lib/model/networks/DCNv2/ /root/TraDeS/src/lib/model/networks/DCNv2/
WORKDIR /root/TraDeS/src/lib/model/networks/DCNv2
RUN bash make.sh

COPY . /root/TraDeS/
WORKDIR /root/TraDeS