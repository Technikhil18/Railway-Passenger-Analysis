# Railway Passenger Booking & Cancellation Analysis

## Project overview

This is a practice data-analytics project based on a 500-row railway booking sample. It uses Microsoft Excel for an overview dashboard, Python (Pandas and Matplotlib) for repeatable analysis and charts, and MySQL for querying booking records.

The analysis explores train-wise and class-wise demand, recorded fares, booking status, payment methods, cancellation patterns, age groups, routes and booking lead time.

> **Dataset limitation:** This is a sample/demo dataset, not official Indian Railways data. The source data contains 33 rows where Source and Destination are the same. Those records are retained and flagged in the data-quality report rather than silently changed. Fare totals are the sum of the Fare column, not audited railway revenue.

## Repository structure

```text
Railway-Passenger-Analysis/
├── README.md
├── requirements.txt
├── .gitignore
├── data/
│   └── railway_passenger_data.csv
├── excel/
│   └── Railway_Passenger_Analysis_Dashboard.xlsx
├── python/
│   ├── analyze.py
│   └── outputs/
│       ├── kpi_summary.csv
│       ├── data_quality_report.csv
│       ├── *_analysis.csv / *_bookings.csv
│       └── charts/
└── sql/
    ├── 01_schema_and_import.sql
    └── 02_analysis_queries.sql
```

## Dataset

The CSV contains 500 rows and these fields: `Booking_ID`, `Passenger_ID`, `Train_Name`, `Source`, `Destination`, `Journey_Date`, `Booking_Date`, `Class`, `Passenger_Age`, `Gender`, `Fare`, `Payment_Mode`, `Booking_Status`, `Cancellation_Status`.

## Sample findings

| Measure | Result |
|---|---:|
| Total bookings | 500 |
| Total recorded fare | ₹677,975.00 |
| Average fare | ₹1,355.95 |
| Confirmed bookings | 245 |
| Records marked cancelled | 33 |
| Cancellation rate | 6.60% |
| Most-booked train | Garib Rath (123 bookings) |

These figures describe only this sample. The dataset does not define a refund or net-revenue rule for cancelled bookings.

## Run the Python analysis

Run these commands from the repository's main folder.

### 1. Create a virtual environment

```bash
python -m venv .venv
```

### 2. Activate it

Windows PowerShell:
```powershell
.venv\Scripts\Activate.ps1
```

Windows Command Prompt:
```bat
.venv\Scripts\activate.bat
```

macOS/Linux:
```bash
source .venv/bin/activate
```

### 3. Install dependencies and run

```bash
pip install -r requirements.txt
python python/analyze.py
```

The script reads `data/railway_passenger_data.csv` and writes KPI summaries, grouped CSV files, a data-quality report and PNG charts to `python/outputs/`.

## Run the MySQL analysis

1. Open MySQL Workbench or MySQL 8 Command Line Client.
2. Run `sql/01_schema_and_import.sql` to create the database and table. The script uses `CREATE TABLE IF NOT EXISTS` and does not drop existing data.
3. Import `data/railway_passenger_data.csv` into `railway_analysis.railway_bookings`. In MySQL Workbench, use the Table Data Import Wizard and map the columns in CSV order. The two date columns use `YYYY-MM-DD`.
4. Run `sql/02_analysis_queries.sql`.
5. Verify the import with `SELECT COUNT(*) FROM railway_analysis.railway_bookings;` — the sample should return 500 after a successful first import.

The commented `LOAD DATA LOCAL INFILE` example in the schema file is optional; update its path to your own absolute file path before using it. Do not run an import twice without handling duplicate `Booking_ID` values.

## Questions explored

1. How many bookings are in the sample?
2. What are the total recorded fare and average fare?
3. Which train has the most bookings?
4. Which train has the highest total recorded fare?
5. Which class is booked most often?
6. What is the distribution of booking statuses?
7. What share of records is marked cancelled?
8. Which payment modes appear most often?
9. How are passengers distributed across age groups?
10. How do bookings vary by journey month?
11. Which source-destination pairs occur most often?
12. What is the average booking lead time?

## Data-quality checks

The Python script reports missing required cells, duplicate booking IDs, journey dates earlier than booking dates, same-city source/destination pairs, invalid ages and missing/negative fares. It reports these conditions rather than silently modifying the source data.

## Tools used

- Microsoft Excel
- Python 3, Pandas and Matplotlib
- MySQL 8
- Git and GitHub

## Author

**Nikhil Patel**  
MCA | Data Analytics Project
