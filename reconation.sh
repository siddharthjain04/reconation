#!/bin/bash

cd /var/www/html/

echo -e "\e[1;33m[+] Running certspotter & CRTsh\e[0m"
curl -s https://crt.sh/?q=%25.$1 | grep $1 | grep "<TD>" | cut -d">" -f2 | cut -d"<" -f1 | sort -u | sed s/*.//g >> crtsh.txt

echo -e "\e[1;33m[+] Running Findomain\e[0m"
findomain -t $1 -u findomain.txt

echo -e "\e[1;33m[+] Running Subfinder\e[0m"
subfinder -d $1 -o subfinder.txt

echo -e "\e[1;33m[+] Running Assetfinder\e[0m"
assetfinder -subs-only $1 > assetfinder.txt

echo -e "\e[1;33m[+] Running Amass\e[0m"
amass enum -passive -d $1 -o amass.txt

echo -e "\e[1;33m[+] Running ShuffleDNS\e[0m"
shuffledns -d $1 -massdns /home/ubuntu/tools/massdns/bin/massdns -w /home/ubuntu/tools/massdns/lists/all.txt -r /home/ubuntu/tools/massdns/lists/resolvers.txt -o shuffledns.txt

echo -e "\e[1;33m[+] Merging Files\e[0m"
cat *.txt > all_old.txt
sort -u all_old.txt > all.txt

echo -e "\e[1;33m[+] Resolving Domains\e[0m"
shuffledns -d $1 -massdns /home/ubuntu/tools/massdns/bin/massdns -list all.txt -o domains.txt -r /home/ubuntu/tools/massdns/lists/resolvers.txt

echo -e "\e[1;33m[+] Running HTTPx\e[0m"
cat domains.txt | httpx -threads 200 -o live_domains.txt

echo -e "\e[1;33m[+] Running Nuclei\e[0m"
cat live_domains.txt | nuclei -t /home/ubuntu/nuclei-templates/cves/ -c 50 -o nuclei_cve.txt 
cat live_domains.txt | nuclei -t /home/ubuntu/nuclei-templates/files/ -c 50 -o nuclei_files.txt
cat live_domains.txt | nuclei -t /home/ubuntu/nuclei-templates/technologies -c 50 -o nuclei_technologies.txt
cat live_domains.txt | nuclei -t /home/ubuntu/nuclei-templates/security-misconfiguration -c 50 -o nuclei_security-misconfiguration.txt

echo -e "\e[1;33m[+] Running WaybackUrl | GAU | Hakrawler\e[0m" 
cat live_domains.txt | waybackurls | tee tmp-url.txt
echo $1 | gau >> tmp-url.txt
echo $1 | hakrawler | awk '{print $2}' >> tmp-url.txt
cd /home/ubuntu/tools/waybackMachine
python waybackmachine.py $1 >> /var/www/html/tmp-url
cd /var/www/html/
sort -u tmp-url.txt >>  tmp.txt
cat tmp.txt | egrep -v "\.woff|\.ttf|\.svg|\.eot|\.png|\.jpeg|\.jpg|\.svg|\.css|\.ico" | sed 's/:80//g;s/:443//g' | sort -u > urls.txt


echo -e "\e[1;33m[+] Running FFUF\e[0m"
ffuf -c -u "FUZZ" -w urls.txt -of csv -o /var/www/html/valid-tmp.txt
cat valid-tmp.txt | grep http | awk -F "," '{print $1}' >> /var/www/html/valid-urls.txt

echo -e "\e[1;33m[+]Finding all the Live IP's\e[0m"
ipfinder live_domains.txt ipfinder.txt

echo -e "\e[1;33m[+]Finding IP's through ASN block's\e[0m"
asnip -t $1 -p 
cat ipfinder.txt cidrs.txt >> tmp-ip.txt

echo -e "\e[1;33m[+]Finding IP's through DNS Buffer's\e[0m"
curl -s https://dns.bufferover.run/dns?q=$1 | grep $1 | grep -Eo '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}' | sort -u >> tmp-ip.txt

echo -e "\e[1;33m[+]Cleaning IP list 's\e[0m"
sort -u tmp-ip.txt > ip.txt

echo -e "\e[1;33m[+]Running Port Scan 's\e[0m" 
naabu -hL ip.txt -o /var/www/html/live_ip.txt -ports full -silent

echo -e "\e[1;33m[+]Running ParamSpider 's\e[0m" 
cd /home/ubuntu/tools/ParamSpider/
python3 paramspider.py -d $1 -o /var/www/html/paramspider.txt 
cd /var/www/html/

echo -e "\e[1;33m[+]Running FFUF 's\e[0m" 
ffuf -c -w /home/ubuntu/massdns/lists/all.txt -u $1/FUZZ -mc all -fs 4242 -v -o /var/www/html/fuff.txt 

echo -e "\e[1;33m[+]Running Arjun 's\e[0m" 
cd /home/ubuntu/tools/Arjun/
python3 arjun.py --urls valid-urls.txt --get -o /var/www/html/arjun.txt

