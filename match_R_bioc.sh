#!/bin/bash 
R_path=$1
bioc_path=$2


R_pl=/tmp/R_packs_locs.txt 
B_pl=/tmp/bl_pl.txt 
R_pn=/tmp/rpn.txt
B_pn=/tmp/bpn.txt

ls ${R_path} > ${R_pl}
ls ${bioc_path} > ${B_pl}
cat ${R_pl} | grep ".tar.gz" - |  cut -d'_' -f1 > $R_pn 
cat ${B_pl} | grep ".tar.gz" - |  cut -d'_' -f1 > $B_pn 


R_common_packs=/tmp/cpacks.txt
B_common_packs=/tmp/asfddfgfgad.txt
common_packs=/tmp/asfsdfdzzz.txt

#only swap packages that are common between the two 
grep -o -Ff ${R_pn} ${B_pl} | sort > ${R_common_packs} 
grep -o -Ff ${B_pn} ${R_pl} | sort  >${B_common_packs}
comm -12 $R_common_packs $B_common_packs > ${common_packs}


# create list of regex patterns to match accurately matach packages 
sed -i -e 's/^/\^/' $common_packs
sed -i -e 's/$/_(.+)\.tar\.gz$/' $common_packs


cp_R_locs=/tmp/sdfsdf.txt 
cp_B_locs=/tmp/gfghgh.txt
grep -Ef ${common_packs} ${R_pl} > ${cp_R_locs}
grep -Ef ${common_packs} ${B_pl} > ${cp_B_locs}

cat ${cp_R_locs} | while read i;
do 
    rm ${R_path}/$i ;
done

cat ${cp_B_locs} | while read j;
do 
    cp ${bioc_path}/$j ${R_path}/
done 








