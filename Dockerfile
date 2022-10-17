
FROM condaforge/mambaforge as conda

ENV PIP_ROOT_USER_ACTION ignore

ADD environment.yml /

SHELL ["/bin/bash", "-c"]

RUN mamba install -y -n base -c conda-forge conda-lock && \
    mamba lock -p linux-64 -f /environment.yml && \
    mamba lock install -p /env /conda-lock.yml && \
    mamba clean -afy && \
    pip cache remove "*" 

RUN find -name '*.a' -delete && \
  rm -rf /env/conda-meta && \
  rm -rf /env/include && \
  find -name '__pycache__' -type d -exec rm -rf '{}' '+' && \ 
  find /env/lib/python3.10/site-packages -name 'tests' -type d -exec rm -rf '{}' '+' && \
  find /env/lib/python3.10/site-packages -name '*.pyx' -delete 

FROM ubuntu:20.04

EXPOSE 8080

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Etc/UTC

COPY --from=conda /env /env

RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata \
    wget \
    gnupg \
    xvfb \
    x11-xserver-utils \
    python3-pip && \
    pip3 install pyinotify && \
    echo "deb [arch=amd64] https://xpra.org/ focal main" > /etc/apt/sources.list.d/xpra.list && \
    wget -q https://xpra.org/gpg.asc -O- | apt-key add - && \
    apt update && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt install -y xpra && \
    mkdir -p /run/user/0/xpra && \
    chmod 700 /run/user/0/xpra && \
    mkdir -p /tmp/80 && \
    chmod 700 /tmp/80 && \
    apt-get remove -y \
    wget \
    gnupg \
    python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/* && \
    find -name '*.a' -delete && \
    find -name '__pycache__' -type d -exec rm -rf '{}' '+' && \
    find /usr/lib/ -name 'tests' -type d -exec rm -rf '{}' '+' && \
    apt autoremove -y

RUN adduser --disabled-password --gecos '' newuser

COPY entrypoint.sh /entrypoint.sh

RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

