compress file
```tar -czvf file.tar.gz dir/```

view files stored:
```tar -ztvf file.tar.gz```

uncompress
```tar -xzvf file.tar.gz```

linux root dir spaces
```df -h```

dir space of subfolders in dir 
```du -h /path --max-depth=1 | sort -hr```

permissions
```chmod 770 file```
or
```chmod g+rwx file```