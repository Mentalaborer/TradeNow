# Python
import pandas as pd
import numpy as np
from pandas_datareader import data as pdr

# Load historical data
data = pdr.get_data_yahoo('AAPL', start='2020-01-01', end='2021-12-31')

# Calculate moving averages
data['SMA_50'] = data['Close'].rolling(window=50).mean()
data['SMA_200'] = data['Close'].rolling(window=200).mean()

# Generate trading signals based on crossover of moving averages
data['Signal'] = 0.0
data['Signal'][50:] = np.where(data['SMA_50'][50:] > data['SMA_200'][50:], 1.0, 0.0)

# Calculate daily returns of strategy
data['Return'] = data['Close'].pct_change()
data['Strategy_Return'] = data['Return'] * data['Signal'].shift()

# Evaluate performance
total_return = data['Strategy_Return'].cumsum()[-1]
print(f'Total return: {total_return * 100:.2f}%')