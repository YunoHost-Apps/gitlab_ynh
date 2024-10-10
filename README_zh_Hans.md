<!--
注意：此 README 由 <https://github.com/YunoHost/apps/tree/master/tools/readme_generator> 自动生成
请勿手动编辑。
-->

# YunoHost 上的 GitLab

[![集成程度](https://dash.yunohost.org/integration/gitlab.svg)](https://ci-apps.yunohost.org/ci/apps/gitlab/) ![工作状态](https://ci-apps.yunohost.org/ci/badges/gitlab.status.svg) ![维护状态](https://ci-apps.yunohost.org/ci/badges/gitlab.maintain.svg)

[![使用 YunoHost 安装 GitLab](https://install-app.yunohost.org/install-with-yunohost.svg)](https://install-app.yunohost.org/?app=gitlab)

*[阅读此 README 的其它语言版本。](./ALL_README.md)*

> *通过此软件包，您可以在 YunoHost 服务器上快速、简单地安装 GitLab。*  
> *如果您还没有 YunoHost，请参阅[指南](https://yunohost.org/install)了解如何安装它。*

## 概况

Git-repository manager providing wiki, issue-tracking and CI/CD pipeline features

**分发版本：** 17.4.2~ynh1

**演示：** <https://gitlab.com/explore>

## 截图

![GitLab 的截图](./doc/screenshots/GitLab_running_11.0_(2018-07).png)

## 文档与资源

- 官方应用网站： <https://gitlab.com>
- 官方管理文档： <https://docs.gitlab.com/>
- 上游应用代码库： <https://gitlab.com/gitlab-org/omnibus-gitlab - https://gitlab.com/gitlab-org/gitlab>
- YunoHost 商店： <https://apps.yunohost.org/app/gitlab>
- 报告 bug： <https://github.com/YunoHost-Apps/gitlab_ynh/issues>

## 开发者信息

请向 [`testing` 分支](https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing) 发送拉取请求。

如要尝试 `testing` 分支，请这样操作：

```bash
sudo yunohost app install https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
或
sudo yunohost app upgrade gitlab -u https://github.com/YunoHost-Apps/gitlab_ynh/tree/testing --debug
```

**有关应用打包的更多信息：** <https://yunohost.org/packaging_apps>
