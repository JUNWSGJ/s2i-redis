FROM openshift/base-centos7

MAINTAINER Charles Brown <carbonrobot@gmail.com>

ENV REDIS_VERSION 3.2 \
    REDIS_CONFIG_FILE=/etc/redis/redis.conf \
    STI_SCRIPTS_PATH="/usr/libexec/s2i"

EXPOSE 6379

LABEL io.k8s.description="Redis 3 KeyValue store" \
      io.k8s.display-name="Redis 3" \
      io.openshift.expose-services="6379:redis" \
      io.openshift.tags="builder,redis"

# Install Redis.
RUN yum -y install bind-utils && \
    cd /tmp && \
    wget http://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz && \
    tar xvzf redis-${REDIS_VERSION}.tar.gz && \
    cd redis-${REDIS_VERSION} && \
    make && \
    make install && \
    cp -f src/redis-sentinel /usr/local/bin && \
    mkdir -p /etc/redis && \
    cp -f *.conf /etc/redis && \
    rm -rf /tmp/redis-stable* && \
    chmod -R a+rwx /etc/redis/redis.conf

COPY ./.s2i/bin/ ${STI_SCRIPTS_PATH}

RUN mkdir /data && chmod -R a+rwx /data
VOLUME ["/data"]

USER 1001

CMD $STI_SCRIPTS_PATH/usage