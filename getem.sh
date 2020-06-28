#!/usr/bin/env bash
Sources=$(jq '.sources' $1)
SourcesLength=$(echo ${Sources} | jq 'length')

printf "\nRunning getem script \n"

# Setup output dir
if [ -z ${2+x} ]
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
				exit 1
		fi
	done

	printf "\nFetching $name\n\n"

	# Fetch latest from git repo
	if [ -d "$slug" ]
	then
		cd $slug && git pull && cd ..
	else
		git clone $repo $slug
	fi

	mkdir ../$2/$slug

	cp $slug/README.md ../$2/$slug/README.md

	if [ ! -z ${categories+x} ]
	then
		CategoriesLength=$(echo $categories | jq 'length');
		echo "Found $CategoriesLength categories"
		for ((x=0; x < CategoriesLength; x++))
		do
			Path=$(echo $categories | jq -r ".[${x}].path")
			if [ -z ${Path+x} ]
			then
				echo "Path for category not provided"
			else
				if [ -d "$slug/$Path" ]
				then
					cp -r $slug/$Path ../$2/$slug/$Path
					echo "Copied contents of $Path"
				else
					echo "No directory $Path found within $name"
				fi
			fi
		done
	fi

	printf "\nFinished with $name\n\n"
done

cd ..
