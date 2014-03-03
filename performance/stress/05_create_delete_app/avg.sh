echo "Now generating the avgs..."
for f in 5 10 15 20 25 30 35 40 45
do
  echo "Create $f app: " >> test_results
  cat Jboss/Jboss_time$f | grep real | awk '{sum+=$2}END{print sum/NR}'  >> test_results
  echo "" >> test_results
  sleep 1
done

