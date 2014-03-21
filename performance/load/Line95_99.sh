#the jtl raw data file is defined in line:101 in ./test.jmx, if
#you want to change the file, pls change the file in test.jmx first

number=$(awk -F "," '{print $2}' /home/pei/Desktop/jmeter.jtl|wc|awk '{print $1}')
N95=$number*0.95
N99=$number*0.99

Line95=$(awk -F "," '{print $2}' /home/pei/Desktop/jmeter.jtl|sort -n| awk "NR==$N95" )
Line99=$(awk -F "," '{print $2}' /home/pei/Desktop/jmeter.jtl|sort -n| awk "NR==$N99" )
echo "95 % Line is: $Line95"
echo "99 % Line is: $Line99"

cp /home/pei/Desktop/jmeter.jtl /home/pei/Desktop/jmeter.jtl$number 
> /home/pei/Desktop/jmeter.jtl
