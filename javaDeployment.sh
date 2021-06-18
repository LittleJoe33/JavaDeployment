for arg in "$@"; do
    RPM=$*

    #checks args are not null
    if [[ -z "$1" ]] ; then
        echo "No package name supplied"
        exit 1
    fi

    #defines regex to capture the MAJ.MIN.PAT-BUILD-el* numbers from arg
    verRegex='(([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+)\-([[:digit:]]+))\.el([[:digit:]])'
    #compare arg to regex and store captured regex patterns as varibles
    [[ "$RPM" =~ $verRegex ]]
    nversion="${BASH_REMATCH[1]}"
    nmajor="${BASH_REMATCH[2]}"
    nminor="${BASH_REMATCH[3]}"
    npatch="${BASH_REMATCH[4]}"
    nbuild="${BASH_REMATCH[5]}"
    nel="${BASH_REMATCH[6]}"
    #throws error if regex is not found within arg.
    if [[ -z "${BASH_REMATCH[1]}" ]] ; then
        echo 'Error recognising RPM version format'
        exit 1
    fi

    #function to compare version of RPM passed in to version currently installed. Then calls either the upgrade or downgrade sub-function accordingly.
    version_comp () {
    #both functions echo the current version and new version to terminal and asks user to confirm the change. extra warning in place for downgrades. yum commands will differ once tested in dev-d
        upgrade () {
                echo "UPGRADING $RPMname from $iversion to $nversion"
                read -p "Continue (y/n)?" CONT
                if [ "$CONT" = "y" ]; then
                    RPM=${RPM%.rpm}
                    yum clean all
                    yum update $RPM
                else
                    echo "aborted by user";
                fi
        }

        downgrade () {
                echo "DOWNGRADING $RPMname from $iversion to $nversion"
                read -p "!!!WARNING, THIS IS A DOWNGRADE!!! Continue (y/n)?" CONT
                if [ "$CONT" = "y" ]; then
                    RPM=${RPM%.rpm}
                    yum clean all
                    yum downgrade $RPM
                else
                    echo "aborted by user";
                fi
        }
        #regex from earlier is used again to grab current version and compare to new version
        for Line in $Lines
            do
                [[ "$Line" =~ $verRegex ]]
                iversion="${BASH_REMATCH[1]}"
                imajor="${BASH_REMATCH[2]}"
                iminor="${BASH_REMATCH[3]}"
                ipatch="${BASH_REMATCH[4]}"
                ibuild="${BASH_REMATCH[5]}"
                #elif ladder compares versions starting with most significant digit
                if [[ -z "${BASH_REMATCH[1]}" ]] ; then
                :
                elif [[ "$nversion" == "$iversion" ]]; then
                    echo "same version"
                elif [[ "$nmajor" > "$imajor" ]]; then
                    upgrade
                elif [[ "$nmajor" < "$imajor" ]]; then
                    downgrade
                elif [[ "$nminor" > "$iminor" ]]; then
                    upgrade
                elif [[ "$nminor" < "$iminor" ]]; then
                    downgrade
                elif [[ "$npatch" > "$ipatch" ]]; then
                    upgrade
                elif [[ "$npatch" < "$ipatch" ]]; then
                    downgrade
                elif [[ "$nbuild" > "$ibuild" ]]; then
                    upgrade
                elif [[ "$nbuild" < "$ibuild" ]]; then
                    downgrade
                else
                    echo 'Unknown error. Probably to do with version numbers. Expected format is "PACKAGENAME-MAJ.MIN.PATCH-BUILD.el*.x86_64.rpm"'
                    exit 1
                fi
            done
    }

    #function to run yum installed search with arg and print result to temp.txt file, file is then read during the version compare when version_comp is called
    temp_file () {
    sudo yum list installed "$RPMname" > temp.txt
    File="temp.txt"
    Lines=$(cat $File)
    if grep -Fq "$RPMname" temp.txt; then
        version_comp
    else
        echo "bad temp file"
    fi
    }

    #finds RPM name within arg and sets varible for sake of yum search command and user feedback, then calls temp_file function
    if [[ $RPM == *"vcg-autoboarding"* ]]; then
    RPMname="vcg-autoboarding"
    temp_file
    elif [[ $RPM == *"vcg-iid-simulator"* ]]; then
    RPMname="vcg-iid-simulator"
    temp_file
    elif [[ $RPM == *"vcg-dummy-scheme-amex"* ]]; then
    RPMname="vcg-dummy-scheme-amex"
    temp_file
    elif [[ $RPM == *"vcg-dummy-scheme-mastercard"* ]]; then
    RPMname="vcg-dummy-scheme-mastercard"
    temp_file
    elif [[ $RPM == *"vcg-dummy-scheme-visa"* ]]; then
    RPMname="vcg-dummy-scheme-visa"
    temp_file
    elif [[ $RPM == *"vcg-central-services"* ]]; then
    RPMname="vcg-central-services"
    temp_file
    elif [[ $RPM == *"vcg-security-services"* ]]; then
    RPMname="vcg-central-services"
    temp_file
    elif [[ $RPM == *"vcg-accounts"* ]]; then
    RPMname="vcg-central-services"
    temp_file
    elif [[ $RPM == *"vcg-mas-gw"* ]]; then
    RPMname="vcg-central-services"
    temp_file
    elif [[ $RPM == *"vcg-endpoint-gateway-authmodule"* ]]; then
    RPMname="vcg-central-services"
    temp_file
    elif [[ $RPM == *"vcg-endpoint-jobs"* ]]; then
    RPMname="vcg-central-services"
    temp_file
    elif [[ $RPM == *"vcg-endpoint-service"* ]]; then
    RPMname="vcg-central-services"
    temp_file
    elif [[ $RPM == *"vcg-endpoint-tools"* ]]; then
    RPMname="vcg-central-services"
    temp_file
    else
    echo "RPM invalid"
    exit 1
    fi
  #cycle to next arg
  shift
done
