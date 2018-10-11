ARG IRI_VERSION=1.5.5
FROM arm64v8/maven:3.5-jdk-8 as builder

ARG REPO_ROCKSDB=https://github.com/facebook/rocksdb.git
ARG REPO_SNAPPY=https://github.com/google/snappy.git
ARG REPO_IRI=https://github.com/muXxer/iri.git
ARG ROCKSDB_VERSION=5.17.0
ARG ARCH_FLAGS="-march=armv8-a+crc+crypto -mtune=cortex-a53"

#ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64/

RUN apt-get update && apt-get install -y autotools-dev automake build-essential maven --no-install-recommends && rm -rf /var/lib/apt/lists/*

# Clone RocksDB
WORKDIR /iri-aarch64
RUN git clone $REPO_ROCKSDB
RUN git checkout 7dd1641048bde2e45c3e16d2e7b450b3914df1f4
WORKDIR /iri-aarch64/rocksdb

# Clone libsnappy
RUN git clone --depth=1 $REPO_SNAPPY

# Build RocksDB
RUN set -x
RUN make \
  CC=gcc \
  CXX=g++ \
  AR=ar \
  STRIP=strip \
  EXTRA_CFLAGS="${ARCH_FLAGS} -fuse-ld=gold" \
  EXTRA_CXXFLAGS="${ARCH_FLAGS} -static-libstdc++ -fuse-ld=gold" \
  EXTRA_LDFLAGS="-Wl,-Bsymbolic-functions -Wl,--icf=all" \
  EXTRA_AMFLAGS="--host=aarch64-linux-gnu" \
  DEBUG_LEVEL=0 \
  rocksdbjavastatic

RUN rm /usr/share/maven/boot/plexus-classworlds-2.5.2.jar
ENV M2_HOME=/usr/share/maven
ENV M2=/usr/share/maven/bin

WORKDIR /iri-aarch64/rocksdb/java/target/
RUN mvn install:install-file -Dfile=rocksdbjni-${ROCKSDB_VERSION}-linux64.jar -DgroupId=org.rocksdb -DartifactId=rocksdbjni -Dversion=${ROCKSDB_VERSION} -Dpackaging=jar

# Build IRI
WORKDIR /iri-aarch64
RUN git clone --depth=1 $REPO_IRI
WORKDIR /iri-aarch64/iri
RUN set -x
RUN mvn -q clean compile
RUN mvn -q package

FROM openjdk:jre-slim
ARG IRI_VERSION
WORKDIR /iri
COPY --from=builder /iri-aarch64/iri/target/iri-${IRI_VERSION}.jar iri.jar
VOLUME /iri
