# Metric computation (E2 schema). gradable = outcome "graded"; timeout/escalated/
# error rows are completion failures: excluded from the escape-rate denominator,
# reported as their own rate — never hidden, never scored as shipped defects.
# Columns: 1 run_id 2 task 3 arm 4 trial 5 outcome 6 terminal 7 tier 8 stage_model
#          9 visible_pass 10 oracle_pass 11 escaped_defect 12 wall_secs 13 cost_usd 14 notes
NR > 1 && $2 != "" {
  arm = $3; total[arm]++; oc[arm "," $5]++
  if ($5 == "graded") { graded[arm]++; ora[arm] += $10; esc[arm] += $11 }
  wall[arm] += $12
  if ($13 != "") { cost[arm] += $13; costed[arm]++ }
}
END {
  for (arm in total) {
    printf "%s: completed=%d/%d", arm, graded[arm], total[arm]
    if (graded[arm] > 0)
      printf " escaped_defects=%d/%d gradable (rate=%.3f) oracle_pass=%d/%d", \
        esc[arm], graded[arm], esc[arm] / graded[arm], ora[arm], graded[arm]
    else
      printf " escaped_defects=N/A (0 gradable runs)"
    printf " outcomes[graded=%d timeout=%d escalated=%d error=%d]", \
      oc[arm ",graded"], oc[arm ",timeout"], oc[arm ",escalated"], oc[arm ",error"]
    printf " mean_wall=%.1fs", wall[arm] / total[arm]
    if (costed[arm] > 0) printf " total_cost=$%.4f (over %d costed rows)", cost[arm], costed[arm]
    printf "\n"
  }
}
