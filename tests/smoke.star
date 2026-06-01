# Stable smoke test — assert on the contract (exit code, version shape,
# computed result), never on help/version prose. jq is a pure-compute CLI
# with no declared non-PATH env var, so its full contract is Tiers 1-3.
JQ = "jq.exe" if ocx.target_platform.os == ocx.os.Windows else "jq"

# Tier 1 + 2: liveness + version SHAPE. jq prints `jq-1.8.1` (three digits)
# on recent releases and `jq-1.7` (two digits) on the floor, so the shape
# match stops at the minor component — stable across the mirror's lifetime.
r_version = ocx.run(JQ, "--version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+")

# Tier 3: functional behavior on a pure computation — assert the result, not
# prose. Exercises the parser + evaluator the actual code path uses.
r_compute = ocx.run(JQ, "-n", "1 + 1")
expect.ok(r_compute)
expect.contains(r_compute.stdout, "2")

# Tier 3b: a hermetic filter over real JSON input on stdin proves the
# end-to-end read → evaluate → emit path, asserting the extracted value.
r_filter = ocx.run(JQ, "-r", ".value", stdin='{"value": "ok"}')
expect.ok(r_filter)
expect.contains(r_filter.stdout, "ok")
