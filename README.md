# ExportExcel2Lua
C#开发的excel插件，只支持office2013

可以把excel的数据按一定的格式导出lua表

打开Export\Export\bin\Debug\app.publish，点击setup.exe安装插件

![image](https://github.com/2109/ExportExcel2Lua/blob/master/pic/1.png)

打开excel文件后，可以看到加载项

![image](https://github.com/2109/ExportExcel2Lua/blob/master/pic/3.png)



使用例子

![image](https://github.com/2109/ExportExcel2Lua/blob/master/pic/4.png)

设置好相关目录后，点击导表

![image](https://github.com/2109/ExportExcel2Lua/blob/master/pic/5.png)

##目录设置
###解析目录:parser目录

###前端导出目录:导出表到此目录

###后端导出目录:导出表到此目录

##每个sheet表至少有三列

###第一行为类型定义

###第二行为中文描述(不导出)

###第三行为字段名


支持类型在parser/type里(可以支持扩展)

#目前支持

##简单类型:
###bool
###int
###number
###string
###table
###json

数组类型:
  array_int,array_number,array_string,array_auto

类型修饰

  key:每个表必有一个类型的修饰为key,用作索引此行的key

  default:代表此列可以为空

  unique:此列的值不能重复

