# Create an Scada-LTS.war file and deploy it into Docker Tomcat Image.
FROM tomcat:9.0.86-jre11
LABEL maintainer="rjajko@softq.pl"

# Copy library dependencies
COPY tomcat/lib/mysql-connector-java-5.1.49.jar /usr/local/tomcat/lib/mysql-connector-java-5.1.49.jar
COPY tomcat/lib/activation.jar /usr/local/tomcat/lib/activation.jar
COPY tomcat/lib/jaxb-api-2.4.0-b180830.0359.jar /usr/local/tomcat/lib/jaxb-api-2.4.0-b180830.0359.jar
COPY tomcat/lib/jaxb-core-3.0.2.jar /usr/local/tomcat/lib/jaxb-core-3.0.2.jar
COPY tomcat/lib/jaxb-runtime-2.4.0-b180830.0438.jar /usr/local/tomcat/lib/jaxb-runtime-2.4.0-b180830.0438.jar

# Install dependencies in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends unzip wait-for-it && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Deploy and unpack WAR
COPY build/libs/Scada-LTS.war /usr/local/tomcat/webapps/
RUN cd /usr/local/tomcat/webapps/ && \
    mkdir Scada-LTS && \
    unzip Scada-LTS.war -d Scada-LTS && \
    rm Scada-LTS.war

# Inject context configuration
COPY docker/config/context.xml /usr/local/tomcat/webapps/Scada-LTS/META-INF/context.xml

# Inject custom background image(s) for Graphical Views
COPY uploads/ /usr/local/tomcat/webapps/Scada-LTS/uploads/
RUN chmod -R 755 /usr/local/tomcat/webapps/Scada-LTS/uploads/