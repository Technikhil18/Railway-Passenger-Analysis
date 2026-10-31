"""Railway Passenger Booking & Cancellation Analysis.
Run from the repository root: python python/analyze.py
"""
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "railway_passenger_data.csv"
OUT = ROOT / "python" / "outputs"
CHARTS = OUT / "charts"


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    CHARTS.mkdir(parents=True, exist_ok=True)
    df = pd.read_csv(DATA, parse_dates=["Journey_Date", "Booking_Date"])

    required = [
        "Booking_ID", "Passenger_ID", "Train_Name", "Source", "Destination",
        "Journey_Date", "Booking_Date", "Class", "Passenger_Age", "Gender",
        "Fare", "Payment_Mode", "Booking_Status", "Cancellation_Status"
    ]
    missing_columns = sorted(set(required) - set(df.columns))
    if missing_columns:
        raise ValueError(f"Missing required columns: {missing_columns}")

    df["Fare"] = pd.to_numeric(df["Fare"], errors="coerce")
    df["Passenger_Age"] = pd.to_numeric(df["Passenger_Age"], errors="coerce")

    # Data-quality checks are reported, not silently corrected.
    quality = {
        "row_count": len(df),
        "missing_cells": int(df[required].isna().sum().sum()),
        "duplicate_booking_ids": int(df["Booking_ID"].duplicated().sum()),
        "journey_before_booking": int((df["Journey_Date"] < df["Booking_Date"]).sum()),
        "same_source_destination": int((df["Source"].str.strip().str.casefold() == df["Destination"].str.strip().str.casefold()).sum()),
        "negative_or_missing_fares": int((df["Fare"].isna() | (df["Fare"] < 0)).sum()),
        "invalid_ages": int((df["Passenger_Age"].isna() | (df["Passenger_Age"] < 0) | (df["Passenger_Age"] > 120)).sum()),
    }
    pd.DataFrame([{"check": k, "count": v} for k, v in quality.items()]).to_csv(
        OUT / "data_quality_report.csv", index=False
    )

    total = len(df)
    cancelled = int((df["Cancellation_Status"] == "Yes").sum())
    summary = {
        "total_bookings": total,
        "total_recorded_fare": round(df["Fare"].sum(), 2),
        "average_fare": round(df["Fare"].mean(), 2),
        "confirmed_bookings": int((df["Booking_Status"] == "Confirmed").sum()),
        "cancelled_bookings": cancelled,
        "cancellation_rate_pct": round(cancelled / total * 100, 2) if total else 0,
        "unique_trains": int(df["Train_Name"].nunique()),
        "unique_source_destination_pairs": int((df["Source"].astype(str).str.strip() + " - " + df["Destination"].astype(str).str.strip()).nunique()),
        "average_booking_lead_days": round((df["Journey_Date"] - df["Booking_Date"]).dt.days.mean(), 1),
    }
    pd.DataFrame([summary]).to_csv(OUT / "kpi_summary.csv", index=False)

    groupings = {
        "train_wise_bookings": df.groupby("Train_Name").size().sort_values(ascending=False),
        "class_wise_bookings": df.groupby("Class").size().sort_values(ascending=False),
        "revenue_by_train": df.groupby("Train_Name")["Fare"].sum().sort_values(ascending=False),
        "booking_status": df["Booking_Status"].value_counts(),
        "payment_mode": df["Payment_Mode"].value_counts(),
        "cancellation_status": df["Cancellation_Status"].value_counts(),
    }
    for name, series in groupings.items():
        series.rename_axis("Category").rename("Value").to_csv(OUT / f"{name}.csv")

    age_bins = [0, 25, 35, 45, 55, 120]
    age_labels = ["18-25", "26-35", "36-45", "46-55", "56+"]
    df["Age_Group"] = pd.cut(df["Passenger_Age"], bins=age_bins, labels=age_labels, include_lowest=True)
    df.groupby("Age_Group", observed=False).size().rename("Passengers").to_csv(OUT / "age_group_analysis.csv")

    monthly = df.groupby(df["Journey_Date"].dt.month).size().reindex(range(1, 13), fill_value=0)
    monthly.index = [pd.Timestamp(2000, month, 1).strftime("%b") for month in monthly.index]
    monthly.rename("Bookings").to_csv(OUT / "monthly_booking_trend.csv")

    plots = [
        (df["Train_Name"].value_counts().sort_values(ascending=False), "Bookings by Train", "Train", "Bookings", "bookings_by_train.png", "bar"),
        (df.groupby("Train_Name")["Fare"].sum().sort_values(ascending=False), "Recorded Fare by Train", "Train", "Recorded fare (INR)", "revenue_by_train.png", "bar"),
        (df["Booking_Status"].value_counts(), "Booking Status Distribution", "Status", "Bookings", "booking_status.png", "bar"),
        (df["Payment_Mode"].value_counts(), "Payment Mode Distribution", "Payment mode", "Bookings", "payment_mode.png", "bar"),
        (monthly, "Monthly Journey Trend", "Month", "Bookings", "monthly_trend.png", "line"),
    ]
    for series, title, xlabel, ylabel, filename, kind in plots:
        fig, ax = plt.subplots(figsize=(9, 5))
        if kind == "line":
            ax.plot(series.index.astype(str), series.values, marker="o")
        else:
            ax.bar(series.index.astype(str), series.values)
        ax.set_title(title)
        ax.set_xlabel(xlabel)
        ax.set_ylabel(ylabel)
        ax.tick_params(axis="x", rotation=20)
        ax.grid(axis="y", alpha=0.25)
        fig.tight_layout()
        fig.savefig(CHARTS / filename, dpi=160)
        plt.close(fig)

    print("Analysis complete.")
    for key, value in summary.items():
        print(f"{key}: {value}")
    print("Data-quality checks:")
    for key, value in quality.items():
        print(f"{key}: {value}")
    print(f"Outputs saved in: {OUT}")


if __name__ == "__main__":
    main()
