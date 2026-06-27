# %% [markdown]
# # Course-core Python data stack — quick functional test (Polars)
#
# Run cell-by-cell in VS Code (or `python examples/python_data_stack.py`). Each
# cell exercises a different part of the environment and prints a small result.
# The data stack here is **Polars** (not pandas).

# %% numpy + polars — a small synthetic regression dataset
import numpy as np
import polars as pl

rng = np.random.default_rng(42)
n = 300
x1 = rng.normal(size=n)
x2 = rng.normal(size=n)
price = 5 + 2.0 * x1 - 1.0 * x2 + rng.normal(scale=0.5, size=n)
df = pl.DataFrame({"x1": x1, "x2": x2, "price": price})
print(df.head())
print("polars", pl.__version__, "| numpy", np.__version__)

# %% statsmodels — the R-style formula interface
# statsmodels' formula API uses patsy, which expects a pandas frame, so convert
# just for the fit (the data itself stays Polars).
import statsmodels.formula.api as smf

ols = smf.ols("price ~ x1 + x2", data=df.to_pandas()).fit()
print(ols.summary())

# %% pyrsm — the SAME model via its formula interface (takes Polars directly)
import pyrsm as rsm

reg = rsm.model.regress(data={"df": df}, formula="price ~ x1 + x2")
reg.summary()

# %% scikit-learn — a classification task (random forest), not regression
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split

label = (df.get_column("price") > df.get_column("price").median()).to_numpy()
X = df.select(["x1", "x2"]).to_numpy()
Xtr, Xte, ytr, yte = train_test_split(X, label, test_size=0.3, random_state=42)
clf = RandomForestClassifier(n_estimators=100, random_state=42).fit(Xtr, ytr)
print("random forest test accuracy:", round(clf.score(Xte, yte), 3))

# %% xgboost — gradient boosting (verifies the native lib loads)
import xgboost as xgb

dtrain = xgb.DMatrix(X, label=df.get_column("price").to_numpy())
booster = xgb.train({"max_depth": 2, "verbosity": 0}, dtrain, num_boost_round=5)
print("xgboost predictions (first 5):", np.round(booster.predict(dtrain)[:5], 2))

# %% polars — a few expressions (the data-wrangling workhorse)
out = (
    df.with_columns((pl.col("price") > pl.col("price").median()).alias("expensive"))
    .group_by("expensive")
    .agg(pl.len().alias("n"), pl.col("price").mean().round(2).alias("avg_price"))
    .sort("expensive")
)
print(out)

# %% plotnine — build a plot object (works directly with a Polars frame)
from plotnine import aes, geom_point, ggplot

plot = ggplot(df, aes("x1", "price")) + geom_point()
print("plotnine ggplot object:", type(plot).__name__, "OK")

# %%
print("\nData stack OK.")
