"""
platform:      any
description:   Onsite Coding Test - Challenge 2
"""

import pandas as pd
import numpy as np
import pandas as pd
import os


def load_data(file_path: str) -> pd.DataFrame:
    """
    Load financial data from a given file path.
    """
    data = pd.read_csv(
        file_path, header=None, names=["DateTime", "Open", "High", "Low", "Close"]
    )
    data["DateTime"] = pd.to_datetime(data["DateTime"])
    return data.set_index("DateTime")


def find_all_highest_correlations(data_folder: str):
    """
    Find all pairs of stocks with the same highest correlation in closing prices.
    """
    files = [
        os.path.join(data_folder, f)
        for f in os.listdir(data_folder)
        if f.endswith(".txt")
    ]
    closing_prices = {
        os.path.basename(file).split("_")[0]: load_data(file)["Close"] for file in files
    }

    df = pd.DataFrame(closing_prices)
    correlation_matrix = df.corr()

    # Mask to extract upper triangle without diagonal
    mask = np.triu(np.ones_like(correlation_matrix, dtype=bool), k=1)
    unique_correlations = correlation_matrix.where(mask).stack()

    max_correlation = unique_correlations.max()
    highest_pairs = unique_correlations[ unique_correlations == max_correlation ].index.tolist()

    return highest_pairs, max_correlation


def main():
    data_folder = "hour"
    highest_pairs, max_correlation = find_all_highest_correlations(data_folder)
    print(f"All pairs with the highest correlation of {max_correlation:.2f}:")
    for pair in highest_pairs:
        print(pair)


if __name__ == "__main__":
    main()
