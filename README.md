Proposed Commands
Task 1: Sắp xếp theo ngày phát hành giảm dần
python3 -c "
import csv
from datetime import datetime
with open('tmdb-movies.csv') as f:
    reader = csv.reader(f)
    header = next(reader)
    rows = list(reader)
# Parse date M/D/YY and sort descending
def parse_date(row):
    try:
        return datetime.strptime(row[15], '%m/%d/%y')
    except:
        return datetime.min
rows.sort(key=parse_date, reverse=True)
with open('task1_sorted_by_date.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerows(rows)
"
Task 2: Lọc phim có rating > 7.5
python3 -c "
import csv
with open('tmdb-movies.csv') as f:
    reader = csv.reader(f)
    header = next(reader)
    rows = [r for r in reader if r[17] and float(r[17]) > 7.5]
with open('task2_rating_above_7.5.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerows(rows)
"
Task 3: Phim có doanh thu cao nhất & thấp nhất
python3 -c "
import csv
with open('tmdb-movies.csv') as f:
    reader = csv.reader(f)
    next(reader)
    rows = [(r[5], int(r[4]) if r[4] else 0) for r in reader]
rows_with_rev = [(t,r) for t,r in rows if r > 0]
rows_with_rev.sort(key=lambda x: x[1])
print('Doanh thu THẤP NHẤT:', rows_with_rev[0])
print('Doanh thu CAO NHẤT:', rows_with_rev[-1])
"
Task 4: Tổng doanh thu
python3 -c "
import csv
total = sum(int(r[4]) if r[4] else 0 for r in csv.reader(open('tmdb-movies.csv')) if r[0] != 'id')
print(f'Tổng doanh thu: {total:,}')
"
Task 5: Top 10 phim lợi nhuận cao nhất
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
print('Top 10 phim lợi nhuận cao nhất:')
for i, (title, profit, rev, bud) in enumerate(rows[:10], 1):
    print(f'{i}. {title}: {profit:,} (Revenue: {rev:,}, Budget: {bud:,})')
"
Task 6: Đạo diễn & diễn viên đóng nhiều phim nhất
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
            for a in r[6].split('|'):
                actors[a.strip()] += 1
print('Đạo diễn nhiều phim nhất:')
for d, c in directors.most_common(5): print(f'  {d}: {c} phim')
print('Diễn viên đóng nhiều phim nhất:')
for a, c in actors.most_common(5): print(f'  {a}: {c} phim')
"
Task 7: Thống kê số phim theo thể loại
python3 -c "
import csv
from collections import Counter
genres = Counter()
with open('tmdb-movies.csv') as f:
    reader = csv.reader(f)
    next(reader)
    for r in reader:
        if r[13]:
            for g in r[13].split('|'):
                genres[g.strip()] += 1
print('Số phim theo thể loại:')
for g, c in genres.most_common(): print(f'  {g}: {c}')
"
Task 8: Ý tưởng phân tích thêm
Phân tích xu hướng doanh thu theo năm
Thể loại nào có rating trung bình cao nhất
Độ dài phim phổ biến nhất
Top 10 cặp đạo diễn - diễn viên hợp tác nhiều nhất
Verification Plan
Automated Verification
# Verify Task 1: Check sorted dates
head -5 task1_sorted_by_date.csv
tail -5 task1_sorted_by_date.csv
# Verify Task 2: Check all ratings > 7.5
python3 -c "
import csv
with open('task2_rating_above_7.5.csv') as f:
    reader = csv.reader(f)
    next(reader)
    for r in reader:
        if float(r[17]) <= 7.5:
            print('ERROR:', r[5], r[17])
print('All ratings verified > 7.5')
"
