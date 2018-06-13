#
# Cookbook: kubernetes-cluster
# License: Apache 2.0
#
# Copyright 2015-2016, Bloomberg Finance L.P.
#

case node['platform']
when 'redhat', 'centos', 'fedora'
  yum_package "#{node['kubernetes_cluster']['package']['docker-engine-selinux']['name']} #{node['kubernetes_cluster']['package']['docker-engine-selinux']['version']}"
  yum_package "#{node['kubernetes_cluster']['package']['docker']['name']} #{node['kubernetes_cluster']['package']['docker']['version']}"
  yum_package "kubernetes-node #{node['kubernetes_cluster']['package']['kubernetes_node']['version']}"
  yum_package "bridge-utils #{node['kubernetes_cluster']['package']['bridge_utils']['version']}"
  service 'firewalld' do
    action [:disable, :stop]
  end

  flannel_tar_version = node['kubernetes_cluster']['package']['flannel']['tar_version']
  if flannel_tar_version
    remote_file "#{Chef::Config['file_cache_path']}/flannel-#{flannel_tar_version}-linux-amd64.tar.gz" do
      source "https://github.com/coreos/flannel/releases/download/#{flannel_tar_version}/flannel-#{flannel_tar_version}-linux-amd64.tar.gz"
      checksum node['kubernetes_cluster']['package']['flannel']['tar_checksum']
      action :create_if_missing
      notifies :run, "bash[install_flannel_#{flannel_tar_version}]", :immediately
    end

    bash "install_flannel_#{flannel_tar_version}" do
      user 'root'
      cwd Chef::Config[:file_cache_path]
      code <<-EOH
      tar zxvf flannel-#{flannel_tar_version}-linux-amd64.tar.gz
      chmod +x flanneld
      mv flanneld /usr/bin/flanneld
      EOH
    end
  else
    yum_package "flannel #{node['kubernetes_cluster']['package']['flannel']['version']}"
  end
end

group 'kube-services'

directory node['kubernetes_cluster']['secure']['directory'] do
  only_if { node['kubernetes_cluster']['secure']['enabled'] }
  owner 'root'
  group 'kube-services'
  mode '0770'
  recursive true
  action :create
end
