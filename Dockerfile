FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
	build-essential postgresql postgresql-client \
	libcg cppreference-doc-en-html zip git \
	libcap-dev libcups2-dev libpq-dev cgroup-lite python3-pip sudo

# this is default value
# you can override using --build-arg CMS_ROOT_DIR=...
ARG CMS_ROOT_DIR='/cms'

# add user to be able to run commands as sudo
RUN adduser --disabled-password --gecos '' docker
RUN adduser docker sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN mkdir ${CMS_ROOT_DIR}
RUN chown -R docker:docker ${CMS_ROOT_DIR}

COPY ["scripts", "/"]
RUN chmod +x cms_startup.sh

# change to non-root user for executing python scripts
USER docker

RUN git clone https://github.com/cms-dev/cms --recursive ${CMS_ROOT_DIR}
RUN cd ${CMS_ROOT_DIR} && sudo python3 prerequisites.py -y install

# back to privileged for python installations
USER root

WORKDIR ${CMS_ROOT_DIR}
ENV SETUPTOOLS_USE_DISTUTILS="stdlib"
RUN pip3 install -r requirements.txt
RUN python3 setup.py install

ENTRYPOINT ["/cms_startup.sh"]