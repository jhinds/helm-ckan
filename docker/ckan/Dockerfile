FROM debian:jessie

EXPOSE 5000

# Define environment variables
ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_CONFIG /etc/ckan
ENV CKAN_STORAGE_PATH /var/lib/ckan
ENV CKAN_VERSION 2.7.2

# Install required system packages
RUN apt-get -q -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade \
    && apt-get -q -y install \
        apache2 \
        build-essential \
        git-core \
        python-dev \
        libapache2-mod-wsgi \
        libpq-dev \
        libxml2-dev \
        libxslt-dev \
        libgeos-dev \
        libssl-dev \
        libffi-dev \
        postgresql-client \
        vim \
        wget \
    && apt-get -q clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py

# Setup CKAN
RUN mkdir -p $CKAN_CONFIG $CKAN_STORAGE_PATH $CKAN_HOME
RUN git clone https://github.com/ckan/ckan.git --depth 1 -b ckan-$CKAN_VERSION $CKAN_HOME/src/ckan/
RUN pip install --upgrade -r $CKAN_HOME/src/ckan/requirements.txt
RUN pip install -e $CKAN_HOME/src/ckan/

# Create ckan user & update permissions
RUN useradd -r -u 900 -m -c "ckan account" -d $CKAN_HOME -s /bin/false ckan
RUN chown -R ckan:ckan $CKAN_HOME $CKAN_CONFIG $CKAN_STORAGE_PATH

# Copy over entrypoint
COPY bin/ /opt/bin/
RUN chmod +x /opt/bin/*
ENTRYPOINT ["bash"]

ARG BUILD_URL=http://localhost
ARG BRANCH=master
ARG REPO_URL=git://github.com/jhinds/helm-ckan

LABEL maintainer.name="Jonathan Hinds" \
      maintainer.email="jonathan@hinds.io" \
      com.opengov.build.branch=${BRANCH} \
      com.opengov.build.build-url=${BUILD_URL} \
      ckan.version=${CKAN_VERSION}
