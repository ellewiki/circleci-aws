FROM amazonlinux:latest

##############UPDATE the image
RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install yum-utils gcc openssl-devel bzip2-devel libffi-devel wget bash cloud-init procps lsof
RUN yum -y groupinstall development
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm
RUN yum -y install systemd-sysv systemd; yum clean all

##############INSTALL python 3.x
WORKDIR /usr/src
RUN wget https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tgz
RUN tar xzf Python-3.7.2.tgz
RUN ls -ltrh /usr/src/Python-3.7.2
WORKDIR /usr/src/Python-3.7.2
RUN ./configure --enable-optimizations
RUN make altinstall
RUN python3.7 -m pip install --upgrade pip
RUN python3.7 -m pip install --upgrade snowflake-connector-python
RUN pip3.7 install pymongo dnspython

##############INSTALL nodejs
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 8.10.0
WORKDIR $NVM_DIR
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:/root/.local/bin:/app/pipeline-script/bin:$PATH
###############INSTALL aws cli
RUN pip3.7 install awscli --upgrade --user

##############FETCH application place on image
RUN mkdir -p /app
COPY . /app
WORKDIR /app
# RUN chmod 755 /app/src/scripts/processFiles.sh
# RUN chmod 755 /app/src/scripts/importFile.sh
RUN npm install
###############INSTALL mongodb
# RUN mv mongodb-org-4.0.repo /etc/yum.repos.d/
# RUN yum install -y mongodb-org-shell-4.0.7 mongodb-org-tools-4.0.7

############### Environment variables
# ENV TZ=UTC
# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

############### VERIFY variables
RUN mongo --version
RUN python3.7 --version
RUN echo $(date)
RUN echo $PATH