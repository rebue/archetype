# torna使用指南

[TOC]

## 1. 创建 `torna` 数据库

<https://gitee.com/durcframework/torna/blob/master/mysql.sql>
如果上面的地址失效，可以使用下面的地址
<https://github.com/rebue/archetype/blob/1.2.3/src/main/resources/archetype-resources/doc/torna使用指南/torna.sql>

## 2. 配置数据库链接

复制 [server/boot/src/main/resources/application.properties 文件](https://gitee.com/durcframework/torna/blob/master/server/boot/src/main/resources/application.properties) 到 `/opt/torna/config/` 目录下，修改数据库连接配置，其内容如下

```ini
# Server port
server.port=7700

# MySQL host
mysql.host=127.0.0.1:3306
# Schema name
mysql.schema=torna
# Insure the account can run CREATE/ALTER sql.
mysql.username=torna
mysql.password=torna
```

**注意:** 如果MySQL也是装在docker容器中，查询docker0的IP是什么(我这里是172.17.0.1)，然后修改 `mysql.host` 项的值

## 3. 创建并运行 `norta` 容器

```sh
docker run --name torna -dp 7700:7700 -v /opt/torna/config:/torna/config --restart=always tanghc2020/torna
```

## 4. 浏览器访问

<http://ip:7700>

## 5. 体验账号

```ini
密码均为：123456

超级管理员：admin@torna.cn

研发一部空间管理员：dev1admin@torna.cn
研发一部-商城项目（公开）-项目管理员：dev1shop_admin@torna.cn
研发一部-商城项目（公开）-开发者张三：dev1shop_zhangsan@torna.cn
研发一部-访客王五：dev1guest_wangwu@torna.cn


研发二部空间管理员：dev2admin@torna.cn
研发二部-后台项目（私有）-项目管理员：dev2back_admin@torna.cn
研发二部-后台项目（私有）-开发者李四：dev2back_lisi@torna.cn
研发二部-后台项目（私有）-访客：dev2back_guest@torna.cn
研发二部-访客赵六：dev2guest_zhaoliu@torna.cn
```

## 6. 使用指南

1. 使用上面的超级管理员账号登录系统
2. 创建空间(一般以公司名称或小组名称命名)
3. 进入空间，创建项目
4. 进入项目，创建模块
5. 在 `xxx-svr` 的 `smart-doc.json` 文件中添加内容如下:

   ```json
   {
       ....
       "appKey": "20210617855105369637126144",          // torna平台对接appKey，在 空间->开放用户 中查看
       "secret": "71T56-65R2Hc>Afu2YfBRcogROjezZTD",    // torna平台secret，在 空间->开放用户 中查看
       "appToken": "98ee93e2bfb747658fa818572f60cc50",  // torna平台appToken，在 项目->模块->OpenAPI 中查看
       "openUrl": "http://127.0.0.1:7700/api",          // torna平台地址，填写自己的私有化部署地址
       "debugEnvName": "测试环境",                      // torna测试环境
       "debugEnvUrl": "http://127.0.0.1:xxxxx"          // torna测试调用微微服务的地址
   }
   ```

6. 使用 `Maven Build`，`Goals` 的参数填 `smart-doc:torna-rest`，编译出文档并推送到 `torna` 服务器
