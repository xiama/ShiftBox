echo "Now generating the avgs..."

#for f in 5 10 20 30 40 50 60 70 80 90 100
for f in 3
do
  echo "$f app: " >> add_test_results
  cat ./time/add_key$f | grep real | awk '{sum+=$2}END{print sum/NR}'  >> add_test_results
  echo "" >> add_test_results
  sleep 1
done

#for f in 5 10 20 30 40 50 60 70 80 90 100
for f in 3
do
  echo "$f app: " >> remove_test_results
  cat time/remove_key$f | grep real | awk '{sum+=$2}END{print sum/NR}'  >> remove_test_results
  echo "" >> remove_test_results
  sleep 1
done

