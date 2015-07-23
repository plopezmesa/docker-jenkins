# Ubuntu 14.04 LTS
# Oracle Java 1.8.0_11 64 bit
# Maven 3.3.3
# Jenkins latest
# git 1.9.1
# vim

# extend the most recent long term support Ubuntu version
FROM ubuntu:14.04

MAINTAINER Pablo López Mesa (plopezmesa@gmail.com)

# this is a non-interactive automated build - avoid some warning messages
ENV DEBIAN_FRONTEND noninteractive

# update dpkg repositories
RUN apt-get update 

# install wget y curl
RUN apt-get install -y wget curl

# set shell variables for java installation
ENV maven_version 3.3.3

# get maven 3.2.2
RUN wget --no-verbose -O /tmp/apache-maven-$maven_version.tar.gz http://ftp.cixug.es/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz

# verify checksum
RUN echo "794b3b7961200c542a7292682d21ba36 /tmp/apache-maven-$maven_version.tar.gz" | md5sum -c

# install maven
RUN tar xzf /tmp/apache-maven-$maven_version.tar.gz -C /opt/
RUN ln -s /opt/apache-maven-$maven_version /opt/maven
RUN ln -s /opt/maven/bin/mvn /usr/local/bin
RUN rm -f /tmp/apache-maven-$maven_version.tar.gz
ENV MAVEN_HOME /opt/maven

# install git
RUN apt-get install -y git

# install npm
RUN curl -sL https://deb.nodesource.com/setup_0.12 | sudo -E bash -
RUN apt-get install -y nodejs

# install bower & gulp
RUN npm install -g bower grunt gulp

# remove download archive files
RUN apt-get clean

# set shell variables for java installation
ENV java_version 1.8.0_11
ENV filename jdk-8u11-linux-x64.tar.gz
ENV downloadlink http://download.oracle.com/otn-pub/java/jdk/8u11-b12/$filename

# download java, accepting the license agreement
RUN wget --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" -O /tmp/$filename $downloadlink 

# unpack java
RUN mkdir /opt/java-oracle && tar -zxf /tmp/$filename -C /opt/java-oracle/
ENV JAVA_HOME /opt/java-oracle/jdk$java_version
ENV PATH $JAVA_HOME/bin:$PATH

# configure symbolic links for the java and javac executables
RUN update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java 20000 && update-alternatives --install /usr/bin/javac javac $JAVA_HOME/bin/javac 20000

# copy jenkins war file to the container
ADD http://mirrors.jenkins-ci.org/war/latest/jenkins.war /opt/jenkins.war
RUN chmod 644 /opt/jenkins.war
ENV JENKINS_HOME /jenkins

# configure the container to run jenkins, mapping container port 7070 to that host port
ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]
EXPOSE 8080

CMD [""]
