FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    vim \
    nano \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/miniforge && \
    rm /tmp/miniforge.sh

ENV PATH="/opt/miniforge/bin:${PATH}"

RUN /bin/bash -c "source /opt/miniforge/etc/profile.d/conda.sh && \
    conda create -n AmberTools25 python=3.12 -y && \
    conda activate AmberTools25 && \
    conda install dacase::ambertools-dac=25 jupyterlab py3Dmol -y"

RUN echo 'source /opt/miniforge/etc/profile.d/conda.sh' >> /root/.bashrc && \
    echo 'conda activate AmberTools25' >> /root/.bashrc && \
    echo 'source $CONDA_PREFIX/amber.sh 2>/dev/null || true' >> /root/.bashrc

ENV SHELL=/bin/bash

WORKDIR /workspace
CMD ["/bin/bash", "-l"]
