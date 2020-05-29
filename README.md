# archetype

构建 **Rebue** 微服务项目的archetype插件

[TOC]

## Rebue开发指南

<https://github.com/rebue/archetype/blob/master/src/main/resources/archetype-resources/doc/%E5%BE%AE%E6%9C%8D%E5%8A%A1%E5%BF%AB%E9%80%9F%E5%BC%80%E5%8F%91%E6%8C%87%E5%8D%97.md>

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