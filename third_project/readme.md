项目结构:
doc 设计文档
mcs bit流文件
scripts vivado项目构建脚本，bd脚本
src 源文件
| constrs 约束文件
| hdl HDL设计文件
| ip_core ip核文件
| sim 仿真文件
| sw c代码文件
work vivado项目目录(gitignore)

项目构建方法，
在命令行中切换到 ./src/sw/
如果没有build目录，新建build目录 mkdir build
使用make工具运行makefiles,生成机器码的txt文件

打开vivado，在下方tcl命令行内输入命令切换到scripts目录
例如 cd {C:/xxx/xxx/xxx/scripts}
输入命令 source ./s1_recreate_project.tcl
（测试中，暂时无法使用，请依照项目结构手动构建。）