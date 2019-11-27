FROM jupyter/minimal-notebook
# ---------------------------------------------------------------------------------------------------------------------
USER root

RUN apt-get update && apt-get install libgeos-dev -y && apt-get clean
# ---------------------------------------------------------------------------------------------------------------------
# Install Java
RUN apt-get update && apt-get install openjdk-8-jdk -y && apt-get clean

# ---------------------------------------------------------------------------------------------------------------------
# Install Cytomine python client
RUN cd / && git clone https://github.com/cytomine-uliege/Cytomine-python-client.git
RUN cd /Cytomine-python-client && git checkout tags/v2.4.0 && pip install .
RUN rm -r /Cytomine-python-client

# ---------------------------------------------------------------------------------------------------------------------
# Install Icy.
RUN apt-get update && apt-get install -y unzip wget && \
    mkdir -p /icy && \
    cd /icy && \
    wget -O icy.zip https://github.com/Neubias-WG5/W_SpotDetection-Icy/raw/master/icy_1.9.9.1_with_plugins.zip && \
    unzip icy.zip && \
    rm -rf icy.zip

# Add icy to the PATH
ENV PATH $PATH:/icy

RUN mkdir -p /icy/data/in && \
        mkdir -p /icy/protocols

RUN chmod -R a+rwx /icy 
# ---------------------------------------------------------------------------------------------------------------------
# Install Neubias-W5-Utilities (annotation exporter, compute metrics, helpers,...)
RUN cd / && git clone https://github.com/Neubias-WG5/neubiaswg5-utilities.git && \
       cd /neubiaswg5-utilities/ && git checkout tags/v0.8.3 && pip install .

# install utilities binaries
RUN chmod +x /neubiaswg5-utilities/bin/*
RUN cp /neubiaswg5-utilities/bin/* /usr/bin/

# cleaning
RUN rm -r /neubiaswg5-utilities

# ---------------------------------------------------------------------------------------------------------------------
# Install Protocol
ADD protocol.protocol /icy/protocols/protocol.protocol
ADD wrapper.py /app/wrapper.py

# for running the wrapper locally
ADD descriptor.json /app/descriptor.json

# Create the tmp-directory
RUN mkdir -p /tmp && chmod -R a+rwx /tmp

# changing access rights to the app folder
RUN chmod -R a+rx /app
RUN chmod -R a+rw /icy

USER ${NB_USER}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
