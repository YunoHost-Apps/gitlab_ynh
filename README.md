# Gitlab for Yunohost

[![Integration level](https://dash.yunohost.org/integration/gitlab.svg)](https://ci-apps.yunohost.org/jenkins/job/gitlab%20%28Community%29/lastBuild/consoleFull)  
[![Install gitlab with YunoHost](https://install-app.yunohost.org/install-with-yunohost.png)](https://install-app.yunohost.org/?app=gitlab)

> *This package allow you to install gitlab quickly and simply on a YunoHost server.  
If you don't have YunoHost, please see [here](https://yunohost.org/#/install) to know how to install and enjoy it.*

## Overview

GitLab is a web-based Git-repository manager providing wiki, issue-tracking and CI/CD pipeline features, using an open-source license, developed by GitLab Inc.

**Shipped version:** 1.6.3

## Screenshots

![](https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/GitLab_running_11.0_%282018-07%29.png/300px-GitLab_running_11.0_%282018-07%29.png)

## Configuration

How to configure this app: by an admin panel

## Documentation

 * Official documentation: https://docs.gitlab.com/ce/README.html

## YunoHost specific features

#### Multi-users support

Yes with LDAP support.

#### Supported architectures

* x86-64b - [![Build Status](https://ci-apps.yunohost.org/jenkins/job/gitlab%20(Community)/badge/icon)](https://ci-apps.yunohost.org/jenkins/job/gitlab%20(Community)/)
* ARMv8-A - [![Build Status](https://ci-apps-arm.yunohost.org/jenkins/job/gitlab%20(Community)%20(%7EARM%7E)/badge/icon)](https://ci-apps-arm.yunohost.org/jenkins/job/gitlab%20(Community)%20(%7EARM%7E)/)
* Jessie x86-64b - [![Build Status](https://ci-stretch.nohost.me/jenkins/job/gitlab%20(Community)/badge/icon)](https://ci-stretch.nohost.me/jenkins/job/gitlab%20(Community)/)

## Limitations

* Not compatible with a 32-bit architecture.

**More information on the documentation page:**  
https://yunohost.org/packaging_apps

## Links

 * Report a bug: https://github.com/YunoHost-Apps/gitlab_ynh/issues
 * App website: https://gitlab.com
 * YunoHost website: https://yunohost.org/

---

Developers info
----------------

**Only if you want to use a testing branch for coding, instead of merging directly into master.**
Please do your pull request to the [testing branch](https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing).

To try the testing branch, please proceed like that.
```
sudo yunohost app install https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
or
sudo yunohost app upgrade gitlab -u https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
```
