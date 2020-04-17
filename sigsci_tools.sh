#!/bin/bash
#
# Prompt for SigSci Credentials and stores them in your OSX keychain 
# 

# Written for OSX
if [ `uname` != "Darwin" ] ; then
	echo "Requires OSX"
	exit 1
fi

version="0.3"

#function to load Signal Science Credentials into Apple KeyStore
save_keystore () {
        echo -n "Please enter the Signal Sciences User Name: "
        read SIGSCI_EMAIL
        echo -n "Please enter the Signal Sciences API Token: "
        read SIGSCI_API_TOKEN
	echo -n "Please enter the Signal Sciences Corp: "
	read SIGSCI_CORP

if [ -z "$SIGSCI_EMAIL" ] || [ -z "$SIGSCI_API_TOKEN" ] || [ -z "$SIGSCI_CORP" ]; then
	echo "Unable to get all the required parameters. Unable to proceed."
	exit 1
fi

        KEYCHAIN_ENTRY=$SIGSCI_EMAIL
        security add-generic-password -c SSCI -D SIGSCI_EMAIL -a SIGSCI_EMAIL -s $KEYCHAIN_ENTRY -w $SIGSCI_EMAIL -T /usr/bin/security
        security add-generic-password -c SSCI -D SIGSCI_API_TOKEN -a SIGSCI_API_TOKEN -s $KEYCHAIN_ENTRY -w "$SIGSCI_API_TOKEN"
        security add-generic-password -c SSCI -D SIGSCI_CORP -a SIGSCI_CORP -s $KEYCHAIN_ENTRY -w "$SIGSCI_CORP"


        echo -n "Added $SIGSCI_EMAIL to Apple KeyStore: "
        security find-generic-password -a SIGSCI_EMAIL -s $KEYCHAIN_ENTRY -w
        echo -n "Added Password to Apple KeyStore (truncated for security): "
        security find-generic-password -a SIGSCI_EMAIL -s $KEYCHAIN_ENTRY -w | cut -c1-30
	echo -n "Added $SIGSCI_CORP to Apple KeyStore: "
        security find-generic-password -a SIGSCI_CORP -s $KEYCHAIN_ENTRY -w
}

#function to extract Signal Sciences Keystore from Apple KeyStore and load into local Environment Vars
load_env () {
        echo -n "Please enter the Signal Sciences User Name: "
        read SIGSCI_EMAIL

if [ -z "$SIGSCI_EMAIL" ] ; then
        echo "Unable to get all the right credentials . Unable to proceed."
        exit 1
fi
	KEYCHAIN_ENTRY=$SIGSCI_EMAIL
        echo "### PASTE THE FOLLOWING LINES IN YOUR SHELL SESSION ###"
        echo export SIGSCI_EMAIL=$(security find-generic-password -s $KEYCHAIN_ENTRY -a SIGSCI_EMAIL -w)
        echo export SIGSCI_API_TOKEN=$(security find-generic-password -s $KEYCHAIN_ENTRY -a SIGSCI_API_TOKEN -w)
        echo export SIGSCI_CORP=$(security find-generic-password -s $KEYCHAIN_ENTRY -a SIGSCI_CORP -w)
        echo clear
}

Usage()
{
	cat <<EOF >&2
  $0 - [$version]  
  Usage $0 [-s|--save] [-l|--load] [-h|--help]
		-s|--save 	        Save Signal Science Credentials into Apple Key Store
		-l|--load 	        Load from Signal Science Credentials from Apple Key Store into Environment Variables 
		-h|--help 		Help
EOF
	exit 0
}

if [ -z "$1" ]; then
			Usage
		else
			RETVAL=1
		fi

while [ $# -gt 0 ]; do
   case "$1" in
      --help|-h) 
         echo "Usage: $0 [-s|--save] [-|--load] [-h|--help]"
         RETVAL=1
         ;;
      --save|-s)
         save="true"
         shift
         ;;
      --load|-l)
       load="true"
         shift
         ;;
   esac
   shift 1
done

if [ "$save" == "true" ]; then
    save_keystore  
fi

if [ "$load" == "true" ]; then
    load_env
fi

exit $RETVAL




