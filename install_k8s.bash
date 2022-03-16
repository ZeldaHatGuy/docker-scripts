#!/bin/bash



logfile=/tmp/k8sinstall.log


logit (){

/usr/bin/echo $i | tee -a $logfile

}


logit "Installing docker and other packages"
/usr/bin/apt install -y apt-transport-https curl

/usr/bin/apt install -y docker docker.io

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | /usr/bin/apt-key add


logit "setting up k8s package list if its not there."
if [ ! -f /etc/apt/sources.list.d/kubernetes.list ]; then
	logit "creating k8s package list"
        /usr/bin/echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list

fi

logit "running update and installing k8s packages"
/usr/bin/apt update -y


/usr/bin/apt install -y kubelet kubeadm kubectl kubernetes-cni


/usr/sbin/swapoff -a


/usr/sbin/modprobe br_netfilter


/usr/sbin/sysctl net.bridge.bridge-nf-call-iptables=1

logit "checking for docker dir and creating it."
if [ ! -d /etc/docker ]; then 
	/usr/bin/echo "Creating Docker directory"
	/usr/bin/mkdir /etc/docker
fi

/usr/bin/cat << EOF | /usr/bin/tee /etc/docker/daemon.json
{ "exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts":
{ "max-size": "100m" },
"storage-driver": "overlay2"
}
EOF


logit "Restarting and enabling docker service"
/usr/bin/systemctl enable docker
/usr/bin/systemctl daemon-reload
/usr/bin/systemctl restart docker 



