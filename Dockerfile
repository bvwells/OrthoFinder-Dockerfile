################################################
# Dockerfile to build OrthoFinder software
# OS: debian buster
# Based on MrTomRod/Orthofinder-Dockerfile (Roder Thomas <roder.thomas@gmail.com>), which was itself...
# Based on cmonjeau/orthofinder (Monjeaud Cyril <Cyril.Monjeaud@irisa.fr>)
################################################

FROM debian:buster
RUN apt-get update && apt-get install -y --no-install-recommends \
		curl \
	&& rm -rf /var/lib/apt/lists/*


# Set noninterative mode
ENV DEBIAN_FRONTEND noninteractive

################## Update & upgrade ######################
ENV PACKAGES wget make gcc g++ mafft unzip libatlas-base-dev gfortran

RUN apt-get update -y
RUN apt-get install -y ${PACKAGES}

################# Fastree install ########################
ENV FASTTREE_URL http://www.microbesonline.org/fasttree/FastTree

RUN wget -P /usr/local/bin ${FASTTREE_URL} && \
  chmod a+x /usr/local/bin/FastTree

################# MCL install ########################
ENV MCL_URL https://micans.org/mcl/src/mcl-14-137.tar.gz
ENV MCL_PATH /opt/mcl-14-137

WORKDIR /opt
RUN wget ${MCL_URL} -O - | tar xvzf -
WORKDIR ${MCL_PATH}

RUN ./configure --prefix=/usr/local && make install

################ FastME install ##########################
ENV FASTME_URL https://gite.lirmm.fr/atgc/FastME/raw/master/tarball/fastme-2.1.6.1.tar.gz
ENV FASTME_PATH fastme-2.1.6.1

WORKDIR /opt
RUN wget ${FASTME_URL} --no-check-certificate -O - | tar zxvf -
WORKDIR ${FASTME_PATH}

RUN ./configure --prefix=/usr/local && make install

################# DIAMOND install ########################
ENV DIAMOND_URL https://github.com/bbuchfink/diamond/releases/download/v0.9.29/diamond-linux64.tar.gz

WORKDIR /opt
RUN wget ${DIAMOND_URL} --no-check-certificate -O - | tar xvzf - && mv diamond /usr/local/bin/diamond

########################### orthoFinder install & run tests #############################
ENV ORTHOFINDER_VERSION 2.3.8
ENV ORTHOFINDER_FILE_NAME OrthoFinder_glibc-2.15.tar.gz
ENV ORTHOFINDER_URL https://github.com/davidemms/OrthoFinder/releases/download/${ORTHOFINDER_VERSION}/${ORTHOFINDER_FILE_NAME}
ENV ORTHOFINDER_PATH /opt/OrthoFinder

WORKDIR /opt
RUN wget ${ORTHOFINDER_URL} --no-check-certificate && tar -xvzf ${ORTHOFINDER_FILE_NAME}
RUN ln -s ${ORTHOFINDER_PATH}/orthofinder /usr/local/bin/
RUN ln -s ${ORTHOFINDER_PATH}/config.json /usr/local/bin/

WORKDIR /root
RUN pwd && ls -1
RUN orthofinder -f ${ORTHOFINDER_PATH}/ExampleData/

########################## clean source file #################################

RUN rm /opt/${ORTHOFINDER_FILE_NAME}

###############################################################

MAINTAINER David Emms <david_emms@hotmail.com>
