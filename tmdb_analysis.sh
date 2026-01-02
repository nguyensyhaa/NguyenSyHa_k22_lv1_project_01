#!/bin/bash

# ============================================================
# TMDB ANALYTICS - INDEPENDENT & ROBUST VERSION
# ============================================================

DATA_FILE="tmdb-movies.csv"

# 1. Tải dữ liệu
if [ ! -f "$DATA_FILE" ]; then
    curl -s -o "$DATA_FILE" "https://raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv"
fi

echo "=========================================="
echo "TMDB DATA ANALYSIS"
echo "=========================================="

# ==========================================
# TASK 1
# ==========================================
echo "1. Sắp xếp các bộ phim theo ngày phát hành giảm dần rồi lưu ra một file mới"
OUTPUT_FILE_1="movies_sorted_by_date.csv"

head -n 1 "$DATA_FILE" | awk 'BEGIN{OFS=","}{print "release_date_parsed", $0}' > "$OUTPUT_FILE_1"

tail -n +2 "$DATA_FILE" | awk '
BEGIN { OFS = "~" }
{
    n = split($0, parts, "\"")
    clean_line = ""
    for (i = 1; i <= n; i++) {
        if (i % 2 == 1) gsub(/,/, "~", parts[i])
        clean_line = clean_line parts[i]
    }
    split(clean_line, cols, "~")
    
    if (cols[16] ~ /^[0-9]+\/[0-9]+\/[0-9]+$/ && cols[19] ~ /^[0-9]{4}$/) {
        split(cols[16], d, "/")
        parsed_date = sprintf("%04d-%02d-%02d", cols[19], d[1], d[2])
        sort_key = sprintf("%04d%02d%02d", cols[19], d[1], d[2])
        print sort_key, parsed_date, $0
    }
}' | sort -t "~" -k1 -rn | awk -F"~" '{print $2 "," $3}' >> "$OUTPUT_FILE_1"

echo "  - Top 5 Phim mới nhất:"
head -n 6 "$OUTPUT_FILE_1" | tail -n +2 | awk -F, '{printf "    [%s] %s\n", $1, $7}'
echo "    ..."
echo "  - Top 5 Phim cũ nhất:"
tail -n 5 "$OUTPUT_FILE_1" | awk -F, '{printf "    [%s] %s\n", $1, $7}'


# ==========================================
# TASK 2
# ==========================================
echo ""
echo "2. Lọc ra các bộ phim có đánh giá trung bình trên 7.5 rồi lưu ra một file mới"
OUTPUT_FILE_2="movies_high_rated.csv"
head -n 1 "$DATA_FILE" > "$OUTPUT_FILE_2"

tail -n +2 "$DATA_FILE" | awk '
{
    n = split($0, parts, "\"")
    clean_line = ""
    for (i = 1; i <= n; i++) {
        if (i % 2 == 1) gsub(/,/, "~", parts[i])
        clean_line = clean_line parts[i]
    }
    split(clean_line, cols, "~")

    if (cols[18] ~ /^[0-9]+(\.[0-9]+)?$/ && cols[18] > 7.5) {
        print $0
    }
}' >> "$OUTPUT_FILE_2"

count=$(tail -n +2 "$OUTPUT_FILE_2" | wc -l)
echo "Tổng: $count phim (Rating > 7.5)"
echo "  - Một số phim tiêu biểu:"
head -n 6 "$OUTPUT_FILE_2" | tail -n +2 | awk '
{
    n = split($0, parts, "\"")
    clean_line = ""
    for (i = 1; i <= n; i++) {
        if (i % 2 == 1) gsub(/,/, "~", parts[i])
        clean_line = clean_line parts[i]
    }
    split(clean_line, cols, "~")
    printf "    [%.1f] %s\n", cols[18], cols[6]
}' | head -n 5
echo "    ..."


# ==========================================
# TASK 3
# ==========================================
echo ""
echo "3. Tìm ra phim nào có doanh thu cao nhất và doanh thu thấp nhất"
echo ""

tail -n +2 "$DATA_FILE" | awk '
{
    n = split($0, parts, "\"")
    clean_line = ""
    for (i = 1; i <= n; i++) {
        if (i % 2 == 1) gsub(/,/, "~", parts[i])
        clean_line = clean_line parts[i]
    }
    split(clean_line, cols, "~")
    
    if (cols[5] ~ /^[0-9]+(\.[0-9]+)?$/) {
        title = cols[6]
        gsub(/^"|"$/, "", title)
        print cols[5] "~" title
    }
}' > temp_rev.txt

echo "Phim có doanh thu CAO NHẤT: $(sort -t"~" -k1 -rn temp_rev.txt | head -1 | awk -F"~" '{printf "[Doanh thu: $%d] %s", $1, $2}')"
echo ""
echo "Phim có doanh thu THẤP NHẤT:"
sort -t"~" -k1 -n temp_rev.txt | awk -F"~" '$1 > 0' | head -5 | awk -F"~" 'NR==1 {min=$1} {if($1==min) print "  [Doanh thu: $" $1 "] " $2; else exit}'
rm temp_rev.txt


# ==========================================
# TASK 4
# ==========================================
echo ""
echo "4. Tính tổng doanh thu tất cả các bộ phim"
tail -n +2 "$DATA_FILE" | awk '
{
    n = split($0, parts, "\"")
    clean_line = ""
    for (i = 1; i <= n; i++) {
        if (i % 2 == 1) gsub(/,/, "~", parts[i])
        clean_line = clean_line parts[i]
    }
    split(clean_line, cols, "~")
    if (cols[5] ~ /^[0-9]+(\.[0-9]+)?$/) sum += cols[5]
} END { printf "%.0f\n", sum }'


# ==========================================
# TASK 5
# ==========================================
echo ""
echo "5. Top 10 bộ phim đem về lợi nhuận cao nhất"
echo ""
tail -n +2 "$DATA_FILE" | awk '
{
    n = split($0, parts, "\"")
    clean_line = ""
    for (i = 1; i <= n; i++) {
        if (i % 2 == 1) gsub(/,/, "~", parts[i])
        clean_line = clean_line parts[i]
    }
    split(clean_line, cols, "~")
    
    if (cols[5] ~ /^[0-9]+$/ && cols[4] ~ /^[0-9]+$/) {
        profit = cols[5] - cols[4]
        title = cols[6]
        gsub(/^"|"$/, "", title)
        print profit "~" title
    }
}' | sort -t"~" -k1 -rn | head -10 | awk -F"~" '{printf "%50s | %s\n", $2, $1}'


# ==========================================
# TASK 6
# ==========================================
echo ""
echo "6. Đạo diễn nào có nhiều bộ phim nhất và diễn viên nào đóng nhiều phim nhất"
echo ""
tail -n +2 "$DATA_FILE" | awk '
{
    n = split($0, parts, "\"")
    clean_line = ""
    for (i = 1; i <= n; i++) {
        if (i % 2 == 1) gsub(/,/, "~", parts[i])
        clean_line = clean_line parts[i]
    }
    split(clean_line, cols, "~")
    
    if (cols[9] != "") {
        split(cols[9], dirs, "|") 
        for (d in dirs) if (dirs[d] != "") print dirs[d] > "temp_dirs.txt"
    }
    if (cols[7] != "") {
        split(cols[7], actors, "|")
        for (a in actors) if (actors[a] != "") print actors[a] > "temp_actors.txt"
    }
}'
echo "Đạo diễn: $(sort temp_dirs.txt | uniq -c | sort -rn | head -1 | awk '{f=$1;$1="";print substr($0,2) " (" f ")"}')"
echo "Diễn viên: $(sort temp_actors.txt | uniq -c | sort -rn | head -1 | awk '{f=$1;$1="";print substr($0,2) " (" f ")"}')"
rm temp_dirs.txt temp_actors.txt


# ==========================================
# TASK 7 (Optimized Inline Logic)
# ==========================================
echo ""
echo "7. Thống kê số lượng phim theo các thể loại..."
echo ""

tail -n +2 "$DATA_FILE" | awk '
BEGIN { EXPECTED_COLS = 21 }
{
    # 1. Accumulate
    buffer = (buffer == "") ? $0 : buffer " " $0
    
    # 2. Check Parity
    temp = buffer
    quote_count = gsub(/"/, "\"", temp)
    if (quote_count % 2 == 1) next
    
    # 3. Check Columns (Optimized Regex)
    temp = buffer
    gsub(/"[^"]*"/, "", temp)
    col_count = gsub(/,/, ",", temp) + 1
    if (col_count < EXPECTED_COLS) next
    
    # 4. Process
    n = split(buffer, parts, "\"")
    clean_line = ""
    for (i = 1; i <= n; i++) {
        if (i % 2 == 1) gsub(/,/, "~", parts[i])
        clean_line = clean_line parts[i]
    }
    split(clean_line, cols, "~")
    
    if (cols[14] != "") {
        split(cols[14], genres, "|")
        for (g in genres) {
             gsub(/^ +| +$/, "", genres[g])
             if (genres[g] != "") print genres[g]
        }
    }
    buffer = ""
}' | sort | uniq -c | sort -rn | awk '{printf "%s %s\n", $1, $2}'


# ==========================================
# TASK 8 (Idea)
# ==========================================
echo ""
echo "8. (Ý Tưởng Thêm) Thống kê Top 5 Công ty Sản xuất (Production Companies) phổ biến nhất"
echo "   - Ý tưởng: Sử dụng cột 'production_companies' (cột 15)."
echo "   - Cách làm: Tách chuỗi bằng dấu phân cách '|', tương tự như xử lý Đạo diễn/Diễn viên/Thể loại."
echo "   - Mục đích: Tìm ra các hãng phim thống trị thị trường trong tập dữ liệu này."
echo ""
