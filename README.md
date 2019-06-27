# archetype

基于Spring CLoud构建微服务的自定义archetype

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