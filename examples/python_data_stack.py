# %% [markdown]
# # Course-core Python data stack — quick functional test
#
# Run cell-by-cell in VS Code (or `python examples/python_data_stack.py`). Each
# cell exercises a different part of the environment and prints a small result.

# %% numpy + pandas
import numpy as np
import pandas as pd

df = pd.DataFrame({"x": np.arange(1, 6), "y": np.arange(1, 6) ** 2})
print(df)
print("pandas", pd.__version__, "| numpy", np.__version__)

# %% scikit-learn — fit a tiny model
from sklearn.linear_model import LinearRegression

model = LinearRegression().fit(df[["x"]], df["y"])
print("sklearn slope:", round(float(model.coef_[0]), 3))

# %% statsmodels — OLS summary (one line)
import statsmodels.formula.api as smf

res = smf.ols("y ~ x", data=df).fit()
print("statsmodels R^2:", round(res.rsquared, 4))

# %% xgboost — train a trivial model (verifies the native lib loads)
import xgboost as xgb

dtrain = xgb.DMatrix(df[["x"]].values, label=df["y"].values)
booster = xgb.train({"max_depth": 2, "verbosity": 0}, dtrain, num_boost_round=3)
print("xgboost predictions:", np.round(booster.predict(dtrain), 2))

# %% polars + pyarrow
import polars as pl

pdf = pl.DataFrame({"a": [1, 2, 3], "b": ["x", "y", "z"]})
print(pdf)
print("polars", pl.__version__)

# %% plotnine — build a plot object (no display needed to verify it works)
from plotnine import aes, geom_line, ggplot

plot = ggplot(df, aes("x", "y")) + geom_line()
print("plotnine ggplot object:", type(plot).__name__, "OK")

# %%
print("\nData stack OK.")
