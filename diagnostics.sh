#!/usr/bin/env bash
set -x

BASE=log; mkdir -p log

cd $(dirname $0)
timestamp=$(date +%s)
diagnose_dir=/tmp/diagnose_${timestamp}
export KUBECONFIG=/etc/kubernetes/kubeconfig.yaml
mkdir -p $diagnose_dir

run() {
    echo
    echo "-----------------run $@------------------"
    timeout 10s $@
    if [ "$?" != "0" ]; then
        echo "failed to collect info: $@"
    fi
    echo "------------End of ${1}----------------"
}

os_env()
{
  export OS="CentOS"
}

dist() {
    cat /etc/issue*
}

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

# Service status
service_status() {
    echo "--------------------------------------------Docker Service Status---------------------------------------------------------------"
    run systemctl status docker | tee $diagnose_dir/service_status
    echo "--------------------------------------------Kubelet Service Status---------------------------------------------------------------"
    run systemctl status kubelet | tee -a $diagnose_dir/service_status
    echo "--------------------------------------------Init Node Service Status---------------------------------------------------------------"
    run systemctl status init-node | tee -a $diagnose_dir/service_status
}


#system info

system_info() {
    run uname -a | tee -a ${diagnose_dir}/system_info
    run uname -r | tee -a ${diagnose_dir}/system_info
    run dist | tee -a ${diagnose_dir}/system_info
    if command_exists lsb_release; then
        run lsb_release | tee -a ${diagnose_dir}/system_info
    fi
    run ulimit -a | tee -a ${diagnose_dir}/system_info
    run sysctl -a | tee -a ${diagnose_dir}/system_info
}

#network
network_info() {
    run ifconfig -a | tee -a ${diagnose_dir}/network_info
    run ip --details ad show | tee -a ${diagnose_dir}/network_info
    run ip --details link show | tee -a ${diagnose_dir}/network_info
    run ip route show | tee -a ${diagnose_dir}/network_info
    run iptables-save | tee -a ${diagnose_dir}/network_info
    netstat -nt | tee -a ${diagnose_dir}/network_info
    netstat -nu | tee -a ${diagnose_dir}/network_info
    netstat -ln | tee -a ${diagnose_dir}/network_info
}




#system status
system_status() {
    run uptime | tee -a ${diagnose_dir}/system_status
    run top -b -n 1 | tee -a ${diagnose_dir}/system_status

    run ps -ef | tee -a ${diagnose_dir}/system_status
    run netstat -nt | tee -a ${diagnose_dir}/system_status
    run netstat -nu | tee -a ${diagnose_dir}/system_status
    run netstat -ln | tee -a ${diagnose_dir}/system_status

    run df -h | tee -a ${diagnose_dir}/system_status

    run cat /proc/mounts | tee -a ${diagnose_dir}/system_status

    run lsof | tee -a ${diagnose_dir}/system_status
}



docker_status() {
    #mkdir -p ${diagnose_dir}/docker_status
    echo "check dockerd process"
    run ps -ef|grep -E 'dockerd|docker daemon'|grep -v grep| tee -a ${diagnose_dir}/docker_status
    run docker info | tee -a ${diagnose_dir}/docker_status
    run docker version | tee -a ${diagnose_dir}/docker_status
}

kubelet_status() {
  echo "check kubelet process"
  run ps -ef|grep -E 'kubelet'|grep -v grep| tee -a ${diagnose_dir}/kubelet_status
  echo "check kubelet health"
  run curl 0.0.0.0:10255/healthz -v | tee -a ${diagnose_dir}/kubelet_status
}

showlog() {
    local file=$1
    if [ -f "$file" ]; then
        tail -n 200 $file
    fi
}

#collect log
common_logs() {
    mkdir -p ${diagnose_dir}/logs
    run dmesg -T | tee ${diagnose_dir}/logs/dmesg.log
    cp /var/log/messages ${diagnose_dir}/logs
    cp -r /var/log/kube* ${diagnose_dir}/logs
    pidof systemd && journalctl -u docker.service &> ${diagnose_dir}/logs/docker.log || cp /var/log/upstart/docker.log ${diagnose_dir}/logs/docker.log
}

archive() {
    tar -zcvf diagnose_${timestamp}.tar.gz ${diagnose_dir}
    echo "please get diagnose_${timestamp}.tar.gz for diagnostics"
}

varlogmessage(){
    grep cloud-init /var/log/messages > $diagnose_dir/varlogmessage.log
}

cluster_dump(){
    kubectl cluster-info dump > $diagnose_dir/cluster_dump.log
}

core_component() {
    local label="$1"
    mkdir -p $diagnose_dir/cs/$comp/
    local pods=$(kubectl get po -n kube-system -l ${label} -o jsonpath="{range.items[*]}{.metadata.name}:{end}" | tr ":" "\n")
    for po in ${pods}
    do
        kubectl logs -n kube-system ${po} &> $diagnose_dir/cs/${comp}/${po}.log
    done
}

etcd() {
    journalctl -u etcd -xe &> $diagnose_dir/cs/etcd.log
}

kubelet() {
  journalctl -u kubelet -xe &> $diagnose_dir/cs/kubelet.log
}

docker() {
  journalctl -u docker -xe &> $diagnose_dir/cs/docker.log
}

init-node() {
  journalctl -u init-node -xe &> $diagnose_dir/cs/init-node.log
}


pd_collect() {
    os_env
    system_info
    service_status
    network_info
    system_status
    docker_status
    kubelet_status
    common_logs

    varlogmessage
    etcd
    kubelet
    docker
    init-node
    cluster_dump
    core_component "app=kube-apiserver"
    core_component "component=kube-scheduler"
    core_component "component=kube-controller-manager"
    core_component "k8s-app=kube-proxy"
    archive
}

pd_collect
echo "diagnose_${timestamp}.tar.gz"
