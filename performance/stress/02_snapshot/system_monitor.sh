#Record the broker or node system level usability if needed
echo "Input the number of apps you want to record:"
read j

sar -ubBrq -n DEV 1 -o system$j.log
