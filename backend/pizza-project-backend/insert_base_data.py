import csv

from pathlib import Path 

def get_database():


resources_folder = Path(__file__).parents[1] / "res"

csv_files = ["categories.csv", "item_specialities.csv", "items.csv", "prices.csv"]

for csv in csv_files:
