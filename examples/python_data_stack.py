# %% [markdown]
# # Course-core Python data stack — quick functional test (Polars)
#
# Run cell-by-cell in VS Code (or `python examples/python_data_stack.py`). Each
# cell exercises a different part of the environment and prints a small result.
# The data stack here is **Polars** (not pandas).

# %% numpy + polars
import numpy as np
import polars as pl

df = pl.DataFrame({"x": np.arange(1, 6), "y": np.arange(1, 6) ** 2})
print(df)
print("polars", pl.__version__, "| numpy", np.__version__)

# %% scikit-learn — fit a tiny model (Polars -> numpy)
from sklearn.linear_model import LinearRegression

X = df.select("x").to_numpy()
y = df.get_column("y").to_numpy()
model = LinearRegression().fit(X, y)
print("sklearn slope:", round(float(model.coef_[0]), 3))

# %% statsmodels — OLS on numpy arrays (no pandas needed)
import statsmodels.api as sm

res = sm.OLS(y, sm.add_constant(X)).fit()
print("statsmodels R^2:", round(res.rsquared, 4))

# %% xgboost — train a trivial model (verifies the native lib loads)
import xgboost as xgb

dtrain = xgb.DMatrix(X, label=y)
booster = xgb.train({"max_depth": 2, "verbosity": 0}, dtrain, num_boost_round=3)
print("xgboost predictions:", np.round(booster.predict(dtrain), 2))

# %% polars — a few expressions (the data-wrangling workhorse)
out = (
    df.with_columns((pl.col("y") - pl.col("x")).alias("gap"))
    .filter(pl.col("x") >= 2)
    .select(pl.col("x"), pl.col("y"), pl.col("gap"))
)
print(out)
print("x mean:", df.get_column("x").mean(), "| y sum:", df.get_column("y").sum())

# %% plotnine — build a plot object (works directly with a Polars frame)
from plotnine import aes, geom_line, ggplot

plot = ggplot(df, aes("x", "y")) + geom_line()
print("plotnine ggplot object:", type(plot).__name__, "OK")

# %%
print("\nData stack OK.")
