#!/usr/bin/env bash
Sources=$(jq '.sources' $1)
SourcesLength=$(echo ${Sources} | jq 'length')

# Setup output dir
if [ ! -d "$2" ]
then
	echo "An output directory must be supplied as the second argument."
	exit 1
fi
rm -rf $2 && mkdir $2

# Setup repos directory
if [ ! -d "repos" ]; then
	mkdir repos
fi

cd repos

# Iterate through sources
for ((a=0; a < SourcesLength; a++))
do
	Source=$(echo $Sources | jq ".[${a}]")
	declare $(echo $Source | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]')

	# Check necessary variables exist
	for var in { $name $slug $repo }
	do
		if [ -z ${var+x} ]
			then
				echo "Source must contain a name, slug, & repo"
				exit
		fi
	done

	echo "Fetching documentation for $name"

	# Fetch latest from git repo
	if [ -d "$slug" ]
	then
		cd $slug && git pull && cd ..
	else
		git clone $repo $slug
	fi

	mkdir ../$2/$slug
	cp $slug/README.md ../$2/$slug/README.md

	echo "Finished getting documentation for $name"
done

cd ..
