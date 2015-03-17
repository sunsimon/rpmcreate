# Introduction #

Add your content here.


# Details #

rpm打包利器rpm\_create简介
> RPM是Redhat Package Manager的简称，是由redhat公司研制，用在Linux系统下的系统包管理工具。RPM包目的：是使软件包的安装和卸载过程更容易，简化软件包的建立分发过程，并能用于不同的体系结构，RPM系统已成为现在Linux系统下包管理工具事实上的标准，并且已经移植到很多商业的unix系统之下。
> rpm打包可以通过编写spec文件，使用rpmbuild来完成一个rpm的打包。
> 使用spec文件的方式打包，对于初学者最难理解的是install和file节点编写的关系，并且复杂的是，还需要学习spec语言中特有的语法和环境变量关系。其次是打包过程，打rpm包前需要先把打包的内容，打成tar.gz的包，然后拷贝到rpmbuild的源码目录内，大部分是/usr/src/redhat/SOURCES这个目录，之后再把spec文件拷贝到/usr/src/redhat/SPECS目录，然后执行打包命令rpmbuild –bb xxx.spec，到/usr/src/redhat/rpms/i386(32位系统)找到新打的包。当然整个过程可以编写shell脚本来模拟上述步骤，最终得到打包后的文件。但是shell脚本必须和每个项目结合起来，也就是每开一个项目，都要编写与之对应的一个shell文件，并且一样要编写spec文件，这并没有彻底解决使用spec打包的繁琐问题。
> 学习使用rpmbuild打包，学习曲线比较陡峭，并且整个打包过程比较繁琐，尤其当一个产品上线时，如果发现一个bug，需要快速修改调用，那么快速打新包是必须，因为线上环境每晚一刻就可能影响数千人的用户体验，而采用rpmbuild的方式整个过程非常繁琐，有没有更好更快的方式，作为参考有checkinstall。
> checkinstall 是一个能从 tar.gz 类的源代码自动生成 RPM ／Debian 或Slackware 安装包的程序。通过checkInstall ，你就能用几乎所有的 tar.gz 类的源代码来生成“干净”的安装或者卸载包。
checkinstall 的使用非常方便，可以从checkinstall-1.6.1-1.i386.rpm 获取checkinstall 的rpm 包，直接部署到我们的机器上，但是我们要打造自己的checkinstall ，所以我们最好下载源代码来，获取源代码 。
checkinstall的原理是追踪makefile中的install操作（其实是checkinstall中的installwatch完成此项工作），记录下整个文件相关变化，并最终生成spec文件，然后执行rpmbuild打包操作，完成打包过程。
但是真实使用checkinstall打包时，有个难题。checkinstall获取版本号默认的是通过目录名获取的，也就是说我们每次更新一下包都需要更改目录名，当然版本号也可以采用手工输入的方式，面临同样问题的还有包的名称，释放版本号，包依赖，打包者，版权，简介等，这些信息每次打包时，都需要重复填写，对于我们偶尔打个包，这种输入是无所谓的，但是如果频繁打包的话，这样的过程会非常繁琐，并且还容易出错。看我们碰到的问题是，spec文件难写，打包繁琐；checkinstall只需要些makefile文件的install操作即可打包，脚本编写简单，但是交互太多，所以，我决定开发一种新的打包方式，简化流程，并结合spec和checkinstall的优点，这就是rpm\_create。
rpm\_create打包时，只需要编写citb格式文件，当然你会说，rpm\_create一样需要些打包的配置文件，并没有简化流程。是的，rpm\_create一样需要编写打包配置文件，流程似乎没有改变，其实不对。看看citb文件格式就知道，下面是rpm\_create带的实例文件，安装rpm\_create后，/usr/local/lib/checkinstall/example.citb既是文件。

###############################################################
# author: ugg
# mail: ugg.xchj@gmail.com
# url: http://code.google.com/p/rpmcreate/
###############################################################
# 需要包的名称
Name: tpm\_create\_test
# 包的版本信息
Version: 1.0.0
# 释放版本号
Release: 1
# 依赖包
Requires: php , httpd
# 创建者
Packager: ugg
# 摘要信息
Summary: by ugg test
# 版权
copyright: company
# 指定包目标环境平台（i386对应32系统，x86\_64对应64系统，noarch不区分系统）
Architecture: noarch

PEARPATH=/usr/lib/php/pear/tbs/apps/customhtml
HTDOCSPATH=/var/www/htdocs/apps/customhtml

# 安装脚本开始命令,以下部分可以从和Makefile中的内容相同即可
install:
> mkdir -p $(PEARPATH)
> mkdir -p $(HTDOCSPATH)
> cp -r ../../src/htdocs/**.php $(PEARPATH)/customhtml
> cp -r ../../src/pear/**.php $($HTDOCSPATH)/customhtml
# 以下shell命令，要以TAB开始每一行
pre:
# 每行命令以TAB开始,安装包前执行命令
#       sudo apachectl restart
preun:
# 每行命令以TAB开始,卸载包前执行命令
#       sudo apachectl restart
postun:
# 每行命令以TAB开始,卸载包后前执行命令
#       sudo apachectl restart
post:
# 每行命令以TAB开始,删除目录机上的.svn目录，安装包后执行
# 注意find命令后面的路径必须为目录机上的全路径，不能用其他变量替换全路径
#       find /usr/lib/php/pear/tbs/apps/customhtml  -type d -name ".svn"|xargs rm -rf
#       find /var/www/htdocs/apps/customhtml  -type d -name ".svn"|xargs rm -rf

# 打包日志，同rpm中的%changelog
changelog:
# 每行日志以TAB开始
  * Wed May 20 2009 changjing.xu  %{Version}

整个打包配置文件就是如此简单，需要打包时。您只需要更改包的名称，版本号，文件拷贝工作通过install节点完成。Install里面的操作很简单，就是写shell基本即可
比方说，我们和.citb文件同级目录下的test.php文件，打包安装目标机的/var/www/htdocs目录下，那么我就可以这样写
cp ./test.php /var/www/htdocs/
看见了，就这么简单。具体例子可以参考 例子
好了，写完citb文件后，接下来就执行打包命令了
rpm\_create [-citb] xxx.citb
打包完成后，包自动放到与citb同级目录下，-citb参数可以省略，rpm\_create一样支持spec打包方式，也可以rpm\_create –spec xxx.spec打包spec格式文件。rpm\_create还有如下特点如下
**打包命令简单，所需要操作就是指定要打包的citb 文件。** 目录随意，citb 可以放置在任意目录内。
**打包后的文件，放在和citb 同级目录内。** 相对于spec ，更简单的citb 格式文件编写。只要您会写shell ，就会写citb 文件。
**支持多个citb 文件同时打包 rpm**.citb。
**支持spec 格式文件打包。** 项目开源，可以随意修改使用。
**支持32-64 系统（已经经过测试）**

其实rpm\_create并没有多高深技术原理在里面，其实我也是在checkinstall之上做的封装。简单的说，我修改了原checkinstall脚本，为checkinstall脚本增加了解析citb文件的格式，这个checkinstall就可以解析citb格式文件中的Name，Version，Release等信息，然后checkinstall把citb格式文件最终转化为spec格式文件，然后调用rpmbuild进行打包操作，打包完成后，把rpm包拷贝到citb格式目录，而rpm\_create的作用，就是实现检测citb的后缀格式是否正确，用来支持同时打多个包操作，我们用一幅图描述上面的关系

rpm\_create来打包原理和rpmbuild打包原理是不同的。使用rpmbuild打包时，可以直接打源代码包，而rpm\_create不能打；也就是说rpm\_create打包时，需要指定源到目的关系，这时候的源是必须存在的文件，而不能是编译后产生的。比如说我们打包一个C/C++语言编写的包。
使用rpmbuild打包时，我们可以在spec指定编译操作，然后把编译后的.so文件拷贝到指定目录下，来完成打包。而使用rpm\_create，您需要自己先手工完成C/C++语言的编译工作，产生.so文件，然后在citb文件中指定这种对应关系。根据我们的经验，这种源代码类型的包，在企业中应用场景比较少的，企业对源代码的管理，基本都是通过SVN来管理，真正在生产环境部署时，还是以直接的二进制包为主。对于像php这种语言的包来说，根本就无需编译过程的，所以也是不需要编译的，所以这个问题对rpm打包并不会有太大影响，但是如果确实需要打源代码包，那么需要您写spec文件了。
我们在扩展rpm\_create时，还需要满足另外一种需求。我们在开发环境下开发完成，并打包后，然后把这个包部署到测试环境上进行测试，测试没有问题后，直接上生产环境，在开发，测试，生产环境上的包应该是一致的。这里就有一个问题，如果我们的产品有连接数据库等设置，那么我们在不同的环境下安装完成包后，需要修改配置文件，更改不同的数据库连接主机，部署包后，直接修改配置文件，这是很危险的操作，有可能造成修改错误，影响产品发布。而在整个打包过程只有开发人员熟悉自己代码结构，了解在开发，测试，生产数据库的host，如果开发人员不在的话，appops就不会修改配置文件，所以这些都是很危险的，为此我为citb新增3个节点，dev,tst,prd
# dev环境下执行的shell命令
dev:
#       echo "dev"

# tst环境下执行的shell命令
tst:
#       echo "tst"

# prd环境下执行的shell命令
prd:
#       echo "prd"
dev-表示在开发环境下，执行的shell命令，同理tst是测试环境，prd是生产环境。当然，rpm包本身是没有方法可以判断一台服务器是开发，还是测试的。所以，我们的办法是创建/var/tpm/create/tpm文件，如果在开发服务器创建，就在里面写dev，同理在测试服务器上就写tst，生产服务器上写prd，按照这样的约定，只需要我们在打包的过程，在citb的相关节点上写明在不同环境下的操作，那么安装这个包时，我们就无需手工更改配置文件了。这种方式，也可以通过spec方式来支持，如果感兴趣可以联系我。
rpm\_create开源链接 http://code.google.com/p/rpmcreate
rpm包直接下载 http://code.google.com/p/rpmcreate/downloads/list

相关资料链接：
> rpmbuild
> checkinstall http://asic-linux.com.mx/~izto/checkinstall/files/source/checkinstall-1.6.1.tgz
> rpm\_create 地址 http://code.google.com/p/rpmcreate 。