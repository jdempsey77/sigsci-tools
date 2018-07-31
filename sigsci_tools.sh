#!/bin/bash
#
# Prompt for SigSci Credentials and stores them in your OSX keychain 
# Use this with the sigsci  script.

# Abort if not on a Mac, because WTF
if [ `uname` != "Darwin" ] ; then
	echo "Requires OSX"
	exit 1
fi

version="0.1"

#function to load Signal Science Credentials into Apple KeyStore
load_keystore () {
        echo -n "Please enter the Signal Sciences User Name: "
        read SIGSCI_EMAIL
        echo -n "Please enter the Signal Sciences Password: "
        read SIGSCI_PASSWORD

if [ -z "$SIGSCI_EMAIL" ] || [ -z "$SIGSCI_PASSWORD" ] ; then
	echo "Unable to get all the right credentials . Unable to proceed."
	exit 1
fi

        KEYCHAIN_ENTRY=$SIGSCI_EMAIL
        security add-generic-password -c SSCI -D SIGSCI_EMAIL -a SIGSCI_EMAIL -s $KEYCHAIN_ENTRY -w $SIGSCI_EMAIL -T /usr/bin/security
        security add-generic-password -c SSCI -D SIGSCI_PASSWORD -a SIGSCI_PASSWORD -s $KEYCHAIN_ENTRY -w "$SIGSCI_PASSWORD"

        echo -n "Added $SIGSCI_EMAIL to Apple KeyStore: "
        security find-generic-password -a SIGSCI_EMAIL -s $KEYCHAIN_ENTRY -w
        echo -n "Added Password to Apple KeyStore (truncated for security): "
        security find-generic-password -a SIGSCI_EMAIL -s $KEYCHAIN_ENTRY -w | cut -c1-30
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
        echo ### PASTE THE FOLLOWING LINES IN YOUR .bash_profile ###
        echo $KEYCHAIN_ENTRY=$SIGSCI_EMAIL
        echo export SIGSCI_EMAIL=$(security find-generic-password -s $KEYCHAIN_ENTRY -a SIGSCI_EMAIL -w)
        echo export SIGSCI_PASSWORD=$(security find-generic-password -s $KEYCHAIN_ENTRY -a SIGSCI_PASSWORD -w) | grep '\$'
}

Usage()
{
	cat <<EOF >&2
  $0 - [$version]  
  Usage $0 [-k|--key] [-e|--env] [-h|--help]
		-k|--key 		Load Signal Science Credentials into Apple Key Store
		-e|--env 	        Load from Signal Science Credentials from Apple Key Store into Environment Variables 
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
         echo "Usage: $0 [-k|--key] [-e|--env] [-h|--help]"
         RETVAL=1
         ;;
      --key|-k)
         key="true"
         shift
         ;;
      --env|-e)
         env="true"
         shift
         ;;
   esac
   shift 1
done

if [ "$key" == "true" ]; then
    load_keystore  
fi

if [ "$env" == "true" ]; then
    load_env
fi

exit $RETVAL




