#!/usr/bin/env bash

watch -n 1 "echo 'SELECT * FROM workers' | /usr/local/mysql-5.5.21-osx10.6-x86_64/bin/mysql rbpm_dev"
