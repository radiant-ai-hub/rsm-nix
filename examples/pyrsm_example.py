# %% [markdown]
# # pyrsm — quick modeling test (Polars data)
#
# `pyrsm` is the Rady School helper package used in the MSBA Python courses.
# This exercises a linear and a logistic regression on synthetic **Polars** data.
# Run cell-by-cell in VS Code, or `python examples/pyrsm_example.py`.
#
# pyrsm's model classes accept Polars (or pandas) frames directly.

# %%
import numpy as np
import polars as pl
import pyrsm as rsm

print("pyrsm", rsm.__version__)

rng = np.random.default_rng(42)
n = 500
x1 = rng.normal(size=n)
x2 = rng.normal(size=n)
group = rng.choice(["a", "b", "c"], size=n)

# %% linear regression (OLS) with pyrsm.model.regress — formula interface (R-style)
price = 5 + 2.0 * x1 - 1.0 * x2 + rng.normal(scale=0.5, size=n)
sales = pl.DataFrame({"x1": x1, "x2": x2, "group": group, "price": price})

reg = rsm.model.regress(data={"sales": sales}, formula="price ~ x1 + x2 + group")
reg.summary()

# %% logistic regression with pyrsm.model.logistic
# a binary outcome ("yes"/"no") driven mostly by x1
prob = 1.0 / (1.0 + np.exp(-(0.5 + 1.5 * x1 - 0.8 * x2)))
buy = np.where(rng.uniform(size=n) < prob, "yes", "no")
customers = sales.with_columns(pl.Series("buy", buy))

clf = rsm.model.logistic(
    data={"customers": customers}, rvar="buy", lev="yes", evar=["x1", "x2"]
)
clf.summary()

# %%
print("\npyrsm OK.")
