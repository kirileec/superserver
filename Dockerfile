FROM ubuntu:16.04
RUN sed -i "s/archive.ubuntu./mirrors.aliyun./g" /etc/apt/sources.list

# Define environment variables.
ENV AUTH yes
ENV MONGODB_ADMIN_USER admin
ENV MONGODB_ADMIN_PASS admin123
ENV MONGODB_APPLICATION_DATABASE superserver
ENV MONGODB_APPLICATION_USER soe
ENV MONGODB_APPLICATION_PASS soe123soft

ENV RABBITMQ_LOG_BASE /data/log
ENV RABBITMQ_MNESIA_BASE /data/mnesia

# Add files.
ADD run.sh /run.sh
ADD set_mongodb_password.sh /set_mongodb_password.sh
ADD bin/rabbitmq-start /usr/local/bin/
ADD bin/superserver /superserver
ADD start.sh /

RUN \
  chmod +x /run.sh && \
  chmod +x /set_mongodb_password.sh && \
  chmod +x /superserver/SuperCenterServer && \
  chmod +x /usr/local/bin/rabbitmq-start && \
  chmod +x /start.sh 

# Install MongoDB.
RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5 && \
  echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential && \
  apt-get install -y software-properties-common && \
  apt-get install -y byobu curl git htop man unzip vim wget && \
  apt-get install -y mongodb-org

# Install RabbitMQ.
RUN \
  wget -qO - https://www.rabbitmq.com/rabbitmq-signing-key-public.asc | apt-key add - && \
  echo "deb http://www.rabbitmq.com/debian/ testing main" > /etc/apt/sources.list.d/rabbitmq.list && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated rabbitmq-server && \
  rm -rf /var/lib/apt/lists/* && \
  rabbitmq-plugins enable rabbitmq_management && \
  echo "[{rabbit, [{default_user,<<\"remote\">>},{default_pass,<<\"soe123soft\">>},{default_permissions, [<<\".*\">>, <<\".*\">>, <<\".*\">>]},{default_user_tags, [administrator]}]}]." > /etc/rabbitmq/rabbitmq.config 
  

# Define mountable directories.
VOLUME ["/data/db"]
# Define working directory.
WORKDIR /data
# Define mount points.
VOLUME ["/data/log", "/data/mnesia"]
# Define working directory.
WORKDIR /

EXPOSE 5672
EXPOSE 15672
EXPOSE 8080

ENTRYPOINT ["/start.sh"]
