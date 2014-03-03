echo "Now generating the avgs..."
for f in 3 5 10
do
  echo "Scale-up $f app: " >> test_results
  cat up_time$f | grep real | awk '{sum+=$2}END{print sum/NR}'  >> test_results
  echo "" >> test_results
  sleep 1
done
