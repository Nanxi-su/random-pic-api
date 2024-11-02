#!/bin/bash

# 设置文件存放路径
OUTPUT_DIR="./hashes"
OUTPUT_FILE_PORTRAIT="$OUTPUT_DIR/portrait.txt"
OUTPUT_FILE_LANDSCAPE="$OUTPUT_DIR/landscape.txt"
BACKUP_DIR="./backup"

# 创建目录（如果不存在）
mkdir -p "$OUTPUT_DIR" "$BACKUP_DIR"

# 生成哈希值并存储到文件
find ./portrait -type f \( \
    -iname '*.jpg' -o \
    -iname '*.jpeg' -o \
    -iname '*.png' -o \
    -iname '*.gif' -o \
    -iname '*.bmp' -o \
    -iname '*.tiff' -o \
    -iname '*.tif' -o \
    -iname '*.webp' -o \
    -iname '*.svg' \
\) -exec md5sum {} + > "$OUTPUT_FILE_PORTRAIT"

find ./landscape -type f \( \
    -iname '*.jpg' -o \
    -iname '*.jpeg' -o \
    -iname '*.png' -o \
    -iname '*.gif' -o \
    -iname '*.bmp' -o \
    -iname '*.tiff' -o \
    -iname '*.tif' -o \
    -iname '*.webp' -o \
    -iname '*.svg' \
\) -exec md5sum {} + > "$OUTPUT_FILE_LANDSCAPE"

# 检查重复哈希值并删除文件
check_duplicates() {
    local FILE=$1
    local DIR=$2

    echo "检查 $FILE 中的重复哈希值："

    # 读取哈希值并查找重复项
    awk '{print $1}' "$FILE" | sort | uniq -d | while read -r hash; do
        echo "发现重复哈希值: $hash"
        # 找到对应的文件
        files=($(grep "^$hash" "$FILE" | awk '{print $2}'))
        
        # 删除逻辑
        for i in "${!files[@]}"; do
            if [[ $i -gt 0 ]]; then
                size1=$(stat -c%s "${files[0]}")
                size2=$(stat -c%s "${files[i]}")
                
                if (( size1 < size2 )); then
                    mv "${files[0]}" "$BACKUP_DIR/"
                    echo "删除文件: ${files[0]} (小于 ${files[i]})"
                    break
                elif (( size1 > size2 )); then
                    mv "${files[i]}" "$BACKUP_DIR/"
                    echo "删除文件: ${files[i]} (小于 ${files[0]})"
                    break
                else
                    # 大小相同，随机删除一个
                    if (( RANDOM % 2 )); then
                        mv "${files[0]}" "$BACKUP_DIR/"
                        echo "随机删除文件: ${files[0]}"
                    else
                        mv "${files[i]}" "$BACKUP_DIR/"
                        echo "随机删除文件: ${files[i]}"
                    fi
                    break
                fi
            fi
        done
    done
}

# 检查 portrait 和 landscape 文件夹中的重复项
check_duplicates "$OUTPUT_FILE_PORTRAIT" "./portrait"
check_duplicates "$OUTPUT_FILE_LANDSCAPE" "./landscape"
