# archetype

构建 **Rebue** 微服务项目的archetype插件

[TOC]

## Rebue快速开发指南

<https://github.com/rebue/archetype/blob/master/src/main/resources/archetype-resources/doc/%E5%BE%AE%E6%9C%8D%E5%8A%A1%E5%BF%AB%E9%80%9F%E5%BC%80%E5%8F%91%E6%8C%87%E5%8D%97/index.md>

## 使用

本插件已上传至中央仓库，可以直接添加到 **Eclipse** 中使用，具体添加办法如下：

1. Eclipse > Preferences... > Maven > Archetypes > Add Remote Catelog...
2. 填写远程仓库信息
   | 填写项       | 填写内容                                               |
   | :----------- | ------------------------------------------------------ |
   | Catelog File | `https://repo1.maven.org/maven2/archetype-catalog.xml` |
   | Description  | 中央仓库                                               |
3. 填写完成后点击 `OK` 按钮，因为是外网，而且数据量大，这时注意要耐心等待一下，可以在Progress视图中查看下载进度。
4. 下载完成后，即可使用。
5. 如果一切正常，后面的章节可以忽略了。如果这种方式不成功，或者要在公司团队中使用，可以继续往下看

## 下载项目并导入到Eclipse中

略

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