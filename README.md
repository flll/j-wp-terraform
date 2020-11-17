前提  
oci console  
region 日本

```
cat << 'EOF' > ~/jj.bash
#!/bin/bash
[[ ! -d j-wp/ ]] && git clone https://github.com/flll/j-wp-terraform.git
cd j-wp-terraform
git fetch && git reset --hard origin/main
chmod 755 -R *
./instance-launch.bash
EOF
```