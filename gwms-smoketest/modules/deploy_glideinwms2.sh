#!/bin/bash

# Tool to automate the GlideinWMS rpm deployment and testing
# Author: Parag Mhashilkar
# 




function write_common_functions() {
    local setup_script=$1

    cat >> $setup_script << EOF

yell() { echo "\$0: \$*" >&2; }
die() { yell "\$*"; exit 111; }
try() { echo "\$@"; "\$@" || die "FAILED \$*"; }


function start_logging() {
    logfile=\$1
    logpipe=\$logfile.pipe
    rm -f \$logfile \$logpipe

    mkfifo \$logpipe
    tee -a \$logfile < \$logpipe &
    logpid=\$!
    exec 3>&1 4>&2 > \$logpipe 2>&1
}

function stop_logging() {
    if [ -z "\$logpid" ]; then
        echo "Logging not yet started!"
        return 1
    fi
    exec 1>&3 3>&- 2>&4 4>&-
    wait \$logpid
    rm -f \$logpipe
    unset logpid
}

function patch_httpd_config() {
    echo "Customizing httpd.conf ..."
    cp $HTTPD_CONF $HTTPD_CONF.$TS
    sed -e 's/Options Indexes FollowSymLinks/Options FollowSymLinks/g' $HTTPD_CONF.$TS > $HTTPD_CONF
}

function patch_privsep_config() {
    factory_groups=\`id -Gn gfactory | tr " " ":"\`
    cp $PRIVSEP_CONF $PRIVSEP_CONF.$TS
    sed -e "s/valid-caller-gids = gfactory/valid-caller-gids = \$factory_groups/g" $PRIVSEP_CONF.$TS > $PRIVSEP_CONF
}


function add_dn_to_condor_mapfile() {
    dn="\$1"
    user="$2"
    mapfile="/etc/condor/certs/condor_mapfile"
    tmpfile=\$mapfile.$TS
    
    echo "GSI \"\$dn\" \$2" > \$tmpfile
    cat \$mapfile >> \$tmpfile
    mv \$tmpfile \$mapfile
}

function start_services() {
     for service in \$* ; do
        /sbin/chkconfig \$service on
        /sbin/service \$service restart
     done
}


function disable_selinux() {
    setenforce permissive
}

EOF
}


function create_fact_install_script() {
    local setup_script=$1
    touch $setup_script
    chmod a+x $setup_script
    cat > $setup_script << EOF
#!/bin/bash

logfile=$FACT_LOG
EOF

    write_common_functions $setup_script

    cat >> $setup_script << EOF

function configure_fact() {

    if which systemctl > /dev/null 2>&1 ; then
        gwms-factory upgrade
    else
        /sbin/service gwms-factory upgrade
    fi
}


function verify_factory() {
    entries_enabled=\`grep "<entry " $ENTRIES_CONFIG_DIR/*.xml | grep "enabled=\\"True\\"" | wc -l\`
    entries_found=\`condor_status -subsystem glidefactory -af entryname | wc -l\`

    [ \$entries_enabled -ne \$entries_found ] && return 1
    return 0
}

uname -a
if ! which condor_root_switchboard ; then
    yum -y --enablerepo osg-development install glideinwms-switchboard
fi

patch_privsep_config

add_dn_to_condor_mapfile "$jobs_dn" testuser
add_dn_to_condor_mapfile "$vofe_dn" vofrontend_service
if [ "$vofe_dn" != "$vo_collector_dn" ]; then
    add_dn_to_condor_mapfile "$vo_collector_dn" condor
fi


configure_fact


start_services gwms-factory
sleep 20

fact_status="FAILED"
verify_factory
[ \$? -eq 0 ] && fact_status="SUCCESS"
echo "==================================="
echo "FACTORY VERIFICATION: \$fact_status"
EOF

}


function create_vofe_install_script() {
    local setup_script=$1
    touch $setup_script
    chmod a+x $setup_script
    cat > $setup_script << EOF
#!/bin/bash

logfile=$VOFE_LOG
#echo > \$logfile
#exec > >(tee -a \$logfile)
EOF

    write_common_functions $setup_script

    cat >> $setup_script << EOF

function setup_testuser() {
    user=testuser
    user_home=/var/lib/\$user
    groupadd \$user
    adduser -d \$user_home -g \$user \$user
    id \$user
    if [ "$jobs_proxy" = "" ]; then
        cp /tmp/frontend_proxy /tmp/grid_proxy
    fi
    chown \$user.\$user /tmp/grid_proxy 
    cp -r $AUTO_INSTALL_SRC_DIR/testjobs \$user_home
    chown -R \$user.\$user \$user_home
}

function configure_vofe() {

    if [ "$vofe_proxy" = "" ]; then
        grid-proxy-init -valid 48:0 -cert /etc/grid-security/hostcert.pem -key /etc/grid-security/hostkey.pem -out /tmp/frontend_proxy
        echo 00 \* \* \* \*   /usr/bin/grid-proxy-init -valid 48:0 -cert /etc/grid-security/hostcert.pem -key /etc/grid-security/hostkey.pem -out /tmp/host_proxy \; /bin/cp /tmp/host_proxy /tmp/frontend_proxy \; /bin/cp /tmp/host_proxy /tmp/vo_proxy \;/bin/cp /tmp/host_proxy /tmp/grid_proxy | crontab -
    fi
    chown frontend:frontend /tmp/frontend_proxy
    cp /tmp/frontend_proxy /tmp/vo_proxy
    chown frontend:frontend /tmp/vo_proxy
    if [ -d $AUTO_INSTALL_SRC_DIR/patch/frontend ]; then
       cd $AUTO_INSTALL_SRC_DIR/patch/frontend
       for SRC in \$(find . -type f); do
           TGT=\$(echo \$SRC | sed -e 's/^\.//')
           echo copying \$SRC to \$TGT
           cp \$SRC \$TGT
       done
    fi
    if which systemctl > /dev/null 2>&1 ; then
        gwms-frontend upgrade
    else
        /sbin/service gwms-frontend upgrade
    fi
}

function verify_vofe() {
    entries_found=\`condor_status -pool $fact_fqdn -subsystem glidefactory -af entryname | wc -l\`
    glideclients_created=\`condor_status -pool $fact_fqdn -any -constraint 'glideinmytype=="glideclient"' -af frontendname | wc -l\`

    [ \$glideclients_created -ne \$entries_found ] && return 1
    return 0
}

function submit_testjobs() {
    runuser -c "cd ~/testjobs; mkdir -p mkdir joboutput;  condor_submit ~/testjobs/testjob.singularity.jdf" testuser
}


add_dn_to_condor_mapfile "$jobs_dn" testuser
add_dn_to_condor_mapfile "$vofe_dn" vofrontend_service
if [ "$vofe_dn" != "$vo_collector_dn" ]; then
    add_dn_to_condor_mapfile "$vo_collector_dn" condor
fi
add_dn_to_condor_mapfile "$fact_vm_dn" factory




configure_vofe

start_services gwms-frontend
sleep 20
vofe_status="FAILED"

verify_vofe
[ \$? -eq 0 ] && vofe_status="SUCCESS"
echo "==================================="
echo "FRONTEND VERIFICATION: \$vofe_status"

if [ "\$vofe_status" = "SUCCESS" ]; then

    echo "Setting up testuser ..."
    setup_testuser
    submit_testjobs

fi
EOF

}






function usage() {
    echo "Usage: `basename $0` <OPTIONS>"
    echo "  OPTIONS: "
    echo "  "
}




function help() {
    echo "${prog} [OPTIONS]"
    echo
    echo "OPTIONS:"
    echo "--tag            GlideinWMS tag to test (Default: rpm)"
    echo "--el             Redhat version to test (Default: 6)"
    echo "--osg-version    OSG version to use (Default: 3.3)"
    echo "--osg-repo       OSG repo to use (Default: osg-development)"
    echo "--vm_template    fermicloud template (Default: CLI_DynamicIP_SLF6_HOME"
    echo "--monitor        Launch monitoring scripts in xterm"
    echo "--frontend-proxy Frontend proxy to use. Proxy from host DN is used by default"
    echo "--jobs-proxy     Proxy used to submit jobs. Proxy from host DN is used by default"
    echo "--condor-tarball Location of condor Tarball (local file or remote URL)"
    echo "--gwms-release   glideinwms rpm release (Default: latest)"
    echo "--help           Print this help message"
    echo ""
    echo "#examples"
    echo "#deploy SL6 frontend+factory version 3.2.17"
    echo "./deploy_glideinwms.sh --osg-repo osg --gwms-release 3.2.17"
    echo "#deploy SL7 latest in osg-development"
    echo "./deploy_glideinwms.sh --el 7"
}

######################################################################################
# Script starts here
######################################################################################
prog="`basename $0`"
# Following should be parameterized
tag="rpm"
el=6
# repo = release|development|testing
# ver = 3.3
osg_version="3.4"
osg_repo="osg-development"
launch_monitor="false"

# Read command line args
while [[ $# -gt 0 ]] ; do
    case "$1" in
        --tag)
            tag="${2:-rpm}"
            shift ;;
        --el)
            el="${2:-6}"
            shift ;;
        --osg-version)
            osg_version="${2:-3.3}"
            shift ;;
       --osg-repo)
            osg_repo="${2:-osg-development}"
            shift ;;
       --gwms-release)
            gwms_release="$2"
            shift ;;
        --monitor)
            launch_monitor="true"
            ;;
        --frontend-proxy)
            [ -f "$2" ] && vofe_proxy="$2"
            shift ;;
        --jobs-proxy)
            [ -f "$2" ] && jobs_proxy="$2"
            shift ;;
        --condor-tarball)
            if [ "$condor_tarball" = "" ] ; then
               condor_tarball="$2"
            else
               condor_tarball2="$2"
            fi
            shift ;;
        --vm_template)
            vm_template="${2:-CLI_DynamicIP_SLF6_HOME}"
            shift ;;
        --help)
            help
            exit 0;;
        *)
            echo "Invalid option: $1" 
            exit 1 ;;
    esac
    shift
done
enable_repo="--enablerepo=$osg_repo"

#yum_rpm=yum_priorities
#[ "$el" = "7" ] && yum_rpm=yum-plugin-priorities
yum_rpm=yum-plugin-priorities

[ "$el" = "7" ] &&  [ "$vm_template" = "" ] && vm_template="SLF${el}V_DynIP_Home"
[ "$el" = "6" ] &&  [ "$vm_template" = "" ] && vm_template="CLI_DynamicIP_SLF6_HOME"

[ "$gwms_release" != "" ] && [ "$(echo "$gwms_release" | grep '^-')" = "" ]  && gwms_release="-${gwms_release}"
#echo gwms_release=$gwms_release
#exit


condor_version="default"
condor_os="default"
condor_arch="default"

# Some constants
fact_vm_name="fact-el$el-$tag-test"
vofe_vm_name="vofe-el$el-$tag-test"

if [ -n "$condor_tarball" ]; then
base_condor_tarball=`basename $condor_tarball` 
base_condor_dir=`echo $base_condor_tarball | sed s/.tar.gz//`
condor_version=$(echo $base_condor_tarball | sed s/condor-// | sed s/-.*//)
condor_os=$(echo $base_condor_tarball | sed s/.*_// | sed s/-.*//)
condor_arch=$(echo $base_condor_tarball | sed s/_${condor_os}.*// | sed s/condor-${condor_version}-//)
condor_os=$(echo $condor_os | sed s/RedHat/rhel/g)
fi


#for some reason fermicloudui.fnal.gov is kicking me out, so 
#find one that doesnt...

SSH="ssh fcluigpvm02.fnal.gov"
#SSH="ssh fermicloudui.fnal.gov"
$SSH exit 0
if [ $? -ne 0 ]; then
    SSH="ssh fcluigpvm02.fnal.gov"
fi

ENTRIES_CONFIG_DIR=/etc/gwms-factory/config.d
HTTPD_CONF=/etc/httpd/conf/httpd.conf
PRIVSEP_CONF=/etc/condor/privsep_config
AUTO_INSTALL_SRC_BASE="/tmp"
AUTO_INSTALL_SRC_DIR="$AUTO_INSTALL_SRC_BASE/deploy_config"
TS=`date +%s`


#fact_vmid=`launch_vm $fact_vm_name $vm_template`
#vofe_vmid=`launch_vm $vofe_vm_name $vm_template`

#fact_fqdn=`vm_hostname $fact_vmid`
#vofe_fqdn=`vm_hostname $vofe_vmid`

source ./create_fermicloud_vm2.sh --el $el --vm_template $vm_template --vm_name $fact_vm_name 
fact_fqdn=$fqdn
fact_vmid=$vmid

source ./create_fermicloud_vm2.sh --el $el --vm_template $vm_template --vm_name $vofe_vm_name 
vofe_fqdn=$fqdn
vofe_vmid=$vmid

installed_node_list=/tmp/installed.nodes
touch $installed_node_list
echo $fact_vm_name $fact_fqdn >>  $installed_node_list
echo $vofe_vm_name $vofe_fqdn >>  $installed_node_list



fact_vm_dn="`ssh root@$fact_fqdn openssl x509 -in /etc/grid-security/hostcert.pem -subject -noout | sed -e 's|subject= ||g'`"
vofe_vm_dn="`ssh root@$vofe_fqdn openssl x509 -in /etc/grid-security/hostcert.pem -subject -noout | sed -e 's|subject= ||g'`"

wms_collector_dn="$fact_vm_dn"
vo_collector_dn="$vofe_vm_dn"
if [ -z "$vofe_proxy" ]; then
    vofe_dn="$vo_collector_dn"
else
    # Extract the DN from the proxy
    subject="`openssl x509 -in $vofe_proxy -out -text -subject | sed -e 's|subject= ||g'`"
    issuer="`openssl x509 -in $vofe_proxy -out -text -issuer | sed -e 's|issuer= ||g'`"
    case "$subject" in
        *"$issuer"*) vofe_dn="$issuer" ;;
        *) vofe_dn="$subject" ;;
    esac
fi

if [ -z "$jobs_proxy" ]; then
    jobs_dn="$vofe_dn"
else
    # Extract the DN from the proxy
    subject="`openssl x509 -in $jobs_proxy -out -text -subject | sed -e 's|subject= ||g'`"
    issuer="`openssl x509 -in $jobs_proxy -out -text -issuer | sed -e 's|issuer= ||g'`"
    case "$subject" in
        *"$issuer"*) jobs_dn="$issuer" ;;
        *) jobs_dn="$subject" ;;
    esac
fi


ENTRIES_CONFIG_DIR=/etc/gwms-factory/config.d
HTTPD_CONF=/etc/httpd/conf/httpd.conf
PRIVSEP_CONF=/etc/condor/privsep_config
AUTO_INSTALL_SRC_BASE="/tmp"
AUTO_INSTALL_SRC_DIR="$AUTO_INSTALL_SRC_BASE/deploy_config"
TS=`date +%s`
FACT_LOG=/tmp/fact_install.log
VOFE_LOG=/tmp/vofe_install.log
JOBS_LOG=/tmp/jobs_install.log

echo "==============================================================================="
echo "Deployment Options"
echo "------------------"
echo "prog        : $prog"
echo "tag         : $tag"
echo "el          : $el"
echo "osg_version : $osg_version"
echo "osg_repo    : $osg_repo"
echo "monitor     : $launch_monitor"
echo
echo "Factory Information"
echo "-------------------"
echo "fact_vm     : $fact_vm_name"
echo "vm_template : $vm_template"
echo "fact_vmid   : $fact_vmid"
echo "fact_fqdn   : $fact_fqdn"
echo "fact_dn     : $fact_vm_dn"
echo "wms_pool_dn : $wms_collector_dn"
echo
echo "Frontend Information"
echo "--------------------"
echo "vofe_vm     : $vofe_vm_name"
echo "vm_template : $vm_template"
echo "vofe_vmid   : $vofe_vmid"
echo "vofe_fqdn   : $vofe_fqdn"
echo "vofe_dn     : $vofe_dn"
echo "vofe_proxy  : $vofe_proxy"
echo "vo_pool_dn  : $vo_collector_dn"
echo "jobs_proxy  : $jobs_proxy"
echo "jobs_dn     : $jobs_dn"
echo "==============================================================================="
echo
# Create installation scripts
fact_install_script="/tmp/fact_install.$TS.sh"
vofe_install_script="/tmp/vofe_install.$TS.sh"


create_fact_install_script $fact_install_script
create_vofe_install_script $vofe_install_script

deploy_config_dir=`dirname $0`/deploy_config



./install_module.sh $fact_fqdn osg_client
./install_module.sh $vofe_fqdn osg_client
scp $fact_install_script root@$fact_fqdn:/tmp/fact_install.sh
scp $vofe_install_script root@$vofe_fqdn:/tmp/vofe_install.sh
if [ !  -z "$vofe_proxy" ]; then
    scp $vofe_proxy root@$vofe_fqdn:/tmp/frontend_proxy
    scp $vofe_proxy root@$vofe_fqdn:/tmp/vo_proxy
fi
./install_module.sh $fact_fqdn factory  "fact_fqdn => '$fact_fqdn', vofe_fqdn => '$vofe_fqdn', vofe_dn => '$vofe_dn'"
./install_module.sh $vofe_fqdn vofrontend  "fact_fqdn => '$fact_fqdn', vofe_fqdn => '$vofe_fqdn', vofe_dn =>'$vofe_dn'"

#ssh root@$fact_fqdn  /tmp/fact_install.sh > $FACT_LOG.$TS
#ssh root@$vofe_fqdn  /tmp/vofe_install.sh > $VOFE_LOG.$TS

#tail -1  $FACT_LOG.$TS
#tail -1 $VOFE_LOG.$TS
