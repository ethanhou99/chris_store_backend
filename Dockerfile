#
# Docker file for ChRIS store production server
#
# Build with
#
#   docker build -t <name> .
#
# For example if building a local version, you could do:
#
#   docker build -t local/chris_store .
#
# In the case of a proxy (located at proxy.tch.harvard.edu:3128), do:
#
#    docker build --build-arg http_proxy=http://proxy.tch.harvard.edu:3128 --build-arg UID=$UID -t local/chris_store .
#
# To run an interactive shell inside this container, do:
#
#   docker run -ti --entrypoint /bin/bash local/chris_store
#


FROM fnndsc/ubuntu-python3:latest
MAINTAINER fnndsc "dev@babymri.org"

ENV APPROOT="/usr/src/store_backend" REQPATH="/usr/src/requirements" VERSION="0.1"
COPY ["./requirements", "${REQPATH}"]
COPY ["./store_backend", "${APPROOT}"]

# Pass a UID on build command line (see above) to set internal UID
ARG UID=1001
ENV UID=$UID

RUN apt-get update \
  && apt-get install sudo                                             \
  && useradd -u $UID -ms /bin/bash localuser                          \
  && addgroup localuser sudo                                          \
  && echo "localuser:localuser" | chpasswd                            \
  && sudo locakuser -aG docker [non-root user]                        \
  && apt-get install -y libmysqlclient-dev                            \
  && apt-get install -y apache2 apache2-dev                           \
  && pip3 install -r ${REQPATH}/local.txt                             \
  && mkdir /usr/users                                                 \
  && chmod 777 /usr/users                                             \
  && echo "localuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR $APPROOT
EXPOSE 8010

# Start as user $UID
# For now this is disabled so the service runs as root to 
# easily write to the managed db volume.
# USER $UID
RUN su - localuser -c "touch mine"
CMD ["manage.py", "runserver", "0.0.0.0:8010"]
