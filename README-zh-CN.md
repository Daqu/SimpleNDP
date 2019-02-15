# 动机
一个简单的、基于[openstack swift](https://github.com/openstack/swift) 和 [openstack qinling](https://github.com/openstack/qinling)的近数据处理实验  
目的：
- 研究k8s或类似的容器调度框架在解决近数据处理中资源竞争问题的可行性
- 复现[Data-Driven Serverless Functions for Object Storage
,Middleware'17](https://github.com/JosepSampe/data-driven-functions)
- 观察近数据处理场景中资源竞争现象的特点，比如图片过滤、数据加密等


inspired by [kuzoncby/openstack-swift-ansible](https://github.com/kuzoncby/openstack-swift-ansible)

# 开始之前
- 系统为ubuntu且>=16.04, 本项目已经在ubuntu 16.04和ubuntu 18.04下验证过
- 确认每台机子上都安装了python、pip
- 确认机子之间可以通过SSH使用密码互相访问
- ansible>=2.7

## （如果是裸机）在所有机子上执行如下命令

切换到root用户，不要用sudo
> $ su root

为了确认机子满足上述前三条件，你需要
- 进入probiotic项目根目录
- 在集群所有机子上执行`helper`目录下的初始化脚本`bash helper/bare-metal-cluster.sh`
- 在你运行ansible的机子上执行helper目录下的初始化脚本`bash helper/bare-metal-controller.sh`
- 如果你将集群中的某台机子用做运行ansible的机子，那它只需要执行`bash helper/bare-metal-controller.sh`，一般地还是建议独立拿出一台机子来作为ansible的控制节点，部署完成后再删除它。

~~可能你需要安装`dos2unix`来解决一些编码问题,这是因为你可能在windows平台下编辑文件导致文件使用的换行符不被linux兼容~~
## 开始之前

在任意一台机子（可以是非集群机器）上安装python、pip、sshpass以及ansible

编辑config.ini

在ansible控制节点执行如下命令
先把先前的ssh目录清除
然后生成密钥（输入之后一路回车）

> rm -r ~/.ssh

> ssh-keygen -t rsa

设置集群机子免密码登录

> ansible-playbook -i config.ini init.yaml

# 使用 Ansible 安装 OpenStack Swift

部署swift

> ansible-playbook -i config.ini init-swift.yml

顺利的话最后会产生一个错误，在最后一个任务。这个任务是用于启动swift。它的报错为
```
··· ···
No such file or directory: '/etc/swift/internal-client.conf'
```
这是因为probiotic没有配置日志记录，因为你可以在`/var/log/syslog`中看到swift的运行情况，为了节能。
## 验证安装
💡 如果你是使用ubuntu 16.04，需要额外执行如下操作。这是因为Ubuntu 16.04下的`openstacksdk`版本过低导致安装无法正常进行，因此
probiotic会先卸载ubuntu源的openstacksdk。但是这也会导致`swift-proxy-leader`节点的openstack命令无法正常运行。

💡 如果你选择在集群之外的机子验证安装，以下两个步骤不用执行
> pip uninstall openstacksdk

> apt install python-openstackclient

### 验证步骤
probiotic使用keystone作为验证模块，这个流程走完之后会自动为你在*swift-proxy-leader*这个节点创建一个admin用户。

首先激活admin用户(激活文件放在*swift-proxy-leader*这个节点的`/root`目录下，因此需要先切换到root账号)
> su root

> cd /root/

> . admin-openrc

查看是否激活
> openstack token issue

如果你看到一个框框里面有你不懂的超长字符串，那就是激活成功了

如果你想在其它机子登录openstack，复制`admin-openrc`到那台机子上并且安装对应openstack版本的`openstack client`，具体可以看[这里](https://docs.openstack.org/install-guide/environment-packages-ubuntu.html)

创建一个容器
> openstack container create hello

检查是否创建成功
> openstack container list

目前openstack正在通过openstack client这个项目来一统所有openstack项目的操作，尝试适应这种趋势！比如你想了解object相关操作，输入`openstack object`。

由于本项目使用keystone验证，因此在你执行任何openstack命令前，记得先激活用户！
# 使用 Ansible 安装 kubernetes

### 该过程的代码直接引用了[kubeadm-ansible](https://github.com/kairen/kubeadm-ansible)，并做了少量修改，因此这个实验遵循APL 2.0协议

编辑`k8s.ini`配置文件

执行命令
> ansible-playbook -i k8s.ini init-k8s.yaml

在k8s的master节点中执行
> cp /etc/kubernetes/admin.conf ~/admin.conf
> export KUBECONFIG=~/admin.conf

检查安装是否成功，在master节点执行
> kubectl get node

# 使用 Ansible 安装 openstack-qinling

部署qinling

> ansible-playbook -i config.ini init-qinling.yml