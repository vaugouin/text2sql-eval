"""Parse and check a result-shape assertion against a /search/text2sql response.

FASTAPI-TEXT2SQL-349 added three deterministic fields to the API response: `result_kind`,
`result_columns` (one `{name, role, unit}` per projected column) and `representation`. This
module lets the evaluation bank assert on them, so the rendering hint is evaluable the way
every other API defect is closed here ("this sum returns result_kind scalar, unit minutes"
is true or false).

**It is a check, not a score.** The campaign pass is computed from `query_result` alone
(harness/harness_lib.py); this assertion lives in its own column `ASSERTIONS_RESULT_SHAPE`
and is read only by the out-of-score checker `checks/check-result-shape.py`. Adding or
editing it never moves a campaign number, which is the whole point: it evaluates the new
feature without perturbing the accuracy everyone tracks.

Grammar. One clause per line (or separated by `;` or ` AND `), each `LHS OP RHS`:

    result_kind == scalar
    representation == number-card
    unit(TOTAL_RUNTIME) == minutes
    role(GENRE_NAME) == label

- LHS is `result_kind`, `representation`, or `unit(COL)` / `role(COL)` naming a column.
  `unit(*)` / `role(*)` names the single metric column instead, which is the robust form
  for a generated query whose aggregate alias the model chooses (`TOTAL_RUNTIME` is not
  guaranteed); it fails when the result has no metric column or more than one.
- OP is `==` or `!=`.
- RHS is a bare token, compared case-insensitively; `null` / `none` means "no unit".
- All clauses must hold for the assertion to pass. An empty assertion passes vacuously.

The grammar is deliberately tiny and additive: a new facet is a new LHS keyword and one
branch in `_check_clause`, with no change to the campaign scorer.
"""
import html
import re

_CLAUSE_RE = re.compile(
    r"^\s*(result_kind|representation|unit|role)\s*(?:\(\s*([A-Za-z_][A-Za-z0-9_]*|\*)\s*\))?\s*(==|!=)\s*(.+?)\s*$",
    re.IGNORECASE,
)
_NULLS = {"null", "none", ""}


def parse(spec_text):
    """Parse an assertion string into a list of clause dicts.

    Returns [] for an empty assertion. Raises ValueError on a clause that does not match
    the grammar, so a typo in the bank is caught at check time rather than passing silently.
    """
    if not spec_text:
        return []
    text = html.unescape(spec_text).strip()
    if not text:
        return []
    clauses = []
    for raw in re.split(r"[;\n]|\s+AND\s+", text, flags=re.IGNORECASE):
        raw = raw.strip()
        if not raw:
            continue
        m = _CLAUSE_RE.match(raw)
        if not m:
            raise ValueError(f"unparseable result-shape clause: {raw!r}")
        key, col, op, rhs = m.group(1).lower(), m.group(2), m.group(3), m.group(4).strip().lower()
        if key in ("unit", "role") and not col:
            raise ValueError(f"{key} clause needs a column, e.g. {key}(RUNTIME) == …: {raw!r}")
        if key in ("result_kind", "representation") and col:
            raise ValueError(f"{key} takes no column: {raw!r}")
        clauses.append({"key": key, "col": (col.upper() if col else None), "op": op, "value": rhs})
    return clauses


def _sole_metric(columns):
    """Return (found, column) for the single metric column, or (False, None) if not exactly one."""
    metrics = [c for c in (columns or []) if str(c.get("role", "")).lower() == "metric"]
    return (True, metrics[0]) if len(metrics) == 1 else (False, None)


def _pick_column(columns, name):
    """Resolve a clause column: '*' means the sole metric column, else match by name."""
    if name == "*":
        return _sole_metric(columns)
    for c in columns or []:
        if str(c.get("name", "")).upper() == name:
            return True, c
    return False, None


def _column_unit(columns, name):
    """Return (found, unit) for a column (name or '*') in result_columns."""
    found, c = _pick_column(columns, name)
    return (found, (c.get("unit") or None) if found else None)


def _column_role(columns, name):
    found, c = _pick_column(columns, name)
    return (found, (c.get("role") or None) if found else None)


def _check_clause(clause, response):
    """Return (passed, message) for one clause against a response dict."""
    key, col, op, want = clause["key"], clause["col"], clause["op"], clause["value"]
    if key == "result_kind":
        got = (response.get("result_kind") or "").lower()
    elif key == "representation":
        got = (response.get("representation") or "").lower()
    elif key in ("unit", "role"):
        found, raw = (_column_unit if key == "unit" else _column_role)(
            response.get("result_columns"), col
        )
        if not found:
            why = "no single metric column" if col == "*" else "no such column in result_columns"
            return False, f"{key}({col}): {why}"
        got = (raw or "null").lower() if key == "unit" else (raw or "").lower()
    else:  # unreachable via parse()
        return False, f"unknown key {key}"

    want_norm = "null" if (key == "unit" and want in _NULLS) else want
    equal = (got == want_norm)
    passed = equal if op == "==" else (not equal)
    label = f"{key}({col})" if col else key
    return passed, f"{label} {op} {want}  (got {got!r})  {'PASS' if passed else 'FAIL'}"


def check_response(spec_text, response):
    """Check a result-shape assertion against an API response.

    Args:
        spec_text: the ASSERTIONS_RESULT_SHAPE string (may be empty).
        response: the parsed /search/text2sql response (result_kind, representation,
            result_columns).

    Returns:
        (overall_pass, details) where details is a list of per-clause dicts
        {passed, message}. An empty assertion is a vacuous pass with no details.
    """
    clauses = parse(spec_text)
    if not clauses:
        return True, []
    details = []
    overall = True
    for clause in clauses:
        passed, message = _check_clause(clause, response)
        details.append({"passed": passed, "message": message})
        overall = overall and passed
    return overall, details
