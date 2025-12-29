#!/bin/bash

# TMDB Data Analysis Script
# Usage: ./run_analysis.sh
# Input: tmdb-movies.csv (must be in the same directory)
# Output: Generates files in output/ directory

# Create output directory
mkdir -p output

echo "Starting TMDB Analysis..."

# Task 1: Sort by release date (descending)
echo "Running Task 1: Sorting by release date..."
python3 -c "
import csv
from datetime import datetime
with open('tmdb-movies.csv') as f:
    reader = csv.reader(f)
    header = next(reader)
    rows = list(reader)
def parse_date(row):
    try:
        dt = datetime.strptime(row[15], '%m/%d/%y')
        if dt.year > 2024: dt = dt.replace(year=dt.year - 100)
        return dt
    except: return datetime.min
rows.sort(key=parse_date, reverse=True)
with open('output/task1_sorted_by_date.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerows(rows)
"

# Task 2: Filter movies rating > 7.5
echo "Running Task 2: Filtering ratings > 7.5..."
python3 -c "
import csv
with open('tmdb-movies.csv') as f:
    reader = csv.reader(f)
    header = next(reader)
    rows = [r for r in reader if r[17] and float(r[17]) > 7.5]
with open('output/task2_rating_above_7.5.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerows(rows)
"

# Task 3: Highest & Lowest Revenue
echo "Running Task 3: Finding highest/lowest revenue..."
python3 -c "
import csv
with open('tmdb-movies.csv') as f:
    reader = csv.reader(f)
    next(reader)
    rows_with_rev = [(r[5], int(r[4])) for r in reader if r[4] and int(r[4]) > 0]
rows_with_rev.sort(key=lambda x: x[1])
with open('output/task3_revenue.txt', 'w') as f:
    f.write('=== Task 3: Revenue ===\n')
    f.write(f'THẤP NHẤT: {rows_with_rev[0][0]} - \${rows_with_rev[0][1]:,}\n')
    f.write(f'CAO NHẤT: {rows_with_rev[-1][0]} - \${rows_with_rev[-1][1]:,}\n')
"

# Task 4: Total Revenue
echo "Running Task 4: Calculating total revenue..."
python3 -c "
import csv
total = sum(int(r[4]) if r[4] else 0 for r in csv.reader(open('tmdb-movies.csv')) if r[0] != 'id')
with open('output/task4_total_revenue.txt', 'w') as f:
    f.write(f'=== Task 4: Tổng doanh thu ===\n\${total:,}\n')
"

# Task 5: Top 10 Profitable
echo "Running Task 5: Top 10 profitable movies..."
python3 -c "
import csv
with open('tmdb-movies.csv') as f:
    reader = csv.reader(f)
    next(reader)
    rows = []
    for r in reader:
        budget = int(r[3]) if r[3] else 0
        revenue = int(r[4]) if r[4] else 0
        profit = revenue - budget
        rows.append((r[5], profit, revenue, budget))
rows.sort(key=lambda x: x[1], reverse=True)
with open('output/task5_top10_profit.txt', 'w') as f:
    f.write('=== Task 5: Top 10 phim lợi nhuận cao nhất ===\n')
    for i, (title, profit, rev, bud) in enumerate(rows[:10], 1):
        f.write(f'{i}. {title}\n   Profit: \${profit:,} | Revenue: \${rev:,} | Budget: \${bud:,}\n')
"

# Task 6: Top Directors & Actors
echo "Running Task 6: Top directors & actors..."
python3 -c "
import csv
from collections import Counter
directors = Counter()
actors = Counter()
with open('tmdb-movies.csv') as f:
    reader = csv.reader(f)
    next(reader)
    for r in reader:
        if r[8]: directors[r[8]] += 1
        if r[6]:
            for a in r[6].split('|'): actors[a.strip()] += 1
with open('output/task6_people.txt', 'w') as f:
    f.write('=== Task 6: Đạo diễn & Diễn viên ===\n\nĐạo diễn nhiều phim nhất:\n')
    for d, c in directors.most_common(5): f.write(f'  {d}: {c} phim\n')
    f.write('\nDiễn viên đóng nhiều phim nhất:\n')
    for a, c in actors.most_common(5): f.write(f'  {a}: {c} phim\n')
"

# Task 7: Genre stats
echo "Running Task 7: Genre statistics..."
python3 -c "
import csv
from collections import Counter
genres = Counter()
with open('tmdb-movies.csv') as f:
    reader = csv.reader(f)
    next(reader)
    for r in reader:
        if r[13]:
            for g in r[13].split('|'): genres[g.strip()] += 1
with open('output/task7_genres.txt', 'w') as f:
    f.write('=== Task 7: Số phim theo thể loại ===\n')
    for g, c in genres.most_common(): f.write(f'  {g}: {c}\n')
"

# Task 8: Additional Analysis
echo "Running Task 8: Additional analysis..."
python3 -c "
import csv
from collections import defaultdict
with open('output/task8_analysis.txt', 'w') as out:
    out.write('=== Task 8: Ý TƯỞNG PHÂN TÍCH BỔ SUNG ===\n\n')
    out.write('1. Xu hướng doanh thu trung bình theo năm:\n')
    year_revenue = defaultdict(list)
    with open('tmdb-movies.csv') as f:
        reader = csv.reader(f)
        next(reader)
        for r in reader:
            if r[18] and r[4]: year_revenue[int(r[18])].append(int(r[4]))
    for year in sorted(year_revenue.keys())[-10:]:
        avg = sum(year_revenue[year]) / len(year_revenue[year])
        out.write(f'  {year}: \${avg/1e6:.1f}M ({len(year_revenue[year])} films)\n')
    
    out.write('\n2. Thể loại có rating trung bình cao nhất:\n')
    genre_rating = defaultdict(list)
    with open('tmdb-movies.csv') as f:
        reader = csv.reader(f)
        next(reader)
        for r in reader:
            if r[13] and r[17]:
                for g in r[13].split('|'): genre_rating[g.strip()].append(float(r[17]))
    genre_avg = [(g, sum(r)/len(r)) for g, r in genre_rating.items() if len(r) >= 50]
    for g, avg in sorted(genre_avg, key=lambda x: x[1], reverse=True)[:5]:
        out.write(f'  {g}: {avg:.2f}\n')
"

echo "All tasks completed! Results are in 'output/' folder."
