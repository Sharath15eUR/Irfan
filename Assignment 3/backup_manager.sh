#!/bin/bash

source_dir="$1"
backup_dir="$2"
extension="$3"

files_to_backup=($source_dir/*$extension)

export backup_count=0

if [ ${#files_to_backup[@]} -eq 0 ]; then
	echo "No files found with the extension $extension in $source_dir."
	exit 1
fi

echo "Files to be backed up:"
for file in "${files_to_backup[@]}"; do
	file_size=$(stat -c %s "$file")
	echo "File: $file, Size: $file_size bytes"
done

if [ ! -d "$backup_dir" ]; then
	mkdir -p "$backup_dir"
	if [ $? -ne 0 ]; then
		echo "Failed to create backup directory $backup_dir."
		exit 1
	fi
fi

for file in "${files_to_backup[@]}"; do
	backup_file="$backup_dir/$(basename "$file")"

	if [ -f "$backup_file" ]; then
		if  [ "$file" -nt "$backup_file" ]; then
			cp "$file" "$backup_file"
		else
			continue
		fi
	else
		cp "$file" "$backup_file"
	fi
	((backup_count++))
done

total_size=0
for file in "${files_to_backup[@]}"; do
	file_size=$(stat -c %s "$file")
	total_size=$((total_size + file_size))
done

report_path="$backup_dir/backup_report.log"

echo "Backup Report" > "$report_path"
echo "------------------------------" >> "$report_path"
echo "Total files backed up: $backup_count" >> "$report_path"
echo "Total size of files backed up: $total_size bytes" >> "$report_path"
echo "Backup directory path: $backup_dir" >> "$report_path"

