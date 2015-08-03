# Do not use Solr 5.0 because the schema.xml doesn't work with sunspot yet

FROM    makuk66/docker-oracle-java7
MAINTAINER  Nicholas Long "nicholas.long@nrel.gov"

ENV SOLR_VERSION 4.10.4
ENV SOLR solr-$SOLR_VERSION
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get -y install lsof curl procps && \
  mkdir -p /opt && \
  wget -nv --output-document=/opt/$SOLR.tgz http://www.mirrorservice.org/sites/ftp.apache.org/lucene/solr/$SOLR_VERSION/$SOLR.tgz && \
  tar -C /opt --extract --file /opt/$SOLR.tgz && \
  rm /opt/$SOLR.tgz && \
  ln -s /opt/$SOLR /opt/solr


# Remove the collection1 example
RUN rm -rf /opt/solr/example/solr/collection1

# Add in the dencity solr instance
ADD /dencity/core.properties /opt/solr/example/solr/dencity/core.properties
ADD /dencity/conf/ /opt/solr/example/solr/dencity/conf

VOLUME ["/opt/solr/example/solr/dencity/data"]

EXPOSE 8983
CMD ["/bin/bash", "-c", "/opt/solr/bin/solr -f"]
