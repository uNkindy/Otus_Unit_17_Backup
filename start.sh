#!/bin/bash

rm -rf /root/.ssh/known_hosts

vagrant destroy -f client backup

export VAGRANT_EXPERIMENTAL="disks"

env | grep disks
