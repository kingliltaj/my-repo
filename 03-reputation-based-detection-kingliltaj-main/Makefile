#.PHONY = all clean

IN := $(wildcard *.pcap)

all: suricata.log

suricata.log: 
	for file in $(IN) ; do suricata -c suricata.yaml -r $$file ; done

clean:
	rm -rvf *.log eve.json
