# Packer templates for Linux using vSphere-ISO provider

This repository contains **HashiCorp Packer** templates to deploy **Linux** distros on **VMware vSphere**.

# Content:

**CentOS7 Base**

- centos-vsphere.pkr.hcl        --> CentOS7 Packer HCL le
- ks.cfg                        --> CentOS7 Kickstart
- secret.auto.pkrvards.hcl      --> Password and user name for vSphere
- variables.auto.pkrvards.hcl   --> Set variables

User: root | Password: server