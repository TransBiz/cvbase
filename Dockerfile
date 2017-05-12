FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

MAINTAINER yvictor

# Pick up some TF & Pytorch dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python \
        python-dev \
        rsync \
        software-properties-common \
        unzip \
        git \
        make \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PYENV_ROOT /root/.pyenv
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
RUN pyenv install anaconda3-4.3.0
RUN pyenv global anaconda3-4.3.0

# RUN conda install scikit-image -y


# Install TensorFlow GPU version.
RUN pip --no-cache-dir install \
    http://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.0.1-cp36-cp36m-linux_x86_64.whl

# Install keras GPU version.
RUN pip install --no-cache-dir keras

# Install pytorch GPU version.
RUN pip install  --no-cache-dir https://s3.amazonaws.com/pytorch/whl/cu80/torch-0.1.12.post1-cp36-cp36m-linux_x86_64.whl
RUN pip install  --no-cache-dir torchvision


# RUN ln -s /usr/bin/python3 /usr/bin/python#

# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/


# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
COPY run_jupyter.sh /

# For CUDA profiling, TensorFlow requires CUPTI.
ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

WORKDIR "/home"
COPY nvidia_test.py /home/

CMD python nvidia_test.py

