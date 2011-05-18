#!/bin/bash

#BINDJAVA="pfexec psrset -e 1"
BINDJAVA=""

BINDIR=$(dirname $0)/
BASEDIR=${BINDIR}../

SLEEPTIME=30            ## 30
NUM_LOOPS=5             ## 5
THREADS=1               ## 1
MAXRECURSIONDEPTH=10    ## 10
TOTALCALLS=200000       ## 200000
RECORDEDCALLS=100000    ## 100000
METHODTIME=500000       ## 500000

TIME=`expr ${METHODTIME} \* ${TOTALCALLS} / 1000000000 \* 4 \* ${MAXRECURSIONDEPTH} \* ${NUM_LOOPS} + ${SLEEPTIME} \* 4 \* ${NUM_LOOPS}  \* ${MAXRECURSIONDEPTH}`
echo "Experiment will take circa ${TIME} seconds."

# determine correct classpath separator
CPSEPCHAR=":" # default :, ; for windows
if [ ! -z "$(uname | grep -i WIN)" ]; then CPSEPCHAR=";"; fi
# echo "Classpath separator: '${CPSEPCHAR}'"

RESULTSDIR="${BASEDIR}tmp/results-benchmark-recursive/"
echo "Removing and recreating '$RESULTSDIR'"
(pfexec rm -rf ${RESULTSDIR}) && mkdir ${RESULTSDIR}
mkdir ${RESULTSDIR}stat/

# Clear kieker.log and initialize logging
rm -f ${BASEDIR}kieker.log

RESULTSFN="${RESULTSDIR}results.csv"
# Write csv file headers:
CSV_HEADER="configuration;iteration;order_index;recursion_depth;thread_id;duration_nsec"
echo ${CSV_HEADER} > ${RESULTSFN}

AOPXML_INSTR_DEACTPROBE="-Dorg.aspectj.weaver.loadtime.configuration=META-INF/aop-deactivatedProbe.xml"
AOPXML_INSTR_PROBE="-Dorg.aspectj.weaver.loadtime.configuration=META-INF/aop-probe.xml"

KIEKER_MONITORING_CONF_NOLOGGING="META-INF/kieker.monitoring-nologging.properties"
KIEKER_MONITORING_CONF_LOGGING="META-INF/kieker.monitoring-logging.properties"

JAVAARGS="-server"
JAVAARGS="${JAVAARGS} -d64"
#JAVAARGS="${JAVAARGS} -XX:+PrintCompilation -XX:+PrintInlining"
#JAVAARGS="${JAVAARGS} -XX:+UnlockDiagnosticVMOptions -XX:+LogCompilation"
#JAVAARGS="${JAVAARGS} -Djava.compiler=NONE"
JAR="-jar dist/OverheadEvaluationMicrobenchmark.jar"

JAVAARGS_NOINSTR="${JAVAARGS}"
JAVAARGS_LTW="${JAVAARGS} -javaagent:${BASEDIR}lib/aspectjweaver.jar -Dorg.aspectj.weaver.showWeaveInfo=false -Daj.weaving.verbose=false"
JAVAARGS_KIEKER="-Djava.util.logging.config.file=META-INF/logging.properties"
JAVAARGS_KIEKER_DEACTV="${JAVAARGS_LTW} ${AOPXML_INSTR_DEACTPROBE} ${JAVAARGS_KIEKER} -Dkieker.monitoring.configuration=${KIEKER_MONITORING_CONF_NOLOGGING}"
JAVAARGS_KIEKER_NOLOGGING="${JAVAARGS_LTW} ${AOPXML_INSTR_PROBE} ${JAVAARGS_KIEKER} -Dkieker.monitoring.configuration=${KIEKER_MONITORING_CONF_NOLOGGING}"
JAVAARGS_KIEKER_LOGGING="${JAVAARGS_LTW} ${AOPXML_INSTR_PROBE} ${JAVAARGS_KIEKER} -Dkieker.monitoring.configuration=${KIEKER_MONITORING_CONF_LOGGING} -Dkieker.monitoring.storeInJavaIoTmpdir=false -Dkieker.monitoring.customStoragePath=${BASEDIR}tmp"

## Write configuration
uname -a >${RESULTSDIR}configuration.txt
java ${JAVAARGS} -version 2>>${RESULTSDIR}configuration.txt
echo "JAVAARGS: ${JAVAARGS}" >>${RESULTSDIR}configuration.txt
echo "" >>${RESULTSDIR}configuration.txt
echo "Runtime: circa ${TIME} seconds" >>${RESULTSDIR}configuration.txt
echo "" >>${RESULTSDIR}configuration.txt
echo "SLEEPTIME=${SLEEPTIME}" >>${RESULTSDIR}configuration.txt
echo "NUM_LOOPS=${NUM_LOOPS}" >>${RESULTSDIR}configuration.txt
echo "TOTALCALLS=${TOTALCALLS}" >>${RESULTSDIR}configuration.txt
echo "RECORDEDCALLS=${RECORDEDCALLS}" >>${RESULTSDIR}configuration.txt
echo "METHODTIME=${METHODTIME}" >>${RESULTSDIR}configuration.txt
echo "THREADS=${THREADS}" >>${RESULTSDIR}configuration.txt
echo "MAXRECURSIONDEPTH=${MAXRECURSIONDEPTH}" >>${RESULTSDIR}configuration.txt
sync

## Execute Benchmark

for ((i=1;i<=${NUM_LOOPS};i+=1)); do
    echo "## Starting iteration ${i}/${NUM_LOOPS}"

    for ((j=1;j<=${MAXRECURSIONDEPTH};j+=1)); do
        echo "# Starting recursion ${i}.${j}/${MAXRECURSIONDEPTH}"

        # 1 No instrumentation
        echo " # ${i}.1 No instrumentation"
        mpstat 1 > ${RESULTSDIR}stat/mpstat-${i}-${j}-1.txt &
        vmstat 1 > ${RESULTSDIR}stat/vmstat-${i}-${j}-1.txt &
        iostat -xn 10 > ${RESULTSDIR}stat/iostat-${i}-${j}-1.txt &
        ${BINDJAVA} java  ${JAVAARGS_NOINSTR} ${JAR} \
            --output-filename ${RESULTSFN} \
            --configuration-id "noinstr;${i};1;${j}" \
            --totalcalls ${TOTALCALLS} \
            --recordedcalls ${RECORDEDCALLS} \
            --methodtime ${METHODTIME} \
            --totalthreads ${THREADS} \
            --recursiondepth ${j}
        kill %mpstat
        kill %vmstat
        kill %iostat
        [ -f ${BASEDIR}hotspot.log ] && mv ${BASEDIR}hotspot.log ${RESULTSDIR}hotspot_${i}_1.log
        sync
        sleep ${SLEEPTIME}


        # 2 Deactivated probe
        echo " # ${i}.2 Deactivated probe"
        mpstat 1 > ${RESULTSDIR}stat/mpstat-${i}-${j}-2.txt &
        vmstat 1 > ${RESULTSDIR}stat/vmstat-${i}-${j}-2.txt &
        iostat -xn 10 > ${RESULTSDIR}stat/iostat-${i}-${j}-2.txt &
        ${BINDJAVA} java  ${JAVAARGS_KIEKER_DEACTV} ${JAR} \
            --output-filename ${RESULTSFN} \
            --configuration-id "deact_probe;${i};2;${j}" \
            --totalcalls ${TOTALCALLS} \
            --recordedcalls ${RECORDEDCALLS} \
            --methodtime ${METHODTIME} \
            --totalthreads ${THREADS} \
            --recursiondepth ${j}
        kill %mpstat
        kill %vmstat
        kill %iostat
        [ -f ${BASEDIR}hotspot.log ] && mv ${BASEDIR}hotspot.log ${RESULTSDIR}hotspot_${i}_2.log
        echo >>${BASEDIR}kieker.log
        echo >>${BASEDIR}kieker.log
        sync
        sleep ${SLEEPTIME}

        # 3 No logging
        echo " # ${i}.3 No logging (null writer)"
        mpstat 1 > ${RESULTSDIR}stat/mpstat-${i}-${j}-3.txt &
        vmstat 1 > ${RESULTSDIR}stat/vmstat-${i}-${j}-3.txt &
        iostat -xn 10 > ${RESULTSDIR}stat/iostat-${i}-${j}-3.txt &
        ${BINDJAVA} java  ${JAVAARGS_KIEKER_NOLOGGING} ${JAR} \
            --output-filename ${RESULTSFN} \
            --configuration-id "no_logging;${i};3;${j}" \
            --totalcalls ${TOTALCALLS} \
            --recordedcalls ${RECORDEDCALLS} \
            --methodtime ${METHODTIME} \
            --totalthreads ${THREADS} \
            --recursiondepth ${j}
        kill %mpstat
        kill %vmstat
        kill %iostat
        [ -f ${BASEDIR}hotspot.log ] && mv ${BASEDIR}hotspot.log ${RESULTSDIR}hotspot_${i}_3.log
        echo >>${BASEDIR}kieker.log
        echo >>${BASEDIR}kieker.log
        sync
        sleep ${SLEEPTIME}

        # 4 Logging
        echo " # ${i}.4 Logging"
        mpstat 1 > ${RESULTSDIR}stat/mpstat-${i}-${j}-4.txt &
        vmstat 1 > ${RESULTSDIR}stat/vmstat-${i}-${j}-4.txt &
        iostat -xn 10 > ${RESULTSDIR}stat/iostat-${i}-${j}-4.txt &
        ${BINDJAVA} java  ${JAVAARGS_KIEKER_LOGGING} ${JAR} \
            --output-filename ${RESULTSFN} \
            --configuration-id "logging;${i};4;${j}" \
            --totalcalls ${TOTALCALLS} \
            --recordedcalls ${RECORDEDCALLS} \
            --methodtime ${METHODTIME} \
            --totalthreads ${THREADS} \
            --recursiondepth ${j}
        kill %mpstat
        kill %vmstat
        kill %iostat
        mkdir -p ${RESULTSDIR}kiekerlog/
        mv ${BASEDIR}tmp/kieker-* ${RESULTSDIR}kiekerlog/
        [ -f ${BASEDIR}hotspot.log ] && mv ${BASEDIR}hotspot.log ${RESULTSDIR}hotspot_${i}_4.log
        echo >>${BASEDIR}kieker.log
        echo >>${BASEDIR}kieker.log
        sync
        sleep ${SLEEPTIME}
    
    done

done
tar cf ${RESULTSDIR}kiekerlog.tar ${RESULTSDIR}kiekerlog/
pfexec rm -rf ${RESULTSDIR}kiekerlog/
gzip -9 ${RESULTSDIR}kiekerlog.tar
tar cf ${RESULTSDIR}stat.tar ${RESULTSDIR}stat/
rm -rf ${RESULTSDIR}stat/
gzip -9 ${RESULTSDIR}stat.tar
mv ${BASEDIR}kieker.log ${RESULTSDIR}kieker.log
## ${BINDIR}run-r-benchmark-recursive.sh
[ -f ${RESULTSDIR}hotspot_1_1.log ] && grep "<task " ${RESULTSDIR}hotspot_*.log >${RESULTSDIR}log.log
[ -f ${BASEDIR}nohup.out ] && mv ${BASEDIR}nohup.out ${RESULTSDIR}
