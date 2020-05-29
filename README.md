# archetype

基于Spring CLoud构建微服务的自定义archetype

[TOC]

## 使用

1. `File` > `New` > `Maven Project`
2. `Next >`
3. 选择 `rebue-archetype` > `Next >`
   ![选择archetype](./img/选择archetype.png)
4. 填写下面几项，然后 `Finish`
   - Group Id
   - Artifact Id
   - Version
   - Package **注意包名后面两级可能会重复，去掉最后一级即可**
   - microServerPort **微服务本地调试时用的端口号**

   ![配置参数](./img/配置参数.png)
5. 项目建成
6. 数据库设计建模(按规范放于db相应目录下)
7. 创建数据库
8. 运行xxx-gen项目中的主程序生成代码
9. 用Spring Boot App的方式启动xxx-svr项目
10. 运行xxx-svr项目下的单元测试

## 编译

1. 右击`archetype`项目 > `Run As` > `Maven build...`
2. `Goals` 输入框中填入 `archetype:create-from-project`
3. 勾选 `Skip Tests`
4. `Run`

## 安装到本地

1. 右击`archetype`项目 > `Run As` > `Maven build...`
2. `Goals` 输入框中填入 `clean install`
3. 勾选 `Skip Tests`
4. `Run`

## 部署到私服

1. 右击`archetype`项目 > `Run As` > `Maven build...`
2. `Goals` 输入框中填入 `clean deploy`
3. `profiles` 输入框中填写 `deploy-private`
4. 勾选 `Skip Tests`
5. `Run`