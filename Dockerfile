################################################
# Dockerfile to build OrthoFinder software
# OS: debian buster
# Based on MrTomRod/Orthofinder-Dockerfile (Roder Thomas <roder.thomas@gmail.com>), which was itself...
# Based on cmonjeau/orthofinder (Monjeaud Cyril <Cyril.Monjeaud@irisa.fr>)
################################################

FROM debian:buster
RUN apt-get update && apt-get install -y --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*


# Set noninterative mode
ENV DEBIAN_FRONTEND noninteractive

################## Update & upgrade ######################
ENV PACKAGES wget mafft mcl libatlas-base-dev

RUN apt-get update -y
RUN apt-get install -y ${PACKAGES}

################# Fastree install ########################
ENV FASTTREE_URL http://www.microbesonline.org/fasttree/FastTree

RUN wget -P /usr/local/bin ${FASTTREE_URL} && \
  chmod a+x /usr/local/bin/FastTree

################ FastME install ##########################
ENV FASTME_VER 2.1.6.2

WORKDIR /opt
RUN wget https://gite.lirmm.fr/atgc/FastME/-/archive/v${FASTME_VER}/FastME-v${FASTME_VER}.tar.gz --no-check-certificate -O - | tar zxvf - \
  && tar xzf  FastME-v${FASTME_VER}/tarball/fastme-*.tar.gz  \  
  && mv fastme-*/binaries/fastme-*-linux64 /usr/local/bin/fastme

################# DIAMOND install ########################
ENV DIAMOND_URL https://github.com/bbuchfink/diamond/releases/latest/download/diamond-linux64.tar.gz

WORKDIR /opt
RUN wget ${DIAMOND_URL} --no-check-certificate -O - | tar xvzf - && mv diamond /usr/local/bin/diamond

########################### orthoFinder install & run tests #############################
ENV ORTHOFINDER_FILE_NAME OrthoFinder.tar.gz
ENV ORTHOFINDER_URL https://github.com/davidemms/OrthoFinder/releases/latest/download/${ORTHOFINDER_FILE_NAME}
ENV ORTHOFINDER_PATH /opt/OrthoFinder

WORKDIR /opt
RUN wget ${ORTHOFINDER_URL} --no-check-certificate && tar -xvzf ${ORTHOFINDER_FILE_NAME}
RUN ln -s ${ORTHOFINDER_PATH}/orthofinder /usr/local/bin/
RUN ln -s ${ORTHOFINDER_PATH}/config.json /usr/local/bin/
RUN rm -r ${ORTHOFINDER_PATH}/bin

WORKDIR /root
RUN pwd && ls -1
RUN orthofinder -f ${ORTHOFINDER_PATH}/ExampleData/

########################## clean source file #################################

RUN rm /opt/${ORTHOFINDER_FILE_NAME}

###############################################################

MAINTAINER David Emms <david_emms@hotmail.com>
