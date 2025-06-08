#!/bin/bash
input="keys.txt"
declare -a arr=()
result=""
while IFS= read -r line
do
  echo "$line"
  result+=("$line")
done < "$input"
echo "$result"
