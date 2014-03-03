echo "Now generating the avgs..."
for f in 10 20 30 40 50 60 70 80 90 100
do
  echo "$f app: " >> test_results
  cat git_test/git_push$f | grep real | awk '{sum+=$2}END{print sum/NR}'  >> test_results
  echo "" >> test_results
  sleep 1
done

