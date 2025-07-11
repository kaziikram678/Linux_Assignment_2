#!/usr/bin/bash

total_line=0
most_req_ip=""
most_req_ip_count=0
#ip_address=""
declare -A ip_count
#end_point=""
declare -A endpoint_count


process_log_line(){
    local log_line="$1"

    ((total_line++))

    local ip_address=$(echo "$log_line" | cut -d " " -f1)
    ip_count["$ip_address"]=$(( ip_count["$ip_address"] + 1 ))
    
    local end_point=$(echo "$log_line" | cut -d " " -f7)
    endpoint_count["$end_point"]=$(( endpoint_count["$end_point"] + 1 ))
}


parse_log_file(){
    local file_name="$1"

    if [[ ! -f "$file_name" ]]; then
        echo "$file_name doesn't exist"
        exit 1
    fi

    if [[ ! -r "$file_name" ]]; then
        echo "$file_name isn't readable"
        exit 2
    fi

    while IFS= read -r line; do
        process_log_line "$line"
    done < "$file_name"

    echo "Total Line: ${total_line}"

    echo "===========IP ADDRESS COUNT =========="
    
    for ip in "${!ip_count[@]}"; do
        echo "$ip => ${ip_count[$ip]}"

        if (( ip_count[$ip] > most_req_ip_count )); then
            most_req_ip="$ip"
            most_req_ip_count=${ip_count["$ip"]}
        fi
    done

    echo "Most req IP $most_req_ip , it occurs $most_req_ip_count times"


    echo "===========END POINT COUNT =========="

    for endpoint in "${!endpoint_count[@]}"; do
        echo "${endpoint_count[$endpoint]} $endpoint" 
    done | sort -n

}

parse_log_file "$1"
