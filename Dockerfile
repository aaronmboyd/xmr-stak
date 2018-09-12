# Latest version of ubuntu
FROM nvidia/cuda:9.0-base

# Default git repository
ENV GIT_REPOSITORY https://github.com/aaronmboyd/xmr-stak.git
ENV XMRSTAK_CMAKE_FLAGS -DXMR-STAK_COMPILE=generic -DCUDA_ENABLE=OFF -DOpenCL_ENABLE=OFF

# Install packages
RUN apt-get update \
    && set -x \
    && apt-get install -qq --no-install-recommends -y build-essential ca-certificates cmake cuda-core-9-0 git cuda-cudart-dev-9-0 libhwloc-dev libmicrohttpd-dev libssl-dev \
    && git clone $GIT_REPOSITORY \
    && cd /xmr-stak \
    && cmake ${XMRSTAK_CMAKE_FLAGS} . \
    && make \
    && cd - \
    && mv /xmr-stak/bin/* /usr/local/bin/ \
    && rm -rf /xmr-stak \
    && apt-get purge -y -qq build-essential cmake cuda-core-9-0 git cuda-cudart-dev-9-0 libhwloc-dev libmicrohttpd-dev libssl-dev \
    && apt-get clean -qq

# Allow memlock / hugepages
RUN echo "vm.nr_hugepages=128" /etc/sysctl.conf \
&& echo "* soft memlock 262144" >> /etc/security/limits.conf \
&& echo "* hard memlock 262144" >> /etc/security/limits.conf

# Personal config
COPY config/config.txt /usr/local/bin/
COPY config/cpu.txt /usr/local/bin/
COPY config/nvidia.txt /usr/local/bin/
COPY config/pools.txt /usr/local/bin/

WORKDIR /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/xmr-stak"]

