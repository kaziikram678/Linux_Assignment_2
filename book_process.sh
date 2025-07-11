#!/usr/bin/bash

# Initialize counters and files
total_sentences=0
total_words=0
tmp_cleaned_text="cleaned_text.tmp"
tmp_word_list="word_list.tmp"
tmp_sentence_lengths="sentence_lengths.tmp"

cleanup() {
    rm -f "$tmp_cleaned_text" "$tmp_word_list" "$tmp_sentence_lengths"
}

trap cleanup EXIT

# Convert text to lowercase and remove punctuation
preprocess_text() {
    
}

count_word_frequency() {
    # Split words and count frequency
    tr ' ' '\n' < "$tmp_cleaned_text" | grep -v '^$' | sort | uniq -c | sort -nr > "$tmp_word_list"
    
    echo "Top 10 most frequent words:"
    head -n 10 "$tmp_word_list"
    echo
}

analyze_sentences() {
    echo "Sentences with more than 10 words:"
    echo "-----------------------------------"

    while IFS= read -r sentence; do
        # Remove punctuation and convert to lowercase (again for accurate counting)
        clean_sentence=$(echo "$sentence" | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]')
        word_count=$(echo "$clean_sentence" | wc -w)
        echo "$word_count" >> "$tmp_sentence_lengths"
        (( total_sentences++ ))
        (( total_words += word_count ))
        if (( word_count > 10 )); then
            echo "$sentence"
        fi
    done < <(tr -d '\r' < "$1" | sed -E 's/([.!?]) /\1\n/g')  # Split sentences
}

calculate_average() {
    if (( total_sentences > 0 )); then
        average=$(echo "scale=2; $total_words / $total_sentences" | bc)
        echo -e "\nTotal sentences: $total_sentences"
        echo "Average number of words per sentence: $average"
    else
        echo "No sentences found."
    fi
}

main() {
    if [[ ! -f "$1" ]]; then
        echo "File $1 does not exist."
        exit 1
    fi

    if [[ ! -r "$1" ]]; then
        echo "File $1 is not readable."
        exit 2
    fi

    preprocess_text "$1"
    count_word_frequency
    analyze_sentences "$1"
    calculate_average
}

main "$1"
