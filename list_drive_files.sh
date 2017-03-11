#! /bin/bash

param="$1"

access_token=$(cat "${HOME}/.google_token_config" | awk -F= '/ACCESS_TOKEN/{print $2}')

items=$( curl -s "https://www.googleapis.com/drive/v2/files?access_token=$access_token" | jq .items )

echo $items | jq -r '.[] | "\(.modifiedDate)%%%\(.id)%%%\(.labels.trashed)%%%\(.title)"' | while read line; do
	modifiedDate=$(echo $line | awk -F%%% '{print $1}')
	id=$(echo $line | awk -F%%% '{print $2}')
	trashed=$(echo $line | awk -F%%% '{print $3}')
	title=$(echo $line | awk -F%%% '{print $4}')

	title_escaped=$( echo "$title" | sed -e 's|"|\\"|g' )

	if [ ! -z "$param" ] && [ "$param"=="--json" ]; then
		line_json="{\"modifiedDate\": \"$modifiedDate\", \"id\": \"$id\", \"trashed\": \"$trashed\", \"title\": \"$title_escaped\"}"
		echo "$line_json" | jq .
	else
		line_json="$modifiedDate\t$id\t$trashed\t$title_escaped"
		echo -e "$line_json"
	fi
done
