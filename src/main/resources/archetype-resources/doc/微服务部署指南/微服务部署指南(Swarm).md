# 微服务部署指南(Swarm)

[TOC]

## 1. 检查项目环境

### 1.1. Dockerfile

在 `xxx-svr` 项目的 `Dockerfile` 文件，内容如下

```Dockerfile{.line-numbers}
# 基础镜像
FROM nnzbz/spring-boot-app:latest
# 镜像的作者和邮箱
LABEL maintainer="nnzbz@163.com"
# 镜像的版本
LABEL version="x.x.x"
# 镜像的描述
LABEL description="xxx-svr"

# 定义形参，实参可在下列情况下传入
# 1. 在pom.xml文件中的buildArgs节点下定义实参)
# 2. 在docker build命令中以--build-arg a_name=a_value形式赋值
ARG JAR_FILE

# 加入jar包
COPY target/${JAR_FILE} /usr/local/myservice/myservice.jar
# 加入资源
COPY src/main/resources/config/bootstrap.yml /usr/local/myservice/config/bootstrap.yml
COPY src/main/resources/config/bootstrap-prod.yml /usr/local/myservice/config/bootstrap-prod.yml
COPY src/main/resources/config/log4j2.xml /usr/local/myservice/config/log4j2.xml

# 修改为生产模式
RUN sed -i 's/active: dev/active: prod/' config/bootstrap.yml
```

- 修改 `LABEL version="x.x.x"` 为当前项目的版本号
- 修改 `LABEL description="xxx-svr"` 为当前项目名称

### 1.2. `xxx-svr` 项目的 `maven-local.properties`

```ini
# Docker私服的主机名:端口号
my-docker.host=xxxxx:xxxxx
# Docker镜像的前缀(镜像的组织)
docker.image.prefix=rebue
```

### 1.3. `xxx-svr` 项目的 `pom.xml`

- `build` -> `plugins` -> 添加插件

```xml
<!-- 制作docker镜像的插件 -->
<plugin>
  <groupId>com.spotify</groupId>
  <artifactId>dockerfile-maven-plugin</artifactId>
  <executions>
    <execution>
      <id>default</id>
      <!-- 绑定到install阶段执行 -->
      <!-- <phase>install</phase> -->
      <!-- 绑定到deploy阶段执行 -->
      <!-- <phase>deploy</phase> -->
      <!-- 不绑定到任何阶段，也就不会执行 -->
      <phase></phase>
      <goals>
        <goal>build</goal>
        <goal>push</goal>
      </goals>
    </execution>
  </executions>
  <configuration>
    <!-- 此选项指定在settings.xml文件中设置的server -->
    <useMavenSettingsForAuth>true</useMavenSettingsForAuth>
    <!-- 部署到私服 -->
    <!-- <repository>${my-docker.host}/${docker.image.prefix}/${project.artifactId}</repository> -->
    <!-- 部署到hub.docker.com -->
    <repository>${docker.image.prefix}/${project.artifactId}</repository>
    <tag>${project.version}</tag>
    <buildArgs>
      <JAR_FILE>${project.build.finalName}.jar</JAR_FILE>
    </buildArgs>
    <verbose>true</verbose>
    <googleContainerRegistryEnabled>false</googleContainerRegistryEnabled>
  </configuration>
</plugin>
```

### 1.4. `settings.xml`

```sh
vi ~/.m2/settings.xml
```

```xml
<servers>
    ....

    <!-- Docker私服 -->
    <server>
      <!-- 主机名:端口号 -->
      <id>xxxxx:xxxxx</id>
      <username>my-deployment</username>
      <password>********</password>
    </server>

    <!-- hub.docker.com -->
    <server>
        <id>docker.io</id>
        <username>nnzbz</username>
        <password>xxxxxxxx</password>
    </server>

    ....
<servers>
```

## 2. 制作镜像并上传

- 步骤:
  - 启用上节 `pom.xml` 文件中的 `<phase>install</phase>` 节点
    - 注意: 打开注释后让只要编译有 `install` 阶段就会开启制作镜像并上传，所以记得在完成后再重新注释起来
  - 然后用 `Maven Build`，`clean install`
  - 上传latest

    ```sh
    docker tag xxxxx/xxx-svr:1.2.4 xxxxx/xxx-svr:latest
    docker push xxxxx/xxx-svr:latest
    ```

- 常见报错:
  - MacOS 注意: 如果报 `java.io.IOException: Cannot run program "docker-credential-osxkeychain"`,
    请 `vi ~/.docker/config.json` 并删除 `"credsStore": "osxkeychain",` 这一行
  - 如果报 `Get https://xxxxxx:xxxxx/v2/: http: server gave HTTP response to HTTPS client`
    - MacOS: 请 `vi ~/.docker/daemon.json`
    - 其它Linux: 请 `/etc/docker/daemon.json`
  
    并添加内容如下:

    ```json
    {
      ....

      "insecure-registries": [
        "xxxxxx:xxxx",
        "xxxxxx:xxxx"
      ]

      ....
    }
    ```

    然后重启 Docker

    ```sh
    systemctl daemon-reload
    systemctl restart docker
    ```

## 3. 准备服务器环境

### 3.1. 创建项目数据库

1. 创建 `schema`
2. 创建账户并授权

   ```sh
   mysql -uroot -p
   ```

   ```sh
   grant all privileges on xxx.* to 'xxx'@'%' identified by '********';
   FLUSH PRIVILEGES;
   ```

- 创建数据库的脚本在 项目下的 `db/script/create-table.sql` 文件中

### 3.2. 在配置中心中配置项目的信息

1. 进入配置中心
  <http://xxxxx:8848/nacos/>
2. 新建配置
  `配置管理` -> `配置列表` -> 点击列表右上角的 `+` 按钮
3. 填写内容并发布
   - Data ID
     xxx-svr-prod.yaml
   - Group
     REBUE
   - 配置格式
     YAML
   - 配置内容
     `xxx-svr` 项目的 `application-prod.yml` 文件的内容，并根据实际情况修改相应内容

### 3.3. `Docker Volume` 配置文件

- 准备 `bootstrap-prod.yml` 文件
  
  ```sh
  mkdir -p /usr/local/xxx-svr/config
  vi /usr/local/xxx-svr/config/bootstrap-prod.yml
  ```

  内容与项目中的同名文件相同

### 3.4. `Docker Compose`

**注意:** 修改 `xxxx` 和 `xxx` 为实际的值

- xxxxx 镜像组织
- xxx-svr 微服务名称

```sh
vi /usr/local/xxx-svr/stack.yml
```

```yml{.line-numbers}
version: "3.9"
services:
  xxx-svr:
    image: xxxxx/xxx-svr
    environment:
      # 最好使用此设定时区，其它镜像也可以使用
      - TZ=CST-8
    volumes:
      # 配置文件目录
      - /usr/local/xxx-svr/config/bootstrap-prod.yml:/usr/local/myservice/config/bootstrap-prod.yml
networks:
  default:
    external: true
    name: rebue
```

## 4. 服务器部署微服务

```sh
docker stack deploy -c /usr/local/xxx-svr/stack.yml xxx-svr
```

## 5. 查看日志

```sh
docker service logs -f xxx-svr_xxx-svr
```

## 6. 强制重启服务

```sh
docker service update --force xxx-svr_xxx-svr
```

## 7. 升级微服务版本

```sh
docker pull xxxxx/xxx-svr && docker service update --force xxx-svr_xxx-svr
```
