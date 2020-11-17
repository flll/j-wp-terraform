前提  
oci console  
region 日本

ダウンロード
```
rm -rf j-wp-terraform/
git clone -q https://github.com/flll/j-wp-terraform.git
chmod +x -R *
```



インスタンスを作成
```
j-wp-terraform/09_instance-terminate.bash
```



最近作られたインスタンスの削除
```
j-wp-terraform/09_instance-terminate.bash
```



80番と443番の疎通をAClistに追加する
```
j-wp-terraform/02_FW_update-web.bash
```