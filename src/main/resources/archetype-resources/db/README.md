# 项目/db目录说明

## 1. 项目/db/model目录说明

- 项目名.prj
  PowerDesigner的项目文件
- 项目名.ldm
  PowerDesigner的逻辑模型
- 项目名-mysql.pdm
  PowerDesigner的物理模型(mysql)

## 2. 项目/db/script目录说明

用于存放操作数据库SQL语句，常见的有:

- create.sql
  建表语句
- init.sql
  建表后初始化表数据的SQL语句
- update.sql
  版本升级时，更新数据库的SQL语句
