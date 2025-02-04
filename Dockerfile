FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York \
    DEBIAN_FRONTEND=noninteractive

LABEL "author"="Reuben Cleetus"
LABEL "version"="1.0"
LABEL "email"="reuben@cleet.us"

ENV SOPS_VER="3.7.1"
ENV KUSTOMIZE_VER="2.0.0"
ENV KUBECTL_VER="v1.23.1"
#apt-get
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

RUN apt-get update && apt-get install -y \
    python3.10 \
    zip \
    jq \
    gpg \
    libssl-dev \
    libffi-dev \
    python-dev \
    apt-transport-https \
    lsb-release \
    software-properties-common \
    wget \
    ca-certificates \
    gnupg \
    git \
    azure-cli \
    curl \
    python3-pip \
    nano \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

#Terraform
RUN wget https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_linux_arm64.zip
RUN unzip terraform*.zip
RUN mv terraform /usr/local/bin

#Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VER}/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

#Kustomize
RUN curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v${KUSTOMIZE_VER}/kustomize_${KUSTOMIZE_VER}_linux_amd64  -o /usr/bin/kustomize \
    && chmod +x /usr/bin/kustomize

#SOPS
ADD https://github.com/mozilla/sops/releases/download/v${SOPS_VER}/sops-v${SOPS_VER}.linux /usr/local/bin/sops

#AZCopy
RUN set -ex \
    && curl -L -o azcopy.tar.gz https://aka.ms/downloadazcopy-v10-linux \
    && tar -xf azcopy.tar.gz --strip-components=1 \
    && mv ./azcopy /usr/local/bin

#Fixing KeyVault bug in AZ CLI (issue/13507)
RUN pip3 uninstall azure-keyvault && \
    pip3 install azure-keyvault==1.1.0

#PyBuilder
COPY . /PyBuilder
WORKDIR /PyBuilder
RUN ls -l
RUN pip install -r requirements.txt
RUN git clone https://github.com/p1-dsop/dsop-rke2 working/dsop_rke2

# TODO: Need to update this to point to p1-dsop after forking
RUN git clone https://github.com/timothymeyers/dsop-aks working/dsop_aks
#RUN git clone git@github.com:p1-dsop/dsop-environment.git working/bigbang

RUN chmod +x working/dsop_rke2/scripts/check-terraform.sh
RUN chmod +x working/dsop_rke2/scripts/fetch-kubeconfig.sh
RUN chmod +x working/dsop_rke2/scripts/fetch-ssh-key.sh
RUN chmod +x working/dsop_rke2/scripts/check-terraform.sh
RUN chmod +x working/dsop_rke2/example/run_after_deploy.sh