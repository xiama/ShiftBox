#!/bin/bash

if [ $# -lt 3 ];then
	echo "Please input correct format, such as:"
	echo -e "\e[1;33m$0 source_file result_png  cloumn_id1 cloumn_id2 ... \e[0m"
	exit 1
fi

pwd=$(pwd)
plot_config_file="2dcompare.tmp"
source_file=$1
result_png=$2
shift 2
parameter_no=$#
columns=$@

xlabel="Time"
ylabel="Size (M)"

>$plot_config_file

cat <<EOF > $plot_config_file
set grid
set xtics rotate
set terminal png
set output "$result_png"
set title "graph"
set xlabel "$xlabel"
set ylabel "$ylabel"
EOF

# Set x lable as time stramp
###timestramp=$(cat $source_file|awk '{print $3}'|grep ^[0-9])
###
###number=0
###for time in $timestramp;do
###    [ -z "$xvariable" ] && xvariable="\"$time\" $number" || xvariable="$xvariable, \"$time\" $number"
###    number=$(($number + 1))
###    #echo $xvariable
###done
###echo "set xtics ($xvariable)" >> $plot_config_file


generate_plot_file()
{
        for column in $columns;do
            var=$1
            title=`cat $source_file|gawk '{print $i}' i=$column|head -n 1`
            file=plot_file_$title
            cat $source_file|gawk '{print $i}' i=$column |grep ^[1-9] > temp
            awk '{print NR-1,$0}' temp > $file
            sed -i 's/^[ \t]*//g' $file
            sed -i "1 i\0 $title" $file
            [ -z "$plot_para" ] && plot_para="'$file' w lp title \"$title\"" || plot_para="$plot_para, '$file' w lp title \"$title\""
        done
        echo "plot $plot_para" >> $plot_config_file
}

generate_plot_file

gnuplot $plot_config_file
