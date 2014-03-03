echo "Now generating the avgs..."

for f in 5 10 20 30 40 50 60 70 80 90 100
do
  echo "$f app: " >> save_test_results
  cat ./save/save_test/snapshot_save$f | grep real | awk '{sum+=$2}END{print sum/NR}'  >> save_test_results
  echo "" >> save_test_results
  sleep 1
done

for f in 5 10 20 30 40 50 60 70 80 90 100
do
  echo "$f app: " >> restore_test_results
  cat ./restore/restore_test/snapshot_restore$f | grep real | awk '{sum+=$2}END{print sum/NR}'  >> restore_test_results
  echo "" >> restore_test_results
  sleep 1
done

