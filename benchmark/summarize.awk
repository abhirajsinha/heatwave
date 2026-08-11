# Metric computation from the harness CSV (FR-7). Usage: awk -F, -f summarize.awk <run.csv>
# Denominator = graded rows present in the CSV; NOT-RUN tasks have no row and are
# listed explicitly in RESULTS.md.
NR > 1 && $2 != "" {
  arm = $3
  graded[arm]++
  ora[arm]  += $6
  esc[arm]  += $7
  wall[arm] += $8
  if ($9 != "") { cost[arm] += $9; costed[arm]++ }
}
END {
  for (arm in graded) {
    printf "%s: graded=%d oracle_pass=%d/%d escaped_defects=%d/%d escape_rate=%.3f mean_wall=%.1fs", \
      arm, graded[arm], ora[arm], graded[arm], esc[arm], graded[arm], \
      esc[arm] / graded[arm], wall[arm] / graded[arm]
    if (costed[arm] > 0) printf " total_cost=$%.4f (over %d costed rows)", cost[arm], costed[arm]
    printf "\n"
  }
}
