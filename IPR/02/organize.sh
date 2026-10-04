#!/bin/bash
# Организатор Downloads: раскладывает файлы каталога по папкам
# images/ archives/ documents/ other/ без перезаписи одноимённых файлов.
# Использование: ./organize.sh <каталог>

if [ $# -ne 1 ]; then
    echo "Использование: $0 <каталог>" >&2
    exit 1
fi

dir="$1"
if [ ! -d "$dir" ]; then
    echo "Ошибка: каталог '$dir' не найден" >&2
    exit 2
fi

shopt -s nullglob          # если файлов нет, цикл просто не выполнится
moved=0

for path in "$dir"/*; do
    [ -f "$path" ] || continue            # пропускаем каталоги

    name=$(basename "$path")

    # расширение: всё после последней точки, в нижнем регистре
    if [[ "$name" == *.* ]]; then
        ext="${name##*.}"
        ext="${ext,,}"
    else
        ext=""
    fi

    case "$ext" in
        jpg|jpeg|png|gif|bmp|webp|svg|tif|tiff|heic) category="images" ;;
        zip|rar|7z|tar|gz|tgz|bz2|xz)                category="archives" ;;
        pdf|doc|docx|xls|xlsx|ppt|pptx|txt|rtf|odt|ods|csv|md) category="documents" ;;
        *)                                           category="other" ;;
    esac

    mkdir -p "$dir/$category"
    target="$dir/$category/$name"

    # не перезаписываем: если имя занято, добавляем _1, _2, ...
    if [ -e "$target" ]; then
        if [[ "$name" == *.* ]]; then
            base="${name%.*}"; suffix=".${name##*.}"
        else
            base="$name"; suffix=""
        fi
        i=1
        while [ -e "$dir/$category/${base}_$i$suffix" ]; do
            i=$((i + 1))
        done
        target="$dir/$category/${base}_$i$suffix"
    fi

    mv -- "$path" "$target"
    echo "$name -> $category/$(basename "$target")"
    moved=$((moved + 1))
done

echo "Готово: перемещено файлов — $moved"
