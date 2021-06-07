# pythonの3.7.0をベースにする
FROM python:3.7.0

RUN apt-get update \
    && apt-get install -y \
    libblas-dev \
    liblapack-dev\
    libatlas-base-dev \
    mecab \
    mecab-naist-jdic \
    mecab-ipadic-utf8 \
    swig \
    libmecab-dev \
    gfortran \
    libav-tools \
    python3-setuptools 
# imageのサイズを小さくするためにキャッシュ削除
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# pipのアップデート
RUN pip install --upgrade pip

#tensorflowをインストール
ENV TENSORFLOW_VERSION 2.1.0
RUN pip --no-cache-dir install \
    https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow_cpu-${TENSORFLOW_VERSION}-cp37-cp37m-manylinux2010_x86_64.whl

# 作業するディレクトリを変更
WORKDIR /home/_machine_learning

COPY ./require.txt ${PWD}

# pythonのパッケージをインストール
RUN pip --no-cache-dir install -r require.txt  && \
    python -m ipykernel.kernelspec

WORKDIR /home/docker_machine_learning/src

# Set up Jupyter Notebook config
ENV CONFIG /root/.jupyter/jupyter_notebook_config.py
ENV CONFIG_IPYTHON /root/.ipython/profile_default/ipython_config.py 

RUN jupyter notebook --generate-config --allow-root && \
    ipython profile create

RUN echo "c.NotebookApp.ip = '0.0.0.0'" >>${CONFIG} && \
    echo "c.NotebookApp.port = 8888" >>${CONFIG} && \
    echo "c.NotebookApp.open_browser = False" >>${CONFIG} && \
    echo "c.NotebookApp.iopub_data_rate_limit=10000000000" >>${CONFIG} && \
    echo "c.MultiKernelManager.default_kernel_name = 'python3'" >>${CONFIG} 

RUN echo "c.InteractiveShellApp.exec_lines = ['%matplotlib inline']" >>${CONFIG_IPYTHON} 

# Port
EXPOSE 8888
EXPOSE 6006 

VOLUME /notebooks

CMD ["jupyter","notebook", "--allow-root"]
