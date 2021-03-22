FROM debian:bullseye

EXPOSE 5000

# Define environment variables
ENV CKAN_HOME /usr/lib/ckan
ENV CKAN_CONFIG /etc/ckan
ENV CKAN_STORAGE_PATH /var/lib/ckan
ENV CKAN_VERSION 2.9.2

# Install required system packages
RUN apt-get -q -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade \
    && apt-get -q -y install \
        apache2 \
        build-essential \
        curl \
        fish \
        git-core \
        python3-dev \
        python3-pip \
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

# Setup CKAN
RUN mkdir -p $CKAN_CONFIG $CKAN_STORAGE_PATH $CKAN_HOME
RUN pip install setuptools==44.1.0
RUN pip install pastescript==3.2.0
RUN pip install uwsgi==2.0.19.1
RUN pip install --upgrade pip

RUN git clone https://github.com/ckan/ckan.git --depth 1 -b ckan-$CKAN_VERSION $CKAN_HOME/src/ckan/
RUN sed -i 's/markdown==2.6.7/markdown==2.6.11/g' $CKAN_HOME/src/ckan/requirements.txt
RUN pip install --upgrade -r $CKAN_HOME/src/ckan/requirements.txt
RUN pip install -e $CKAN_HOME/src/ckan/
COPY extensions.txt /opt/extensions.txt
RUN pip install -r /opt/extensions.txt

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

LABEL io.hinds.name="CKAN" \
      io.hinds.description="For CKAN Deployments" \
      io.hinds.maintainer.name="Jonathan Hinds" \
      io.hinds.maintainer.email="jonathan@hinds.io" \
      io.hinds.build.branch=${BRANCH} \
      io.hinds.build.build-url=${BUILD_URL} \
      io.hinds.ckan.version=${CKAN_VERSION}
