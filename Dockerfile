# using the Jelastic javaengine with graalvm as a base
FROM jelastic/javaengine:graalvm-21.0.0.2

EXPOSE 21 22 25 80 8080 443 8743

LABEL engine=openjdk11 engineName="GraalVM CE" engineType=java engineVersion=21.0.0.2  

# remove the old graalvm (java8)
RUN /bin/sh -c "rm -rf /usr/java/graalvm-${GRAALVM_VERSION}"

# The java 11 version is available at:
# https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.0.0.2/graalvm-ce-java11-linux-amd64-21.0.0.2.tar.gz

LABEL STACK_VERSION=21.1.0 

# temporary
COPY graalvm.tar.gz /home/jelastic

RUN /bin/sh -c "mkdir /usr/java/graalvm-${GRAALVM_VERSION} && \
#    curl -o /home/jelastic/graalvm.tar.gz -L https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAALVM_VERSION}/graalvm-ce-java11-linux-amd64-${GRAALVM_VERSION}.tar.gz && \
    tar --strip-components=1 -xvf /home/jelastic/graalvm.tar.gz -C /usr/java/graalvm-${GRAALVM_VERSION} && \
    /usr/java/graalvm/bin/gu install native-image && \
    chown -hRH 700:nobody /usr/java /usr/java/* && \
    rm -f /graalvm.tar.gz;"

# see the https://graalvm.org/downloads/ for info on the java version used
ENV JAVA_VERSION=11.0.10

RUN chmod 755 /usr /usr/local /usr/local/bin /usr/local/sbin

RUN mkdir /home/jelastic/server

RUN mkdir /home/jelastic/release

RUN mkdir /home/jelastic/libs

COPY payara-micro-5.2021.1.jar /home/jelastic/server

COPY jakartaee-8-project.war /home/jelastic/release

COPY mariadb-java-client-2.5.2.jar /home/jelastic/libs

COPY postboot /home/jelastic/server

COPY jvm.sh /etc/init.d/jvm

ENTRYPOINT ["/bin/bash"]       

# ENTRYPOINT ["/usr/bin/java", "-jar", "/home/jelastic/payara-micro-5.2021.1.jar", "--port", "80", "--sslport", "443", "/home/jelastic/jakartaee-8-project.war"]       

