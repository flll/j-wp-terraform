前提  
oci console  
region 日本

ダウンロード
```
rm -rf j-wp-terraform/
git clone -q https://github.com/flll/j-wp-terraform.git
chmod +x -R j-wp-terraform/
```



インスタンスを作成
```
j-wp-terraform/01_instance-launch.bash
```


80番と443番の疎通するようにアクセスリストを**おきかえる**
```
j-wp-terraform/02_FW_update-web.bash
```



最近作られたインスタンスの削除
```
j-wp-terraform/09_instance-terminate.bash
```