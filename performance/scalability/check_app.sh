for i in `seq 1 1700`
do
  result=$(curl -I app$i-name$i.scalability.com |head -n 1|awk '{print $2}')
  if [ $result == 200 ]
  then
    echo "app$i is running and available" >> result.log
  else
    echo "app$i is not availeble!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> result.log
  fi

  echo "######################################" >> result.log
done
