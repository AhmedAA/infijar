FROM docker.io/debian:testing-slim

# Set environment
ENV TZ="Europe/Copenhagen"

# Pull ansible collection for personal setup and install
WORKDIR /builder

ARG NETSEC=false
ARG APPSEC=false
ARG FORENSICS=false
ARG BURP_COMMUNITY=true
ARG BURP_PRO=false

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        git \
        ansible \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./requirements.yml /builder/

RUN ansible-galaxy collection install -r requirements.yml

COPY ./playbook.yml /builder/

RUN ansible-playbook playbook.yml \
    -e "target_user=root" \
    -e "target_user_home=/root" \
    -e "container=true" \
    -e "desktop=true" \
    -e "build_netsec=${NETSEC}" \
    -e "build_appsec=${APPSEC}" \
    -e "build_forensics=${FORENSICS}}" \
    -e "burp_community=${BURP_COMMUNITY}" \
    -e "burp_pro=${BURP_PRO}"

RUN apt-get purge -y \
        ansible \
    && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /builder /root/.ansible

WORKDIR /root

# Create entrypoint that drops into a shell
CMD [ "/bin/zsh" ]
