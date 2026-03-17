#!/bin/bash
# Extract URL, title and tags from getpocket.com/export CSV export
# and pass to shiori for import ($1 is the CSV file, $2 is optional annotations JSON)
# Requires csvkit and runs shiori commands via docker exec

CONTAINER_NAME="shiori"

# Check if container is running
if ! docker ps | grep -q $CONTAINER_NAME; then
    echo "Error: Container $CONTAINER_NAME is not running"
    exit 1
fi

# Check if csvkit is available
if ! command -v csvcut &> /dev/null; then
    echo "Error: csvkit is not installed. Install with: pip install csvkit"
    exit 1
fi

# Check if annotations file is provided
ANNOTATIONS_FILE="$2"
if [ -n "$ANNOTATIONS_FILE" ] && [ -f "$ANNOTATIONS_FILE" ]; then
    echo "Using annotations from $ANNOTATIONS_FILE"
    # Create a temporary file with URL->excerpt mapping
    python3 -c "
import json
import sys

with open('$ANNOTATIONS_FILE', 'r') as f:
    data = json.load(f)

for entry in data:
    url = entry.get('url', '')
    highlights = entry.get('highlights', [])
    if highlights and highlights[0].get('quote'):
        excerpt = highlights[0]['quote']
        # Clean up the excerpt - remove newlines and limit length
        excerpt = excerpt.replace('\n', ' ').strip()
        if len(excerpt) > 500:
            excerpt = excerpt[:497] + '...'
        print(f'{url}|{excerpt}')
" > url_excerpts.txt
fi

# Use csvkit to reorder the columns to something more convenient
csvcut -c "url,tags,title" $1 > pocket2shiori.csv

# Remove the header row so it's not processed by the while loop
sed -i '1d' pocket2shiori.csv

# Track errors
fail=0

# Now we can use cut
while IFS= read -r line; do
    # Extract the relevant fields
    link=$(echo "$line" | cut -d ',' -f1)
    tags=$(echo "$line" | cut -d ',' -f2)
    title=$(echo "$line" | cut -d ',' -f3-)

    # Remove any quotes around the title, since they will be added at the import step anyway
    title="${title%\"}"
    title="${title#\"}"

    # Convert tags to comma-separated since the Pocket export uses | instead
    tags=${tags//|/,}

    # Get excerpt from annotations if available
    excerpt=""
    if [ -f "url_excerpts.txt" ]; then
        excerpt=$(grep "^${link}|" url_excerpts.txt | cut -d'|' -f2- | head -1)
    fi

    # Build shiori command
    cmd="docker exec $CONTAINER_NAME /usr/bin/shiori add \"$link\""
    
    if [ -n "$tags" ]; then
        cmd="$cmd -t \"$tags\""
    fi
    
    if [ "$link" != "$title" ]; then
        cmd="$cmd -i \"$title\""
    fi
    
    if [ -n "$excerpt" ]; then
        cmd="$cmd -e \"$excerpt\""
    fi

    # Execute the command
    echo "Importing: $title"
    eval $cmd
    ec=$?

    # Check if the import was successful
    if [ $ec -ne 0 ]; then
        fail=1
        echo "Failed to import $link"
        echo "$link" >> pocket2shiori.failed
    fi
done < pocket2shiori.csv

# Cleanup temporary files
if [ -f "url_excerpts.txt" ]; then
    rm url_excerpts.txt
fi

if [ $fail -eq 0 ]; then
    rm pocket2shiori.csv
    echo "Import completed successfully!"
else
    echo "Import completed with some failures. Check pocket2shiori.failed for details."
fi
exit $fail
